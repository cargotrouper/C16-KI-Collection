@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Fertigmelden
//                    OHNE E_R_G
//  Info
//
//
//  21.09.2005  AI  Erstellung der Prozedur
//  04.08.2009  ST  Erweiterung der Theoretischen Fertigmeldung
//  18.08.2009  ST  Fehlerbehandlung beim Abschließen erweitert Projekt 1161/95
//  15.10.2009  AI  Spulen
//  24.11.2009  AI  3 x Messwerte
//  05.01.2010  AI  Versand ist gleich VSB
//  17.02.2010  AI  Reservierungübernahme Einsatz->Verwiegung
//  06.05.2010  AI  Artikelres. nicht mehr zwingend nötig zum Abschliessen
//  25.10.2010  AI  BruttoNetto bei Fahr-Reservierung
//  02.11.2010  AI  Fehlermedlung bei Abschluss von LFA bei denne die LFS nicht verwogen
//  29.11.2010  AI  FM lässt nur noch gleichen BA zu wie Einsatz
//  25.01.2011  AI  NEU; QTEIL im Fertigmelden
//  16.11.2011  AI  RID/RAD nur bei Spalten/Tafeln/Abcoilen nur bei NICHT Rest setzen
//  17.01.2012  AI  FM von Sperre/Ausfall entfernt die Weiterbearbeitung aus dem IO
//  03.02.2012  AI  FMTheorie mit Datum
//  22.02.2012  AI  beim Fertigmelden wird Lohnmaterial ggf. Eigenturm wenn BAG.F.WirdEigenYN
//  15.03.2012  AI  MEH beim Fertigmelden ist immer die von der Fertigung bzw. Output
//  29.06.2012  AI  Glühen/Walzen leert Mechanik 2
//  02.07.2012  AI  NEU:"Verbuchen" erzeugt Analyse
//  20.07.2012  AI  Verpackung beim FM von Fahren nur übernehmen, wenn wirklich vorhanden! Projekt 1161/403
//  30.08.2012  ST  bei FM Auftragsaktionsanlage für 209er, Artikelnummer auch in Auf Aktionsliste  (1326/287)
//  24.09.2012  AI  ArtPrd eingebaut
//  30.11.2012  AI  Schrottrestchargen werden in die BAG.IO.Artikel-Felder gemerkt zum Stornieren
//  09.01.2013  AI  Projekt 1347/96 : LFS-Abschluss nicht RecList refreshen, da sonst Versprung?!?!
//  15.03.2013  ST  Bei "Back In Stock" - Verwiegung soll ein Eingangsetikett gedruckt werden, falls ungeplant
//  20.03.2013  AI  FertigArtanlegen: bucht bei Fahren nicht dazu (LFS macht ja alles)
//  08.04.2013  AI  "Verbuchen" nimmt nur Mat oder Art als FM
//  11.04.2013  AI  MatMEH
//  27.04.2013  AI  Art.MEH in Material aufnehmen, falls ArtMatMix
//  03.05.2013  AI  neuer AFX "BAG.FM.Etikettendruck"
//  26.07.2013  ST  BugFix Mat.MEH nur wenn Wgr Dateinr. nicht 200 ist
//  14.10.2013  AH  Bugfix: EinstzMatMindern rechnet MAt.Bestand.Menge aus und muss NICHT über Mat.Modul künstlich errechnet werden
//  11.11.2013  AH  "Verbuchen" in Unterfuktionen zerteilt & Flag "UnverbuchtYN" eingebaut
//  30.04.2014  AH  "BA FM" setzt auch Start/Endtermine
//  01.08.2014  ST  "AbschlussPos" Prüfung auf Abschlussdatum hinzugefügt Projekt 1326/395
//  19.08.2014  AH  Bug: "AbschlussPos" nimmt beim Fahren statt "BA S" die "BA FA"-Aktionen raus
//  03.11.2014  AH  Neue AFX BAG.P.Abschluss.Pre
//  06.11.2014  AH  "Abschlusspos" löscht bei mehreren LFA auf einer Karte diese niemals, solange sie Bestand hat
//  04.03.2015  AH  Bug: Fehler beim Verbuchen (z.B. Unterdeckung in der Beistellung) kann beim erneuten Speichern übergangen werden
//  16.03.2015  AH  Bug: Nachbesserung zu Fehler beim Verbuchen (z.B. Unterdeckung in der Beistellung) kann beim erneuten Speichern übergangen werden
//  26.03.2015  AH  Bug: s.o.
//  10.04.2015  AH  Auftrags-SL in Kommission aktiviert
//  24.06.2015  AH  Umrechnung der Preise, wenn Fertigung auf Artikel läuft
//  01.07.2015  AH  Etikettentyp für Lagermaterial: Set.BA.FM.Frei.Etk
//  09.07.2015  AH  Abschluss LFA nutzt Mat_Subs:Verschrotten
//  21.10.2015  AH  neue AFX "BAG.FM.FertigAbfrage"
//  04.11.2015  ST  neue AFX zu FMTheorie nach Transoff;
//  16.11.2015  AH  Neu: Schaelen wie Walzen
//  05.02.2016  AH  Neu: Verpacken übernimmt Messwerte
//  16.03.2016  AH  Neu: Feld "BAG.P.Status"
//  23.03.2016  AH  "FMKopf" mit Rücksprungprozedur-Parameter
//  12.04.2016  AH  c_BAG_PACK übernimmt Fertigungs-Güte
//  06.02.2017  AH  Fix: FM aus Bestellung fragte Fertigung nicht immer ab
//  05.05.2017  AH  !!! ABSCHLUSS vom Fahren legt bei Verschrottung RESTKARTE an
//  18.01.2018  ST  Arbeitsgang "Umlagern" hinzugefügt
//  12.07.2018  AH  Fix: "FeritgMatAnlegen" beachtete AUSFALL nicht richtig
//  28.08.2018  AH  Neu: "Verbuchen" kann Einzelringe aus einer Wiegung erzeugen
//  08.10.2018  AH  Neu: AFX "BAG.FM.FMTheorie", AFX "BAG.FM.FmKopf"
//  06.11.2018  AH  Edit: "Verbuchen" kann Etikettentext als Parameter füllen
//  07.11.2018  AH  Neu: Tauschen von Input und Output (wenn mal bei 1zu1 Schritten nicht etikettiert wird)
//  22.11.2018  AH  Neu: Installname
//  12.12.2018  AH  Neu: AFX "BAG.F.RefreshIfm"
//  17.12.2018  AH  Neu: Analyse bekommt Liefernat+Charge+Coilnr
//  15.01.2019  AH  Edit: "BAG.FM.NeuesMat" bekommt direkte Vorgänger-Mat.Nummer als Para
//  16.01.2019  AH  Neu: Fertigmelden errechnet den RAD neu
//  23.01.2019  AH  Edit: Bessere Fehlermeldungen beim EinsatzMatMindern
//  29.01.2019  AH  Fix für MultiLFS pro BA-Pos.
//  22.02.2019  AH  neuer AFX "BAG.FM.Set.MatABemerkung"
//  05.03.2019  AH  BA-Abschluss schließt Vorgänger-Fahren automatisch ab
//  08.05.2019  ST  "ErzeugeMatAusVSB*" ermöglicht auch Fahren von VSB auf Rahmenmaterial
//  24.05.2019  AH  Mat. auf VSB einsetzen, ignoriert die KGMM-Fehler
//  16.07.2019  AH  "BessererLFA", der nur Restmengen anzeigt und ba BA-Ketten sich nicht addiert
//  27.08.2019  AH  "Verbuchen" mit Einzelstücken buffert mehr Sätze
//  11.10.2019  AH  Listenlayout beim FM für Output wird gespeichert
//  13.03.2020  AH  Kostenänderungen werden an vorhandenen ERlöse übermittelt
//  19.06.2020  AH  Set.BA.Ziel.AktivJN
//  25.08.2020  AH  Fix: Abschluss von LFA löscht oder behält Einsatz je nach Restmenge
//  12.11.2020  AH  Fix: s.o. : Abschluss von LFA löscht oder behält Einsatz je nach Restmenge - beachtet NUR NOCH STÜCKZAHL NICHT GEWICHT
//  08.12.2020  AH  "AbschlussPos" mindestens auf spätestes FM-Datum
//  08.02.2021  AH  Fix: "SaveFM" kann bei Einzelstückzahlen auch angehängte Daten kopieren statt erstezen (z.B. BAG.AF)
//  09.02.2021  AH  TauscheInOut übeträgt das Inventurdatum
//  12.04.2021  AH  neuer AFX: "BAG.FM.Verbuchen.Inner.Post"
//  22.04.2021  AH  Typ: PAKET
//  03.05.2021  AH  AFX "BAG.FM.Verbuchen.Etikettenlauf"
//  04.05.2021  ST  Fix: "VererbeReservierungen" Fragt bei MDE Nutzung nicht mehr nach
//  27.07.2021  AH  ERX
//  13.09.2021  AH  AFX "BAG.FM.ChooseMultiInput"
//  (08.10.2021  ST  Fertigmeldung vor Versand: Zielanschrift des Auftrags für Versandpool Projekt 2166/99    -> 02.11.2021 AH)
//  02.11.2021  ST  Fix: Ausführungscleanup bei automatischer Einzelring FM
//  23.11.2021  AH  AFX "BAG.FM.ChooseInput", "BAG.FM.Start.Maske", CHECK übernimmt Messfelder
//  22.12.2021  ST  Fix: MatAnlage/Divers: auch Endabmessungen übernehmen, wenn Fertigung keine Breite vorgegeben hat
//  04.01.2022  AH  AFX "BAG.FM.GetMaskenName"
//  01.02.2022  MR  Edit  BA_Fertigmelden:AbschlussPos Prozentanteil in Messagebox beim BA-Abschluss (2166/136)
//  03.03.2022  ST  Edit  BA_Fertigmelden:AbschlussPosMeltung Schrottgewicht  ist NettoBestand Projekt 2151/128
//  28.05.2022  AH  Edit  Für Etiketten IMMER einen vTxt nutzen
//  30.05.2022  AH  SINGLELOCK
//  30.05.2022  AH  Edit  Neues Etikett bei Entnahmen: 200,'Abbuchungsetikett'
//  08.06.2022  AH  Neu: WalzSpulen
//  2022-06-28  AH  "EtkDruckAusTxt" kann neue oder alte Version vom TextBuf
//  2022-07-05  AH  DEADLOCK
//  2022-07-14  AH  Fix: Paketsumme hatte falsche Stückzahl
//  2022-08-02  MR  Fix: Fail bei Paketieren mittels MDE Zeile 2430
//  2022-08-09  AH  Fix: Fahren mit Tauschen UND Kommission setzt Status im Material richtig
//  2022-10-20  AH  neu: per FM per Tabelle möglich
//  2022-11-22  ST  Fix: MAterialbemerkung bei FM ohne Verpackung wieder io
//  2022-12-01  ST  Fix: BAG Abschluss Datum Fehlerkorrektur
//  2022-12-20  AH  MEH-Wechsel werden nur INNERHALB der Pos gemacht
//  2023-01-19  AH  bei MEH-Wechsel wird neuer EK anderes gebildet, neue BA-MEH-Logik
//  2023-02-03  AH  Abschlussmeldung verändert (Schrottausweisung)
//  2023-02-09  AH  FM per KombiTabelle
//  2023-04-27  AH  BugFix zur Berechnung FM-Mat.Bestand.Menge
//  2023-07-25  AH  "SaveFM" überschreibt IMMER ggf. vorhandene (damit illegale) AFs
//  2023-08-15  AH  Set.BA.AbschlWieWarn
//
//  Subprozeduren
//    SUB EtkDruckAusTxt
//    SUB MinMaxVon3
//    SUB ErzeugeMatausVSB
//    SUB FertigAbfrage
//    SUB AusMaske
//    SUB ChoosePos
//    SUB ChooseInput
//    SUB ChooseMultiInput
//    SUB ChooseOutput
//    SUB AufVSBAktion
//    SUB AbschlussPos
//    SUB Pos
//    SUB EinsatzMatMindern
//    SUB EinsatzArtMindern
//    SUB FertigMatAnlegen(
//    SUB FertigArtAnlegen
//    SUB SaveFM
//    SUB TauscheInUndOut
//    SUB Verbuche707
//    SUB VererbeReservierung
//
//    SUB Verbuchen
//    SUB AbschlussKopf
//    SUB FMKopf
//    SUB FMGesamt
//    SUB FMTheorie
//    SUB Etikettendruck
//    SUB VerbuchenSpulen
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights

@Define defBessererLFA

define begin
  cDebug    : Set.Installname='BSPxxx'
  cDebugLog : '!BSP_Log_Komisch'
end;

declare FMKopf(opt aProc : alpha) : logic;
declare Etikettendruck();
declare TunnelFMdurchLFA();

//========================================================================
//  MinMaxVon3
//
//========================================================================
SUB MinMaxVon3(
  aWert1 : float;
  aWert2 : float;
  aWert3 : float;
  var aMin : float;
  var aMax : float);
local begin
  vMin  : float;
  vMax  : float;
end;
begin
  vMin # 1234567.89;
  vMax # -1234567.89;
  if (aWert1<vMin) and (aWert1<>0.0) then vMin # aWert1;
  if (aWert2<vMin) and (aWert2<>0.0) then vMin # aWert2;
  if (aWert3<vMin) and (aWert3<>0.0) then vMin # aWert3;
  if (aWert1>vMax) and (aWert1<>0.0) then vMax # aWert1;
  if (aWert2>vMax) and (aWert2<>0.0) then vMax # aWert2;
  if (aWert3>vMax) and (aWert3<>0.0) then vMax # aWert3;
  if (vMin<>1234567.89) then aMin # vMin
  else aMin # 0.0;  // 16.01.2017 AH
  if (vMax<>-1234567.89) then aMax # vMax
  else aMax # 0.0;  // 16.01.2017 AH
  
end;


//========================================================================
//  EtkDruckAusTxt
//========================================================================
sub EtkDruckAusTxt(aEtkTxt : int);
local begin
  vA  : alpha;
end;
begin
  if (Set.SQL.SoaYN) then
    Winsleep(500);    // wegen SQL
  FOR vA # TextLineRead(aEtkTxt, 1, _TextLineDelete)
  LOOP vA # TextLineRead(aEtkTxt, 1, _TextLineDelete)
  WHILE (vA<>'') do begin
    if (StrFind(vA,'|',0)>0) then begin   // 2022-06-28 AH optional NEUE Version...
      if (StrCut(vA,1,3)='707') then begin
        RecRead(707,0,_recId, cnvia(Str_token(vA,'|',2)));
        if (BAG.FM.Materialnr<>0) then Mat_Data:Read(BAG.FM.Materialnr);    // 08.10.2018 AH
        Etikettendruck();
      end
      else if (StrCut(vA,1,3)='200') then begin
        RecRead(200,0,_recId, cnvia(Str_token(vA,'|',2)));
        if (Lib_Dokumente:RekReadFrm(200, 'Abbuchungsetikett') <= _rLocked) then begin
          Lib_Dokumente:PrintForm(200,'Abbuchungsetikett',false);
        end;
      end;
    end
    else begin    // 2022-07-11 AH FIX
      RecRead(707,0,_recId, cnvia(vA));
      if (BAG.FM.Materialnr<>0) then Mat_Data:Read(BAG.FM.Materialnr);    // 08.10.2018 AH
      Etikettendruck();
    end;
  END;
end;


//========================================================================
//  sub _FahrenAufRahmenOK(aBagNummer : int; aBagPos : int) : logic
//
//  Prüft ob ein Material, für einen Fahrauftrag eingesetzt werden darf
//========================================================================
sub _FahrenAufRahmenOK(aBagNummer : int; aBagPos : int; aMatSTatus : int) : logic
local begin
  v702 : int;
  vRet : logic;
end
begin
  vRet # true;
  if (aMatSTatus=c_Status_VSBRahmen) OR (aMatSTatus = c_Status_VSBKonsiRahmen) then begin
    v702 # RecBufCreate(702);
    v702->Bag.P.Nummer    # BAG.FM.Nummer;
    v702->BAG.P.Position  # BAG.FM.Position;
    RecRead(v702,1,0);
    if (v702->BAG.P.Aktion = c_BAG_Fahr) AND (v702->BAG.P.ZielVerkaufYN) then
      vRet # false;
  end;

  RETURN vRet;
end;


//========================================================================
//  ErzeugeMatausVSB  +ERR
//========================================================================
sub ErzeugeMatAusVSB() : logic;
local begin
  Erx       : int;
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vMenge    : float;
  vNachBA   : int;
  vNachPos  : int;
  vNachFert : int;
  vNeuFert  : int;
  vNeuInID  : int;
  vNeuOutID : int;
  vOK       : logic;
  vRahmenFahrenOk : logic;
end;
begin DoLogProc;
  
  // ST 2019-05-08: Fahren von auf Rahmenvertrag kommissioniertem Material, nur wenn FAhren kein VK FAhren ist
  vRahmenFahrenOk # _FahrenAufRahmenOK(BAG.FM.Nummer, BAG.FM.Position, Mat.Status);
   
  // Material nochmal auf Status prüfen
  vOK # (Mat.Status<=c_status_bisfrei) or (Mat.Status=c_status_VSB) or (vRahmenFahrenOK) or
      ((Mat.Status>=c_Status_SOnder) and (MAt.Status<=c_Status_bisSonder));
  if (vOK=false) then begin
    Error(010042,AInt(Mat.Nummer)+'|'+AInt(Mat.Status)+'|max.'+AInt(c_status_bisfrei));
    RETURN false;
  end;

  TRANSON;

// Prj 1377/29
  // neue Fertigung anlegen -----------------------------------------------
  BAG.IO.Nummer    # BAG.FM.InputBAG;    // Ursprungs Input holen
  BAG.IO.ID        # BAG.FM.InputID;
  RecRead(701,1,0);
  Erx # RecLink(703,701,10,_recFirsT);  // nach-Fertigung holen
  if (Erx<>_rOk) then begin
    TRANSBRK;
    ErxError(010044,AInt(BAG.FM.InputBAG));
    RETURN false;
  end;

  Erx # RecRead(703,1,_recLock);
  if (Erx=_rOk) then begin
    "BAG.F.Stückzahl"   # "BAG.F.Stückzahl" - Mat.Bestand.Stk;//"Mat.Verfügbar.Stk";
    BAG.F.Gewicht       # BAG.F.Gewicht     - Mat.Bestand.Gew;//"Mat.Verfügbar.Gew";
    if (BAG.IO.MEH.Out='kg') then
      BAG.F.Menge       # BAG.F.Menge       - Mat.Bestand.Gew;//"Mat.Verfügbar.Gew";
    Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
  end;
  if (Erx<>_rOk) then begin     // 2022-07-05 AH DEADLOCK
    TRANSBRK;
    ErxError(010044,AInt(BAG.FM.InputBAG));
    RETURN false;
  end;


  vNeuFert # BAG.F.Fertigung;

  // neuen Inpue anlegen -----------------------------------------------
  BAG.IO.Materialtyp  # c_IO_Mat;
  BAG.IO.Materialnr   # Ein.E.Materialnr;

  // Feldübernahme
  BAG.IO.Materialnr     # Mat.Nummer;
  BAG.IO.Dicke          # Mat.Dicke;
  BAG.IO.Breite         # Mat.Breite;
  BAG.IO.Spulbreite     # Mat.Spulbreite;
  "BAG.IO.Länge"        # "Mat.Länge";
  BAG.IO.Dickentol      # Mat.Dickentol;
  BAG.IO.Breitentol     # Mat.Breitentol;
  "BAG.IO.Längentol"    # "Mat.Längentol";
  BAG.IO.AusfOben       # "Mat.AusführungOben";
  BAG.IO.AusfUnten      # "Mat.AusführungUnten";
  "BAG.IO.Güte"         # "Mat.Güte";
  "BAG.IO.Gütenstufe"   # "Mat.Gütenstufe";

  BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;//"Mat.Verfügbar.Stk";
  BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;//"Mat.Verfügbar.Gew";;
  BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;//"Mat.Verfügbar.Gew";;
  if (BAG.IO.MEH.Out='qm') then begin
    "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
    BAG.IO.Plan.In.Menge  # cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0;
    "BAG.IO.Länge"        # "Mat.Länge";
  end
  else begin
    BAG.IO.Plan.In.Menge # BAG.IO.Plan.In.GewN;
  end;
  BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;

  BAG.IO.Warengruppe    # Mat.Warengruppe;
  BAG.IO.Lageradresse   # Mat.Lageradresse;
  BAG.IO.Lageranschr    # Mat.Lageranschrift;

  vStk    # BAG.IO.Plan.Out.Stk;
  vGewN   # BAG.IO.Plan.Out.GewN;
  vGewB   # BAG.IO.Plan.Out.GewB;
  vMenge  # BAG.IO.Plan.Out.Meng;

  BAG.IO.NachFertigung  # vNeuFert;

  // ID vergeben
  WHILE (RecRead(701,1,_recTest)<=_rLocked) do
    BAG.IO.ID # BAG.IO.ID + 1;

  BAG.IO.UrsprungsID    # BAG.IO.ID;
  BAG.IO.Anlage.Datum   # Today;
  BAG.IO.Anlage.Zeit    # Now;
  BAG.IO.Anlage.User    # gUserName;

  if (BA1_Mat_Data:MatEinsetzen()=false) then begin
    TRANSBRK;
    Error(701021,'');         // ST 2009-02-02
    RETURN false;
  end;
  Erx # BA1_IO_Data:Insert(0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Error(701017,'');         // ST 2009-02-02
    RETURN false;
  end;
  vNeuInID  # BAG.IO.ID;


  // Output aktualisieren
  // 24.05.2019 AH: kgmm ignorieren:
  if (BA1_F_Data:UpdateOutput(701,n,n, true)=false) then begin
    TRANSBRK;
    Error(701018,'');         // ST 2009-02-02
    ERROROUTPUT;  // 01.07.2019
    RETURN false;
  end;

  // alten Input verändern ---------------------------------------------

  // Ursprungs Input holen
  BAG.IO.Nummer    # BAG.FM.InputBAG;
  BAG.IO.ID        # BAG.FM.InputID;
  RecRead(701,1,0);
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.Out.Stk - vStk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.PLan.Out.GewN - vGewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.PLan.Out.GewB - vGewB;
  BAG.IO.Plan.Out.Meng  # BAG.IO.PLan.Out.Meng - vMenge;

  // VSB-Material auf diesen Einsatz hin anpassen
  if (BA1_Mat_Data:VSBFreigeben()=false) then begin
    TRANSBRK;
    Error(701019,AInt(BAG.IO.Materialnr));   // ST 2009-02-02
    RETURN false;
  end;

  if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
    TRANSBRK;
    Error(701020,AInt(BAG.IO.Materialnr));   // ST 2009-02-02
    RETURN false;
  end;
  Erx # RecRead(701,1,_recsingleLock | _RecNoLoad);
  if (Erx=_rOK) then begin
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  end;
  if (Erx<>_rOk) then begin
    TRANSBRK;
    Error(701022,AInt(BAG.IO.ID));           // ST 2009-02-02
    RETURN false;
  end;

  // Output erzeugen
  // 24.05.2019 AH: kgmm ignorieren:
  if (BA1_F_Data:UpdateOutput(701,n,n,true)=false) then begin
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    RETURN false;
  end;

  Erx # RecLink(701,702,3,_recFirst);   // Output loopen
  WHILE (erx<_rLocked) do begin
    if (BAG.IO.VonID=vNeuInID) then begin
      vNeuOutID # BAG.IO.ID;
    end;
    if (BAG.IO.VonID=BAG.FM.InputID) then begin
//debug('von id:'+aint(bag.io.id)+'  '+aint(bag.io.nachbag));
      vNachBA   # BAG.IO.NachBAG;
      vNachPos  # BAG.IO.NachPosition;
      vNachFert # BAG.IO.NachFertigung;
    end;
    Erx # RecLink(701,702,3,_recNext);
  END;

  if (vNachBA<>0) and (vNeuOutID<>0) then begin
    BAG.IO.ID # vNeuOutID;

    Erx # RecRead(701,1,_recSingleLock);
    if (Erx<>_rOK) then begin
      TRANSBRK;
      ERROROUTPUT;
      RETURN false;
    end;
//debug('verbiege id:'+aint(bag.io.id));
    BAG.IO.NachBAG        # vNachBA;
    BAG.IO.NachPosition   # vNachPos;
    BAG.IO.NachFertigung  # vNachFert;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');

    BAG.IO.ID # vNeuInID;   // auf neuen Einsatz restoren
    RecRead(701,1,0);
    // Output updaten
    // 24.05.2019 AH: kgmm ignorieren:
    if (BA1_F_Data:UpdateOutput(701,n, n, true)=false) then begin
      TRANSBRK;
      ERROROUTPUT;  // 01.07.2019
      RETURN false;
    end;

  end;

 
  TRANSOFF;

  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);
  // alle Fertigungen neu errechnen
  BA1_P_Data:ErrechnePlanmengen();

  BAG.FM.InputID  # vNeuInID;
  BAG.FM.OutputID # vNeuOutID;

  RETURN true;

end;


//========================================================================
//  ErzeugeMatausVSB_genau1  +ERR
//
//========================================================================
sub ErzeugeMatAusVSB_genau1() : logic;
local begin
  Erx       : int;
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vMenge    : float;
  vNachBA   : int;
  vNachPos  : int;
  vNachFert : int;
  vNeuFert  : int;
  vNeuInID  : int;
  vNeuOutID : int;
  vOK       : logic;
  vWEMat    : int;
  vVSBMat   : int;
  vRahmenFahrenOk : logic;
end;
begin DoLogProc;
  
  // ST 2019-05-08: Fahren von auf Rahmenvertrag kommissioniertem Material, nur wenn FAhren kein VK FAhren ist
  vRahmenFahrenOk # _FahrenAufRahmenOK(BAG.FM.Nummer, BAG.FM.Position, Mat.Status);

  // Material nochmal auf Status prüfen
  vOK # (Mat.Status<=c_status_bisfrei) or (Mat.Status=c_status_VSB) or (vRahmenFahrenOk) or
      ((Mat.Status>=c_Status_SOnder) and (MAt.Status<=c_Status_bisSonder));
  if (vOK=false) then begin
    Error(010042,AInt(Mat.Nummer)+'|'+AInt(Mat.Status)+'|max.'+AInt(c_status_bisfrei));
    RETURN false;
  end;

  TRANSON;

  vWEMat  # Mat.Nummer;
  vVSBMat # BAG.IO.Materialnr;
  MAt.Nummer # vVSBMat;
  RecRead(200,1,0);

  // VSB-Material freigeben...
  if (BA1_Mat_Data:VSBFreigeben()=false) then begin
    TRANSBRK;
    Error(701019,AInt(BAG.IO.Materialnr));
    RETURN false;
  end;

  Mat.Nummer # vWEMat;
  RecRead(200,1,0);

  // Input anpassen von VSB auf echtes Material...
  Erx # RecRead(701,1,_recSingleLock);
  if (Erx<>_rOK) then begin
    TRANSBRK;
    ERror(701018,'');
    ERROROUTPUT;
    RETURN false;
  end;
  BAG.IO.Materialtyp    # c_IO_Mat;
  BAG.IO.Materialnr     # Mat.Nummer;
  BAG.IO.MaterialRstNr  # Mat.Nummer;
  BAG.IO.Dicke          # Mat.Dicke;
  BAG.IO.Breite         # Mat.Breite;
  BAG.IO.Spulbreite     # Mat.Spulbreite;
  "BAG.IO.Länge"        # "Mat.Länge";
  BAG.IO.Dickentol      # Mat.Dickentol;
  BAG.IO.Breitentol     # Mat.Breitentol;
  "BAG.IO.Längentol"    # "Mat.Längentol";
  BAG.IO.AusfOben       # "Mat.AusführungOben";
  BAG.IO.AusfUnten      # "Mat.AusführungUnten";
  "BAG.IO.Güte"         # "Mat.Güte";
  "BAG.IO.Gütenstufe"   # "Mat.Gütenstufe";
  BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
  BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
  BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;

  BAG.IO.Plan.Out.Stk    # Mat.Bestand.Stk;
  BAG.IO.Plan.Out.GewN   # Mat.Gewicht.Netto;
  BAG.IO.Plan.Out.GewB   # Mat.Gewicht.Brutto;

  if (BAG.IO.MEH.Out='qm') then begin
    "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
    BAG.IO.Plan.In.Menge  # cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0;
    "BAG.IO.Länge"        # "Mat.Länge";
  end
  else begin
    BAG.IO.Plan.In.Menge # BAG.IO.Plan.In.GewN;
  end;
  BAG.IO.Plan.Out.Meng # BAG.IO.Plan.In.Menge;
  RekReplace(701,_RecUnlock,'AUTO');

  if (BA1_Mat_Data:MatEinsetzen()=false) then begin
    TRANSBRK;
    Error(701021,'');         // ST 2009-02-02
    RETURN false;
  end;

  // Output aktualisieren
  // 24.05.2019 AH: kgmm ignorieren:
  if (BA1_F_Data:UpdateOutput(701,n, n, true)=false) then begin
    TRANSBRK;
    Error(701018,'');         // ST 2009-02-02
    ERROROUTPUT;  // 01.07.2019
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;

end;


//========================================================================
//  FertigAbfrage
//
//========================================================================
sub FertigAbfrage(
  aBAG            : int;
  aPos            : int;
  aFert           : int;

  aInputBAG       : int;
  aInputID        : int;
  aBruderID       : int;
  opt aInputList    : handle;
  opt aPerTabelle   : logic;
  opt aPerKombiTab  : logic;
);
local begin
  Erx   : int;
  vTmp  : int;
  vEdit : logic;
  vName : alpha;
end;
begin
 
  // AFX
  if (RunAFX('BAG.FM.FertigAbfrage',aint(aBAG)+'|'+aint(aPos)+'|'+aint(aFert)+'|'+aint(aInputBAG)+'|'+aint(aInputID)+'|'+aint(aBruderID)+'|'+aint(aInputList))<>0) then RETURN;

  // BA holen
  BAG.Nummer # aBAG;
  RecRead(700,1,0);

  // Input holen (ArtPrd NICHT!)
  if (aInputID<>0) then begin
    BAG.IO.Nummer   # aInputBAG;
    BAG.IO.ID       # aInputID;
    RecRead(701,1,0);
    if (BAG.IO.MaterialTyp=c_IO_Mat) or (BAG.IO.MaterialTyp=c_IO_VSB) then begin
      Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
      if (erx>_rLocked) then RecBufClear(200);

      // 23.02.2017 AH Sicherheitsprüfung, falls Rest nicht vom Einsatz sein sollte??
      if ("Mat.Vorgänger"<>BAG.IO.Materialnr) and (BAG.IO.Materialnr<>BAG.IO.MaterialRstNr) then begin
        RecBufClear(200);
        Msg(99,'Restkarte stammt nicht vom Einsatz!! VERKNÜPFUNGSFEHLER!',0,0,0);
        RETURN;
      end;

    end;
  end
  else begin
    RecbufClear(701);
  end;

  // Pos holen
  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  RecRead(702,1,0);
  if (BAG.P.Aktion=c_BAG_MatPrd) or (BAG.P.Aktion=c_BAG_Spulen) or (BAG.P.Aktion=c_BAG_WalzSpulen) or
    (BAG.P.Aktion=c_BAG_SpaltSpulen) or (BAG.P.Aktion=c_BAG_Paket) or (BAG.P.Aktion=c_BAG_Messen) then begin
    RecBufClear(701);
    RecBufClear(200);
  end;


  // Fertigung holen
  BAG.F.Nummer    # aBAG;
  BAG.F.Position  # aPos;
  BAG.F.Fertigung # aFert;
  RecRead(703,1,0);

  // NICHT bei ArtPrd
  if (BAG.IO.ID<>0) then begin
    // Einsatz + Fertigung zusammenführen
    if (BAG.F.Dicke=0.0) then           BAG.F.Dicke         # BAG.IO.Dicke;
    if (BAG.F.Dickentol='') then        BAG.F.Dickentol     # BAG.IO.Dickentol;
    if (BAG.P.Aktion<>c_BAG_Tafel) or (BAG.F.AutomatischYN) then begin   // 24.05.2022 AH : Tafeldaten immer übertragen
      if (BAG.F.Breite=0.0) then          BAG.F.Breite        # BAG.IO.Breite;
      if (BAG.F.Breitentol='') then       BAG.F.Breitentol    # BAG.IO.Breitentol;
      if ("BAG.F.Länge"=0.0) then         "BAG.F.Länge"       # "BAG.IO.Länge";
      if ("BAG.F.Längentol"='') then      "BAG.F.LÄngentol"   # "BAG.IO.Längentol";
    end;
    if ("BAG.F.Güte"='') then           "BAG.F.Güte"        # "BAG.IO.Güte";
    if ("BAG.F.GütenStufe"='') then     "BAG.F.GütenStufe"  # "BAG.IO.GütenStufe";
    if (BAG.F.AusfOben='') then         BAG.F.AusfOben      # BAG.IO.AusfOben;
    if (BAG.F.AusfUnten='') then        BAG.F.AusfUnten     # BAG.IO.AusfUnten;
    if (BAG.F.Warengruppe=0) then       BAG.F.Warengruppe   # BAG.IO.Warengruppe;
    if (BAG.F.Artikelnummer='') then    BAG.F.Artikelnummer # BAG.IO.Artikelnr;
  end;

  // Output holen
  BAG.IO.Nummer   # aInputBAG;
  BAG.IO.ID       # aBruderID;
  RecRead(701,1,0);

  // Verpackung holen
  Erx # RecLink(704,703,6,_recfirst);
  if (Erx>_rLockeD) then RecBufClear(704);

  if (BAG.P.Aktion<>c_BAG_ArtPrd) and (BAG.P.Aktion<>c_BAG_MatPrd) and (BAG.P.Aktion<>c_BAG_SpaltSpulen) and (BAG.P.Aktion<>c_BAG_WalzSpulen) then begin
    "BAG.F.Stückzahl" # BAG.IO.Plan.In.Stk;
    BAG.F.Gewicht     # BAG.IO.Plan.In.GewN;
    BAG.F.Menge       # BAG.IO.Plan.In.Menge;
    "BAG.F.Fertig.Stk"  # BAG.IO.Ist.In.Stk;
    BAG.F.Fertig.Gew    # BAG.IO.Ist.In.GewN;
    BAG.F.Fertig.Menge  # BAG.IO.Ist.In.Menge;
  end;

  // Input holen
  BAG.IO.Nummer   # aInputBAG;
  BAG.IO.ID       # aInputID;
  RecRead(701,1,0);


  // Maske anzeigen
  // 04.01.2022 AH
  if (RunAFX('BAG.FM.GetMaskenName',abool(aPerTabelle))<>0) then vName # Gv.Alpha.01;
  
  if (vName='') and (aPerTabelle) then begin
    vName # 'BA1.FM.List';
  end
  else if (vName='') and (aPerKombiTab) then begin
    vName # 'BA1.FM.Kombi.List';    // 2023-02-09 AH
  end;

  if (vName='') then begin
    if (BAG.P.Aktion=c_BAG_Check) then begin
      if (Set.Installname='LZM') then begin
        Call('SFX_BA1FMQS_Main:START.MASKE','');
        RETURN;
      end
    end;
    if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
        vName # 'BA1.FM.ArtPrd.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_MatPrd) then begin
      aInputList # CteOpen(_CteTree);
      aInputBAG # aBAG;
      vName # 'BA1.FM.MatPrd.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_Bereit) then begin
      vName # 'BA1.FM.Bereit.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_SpaltSpulen) or (BAG.P.Aktion=c_BAG_WalzSpulen) then begin
      vName # 'BA1.FM.SpSpulen.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_Spulen) then begin
      vName # 'BA1.FM.Spulen.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_Paket) then begin
      vName # 'BA1.FM.Paket.Maske';
    end
    else if (BAG.P.Aktion=c_BAG_Messen) then begin
      vName # 'BA1.FM.Messen.Maske';
      vEdit # true;
    end
    else begin
      // Bei Betriebsusern ggf. spezielle Maske Anzeigen
      if (gUserGroup= 'BETRIEB_TS') OR (gUserGroup = 'BETRIEB') then begin
        vName #'BA1.FM.Maske_Betrieb';
      end
      else begin
        vName # 'BA1.FM.Maske';
      end;
    end;
  end;  // STD-Maske

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, vName,here+':AusMaske',y,y);

  Lib_guiCom:ObjSetPos(gMdi,10,0);

  // direkt zur Neuanlage einer FM
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  Mode # c_modeView;
  if (aInputList<>0) then begin
    vTmp # Winsearch(gMDI,'hdl.Inputlist');
    vTmp->wpcustom # AInt(aInputList);
  end;

  if (vEdit) then begin
    App_Main:Action(c_ModeEdit);
  end
  else begin
    App_Main:Action(c_ModeNew); // hiermit auch Vorbelegen

    // weitere Vorbelegungen ************************************************************
    BAG.F.Nummer        # aBAG;
    BAG.FM.Nummer       # myTmpNummer;

    BAG.FM.Position     # aPos;
    BAG.FM.Fertigung    # aFert;

    BAG.FM.InputBAG     # aInputBAG;
    BAG.FM.InputID      # aInputID;
    BAG.FM.Werksnummer  # Mat.Werksnummer;

    BAG.FM.BruderID   # aBruderID

    BAG.FM.Verwiegungart # BAG.Vpg.Verwiegart;

    BAG.FM.Fertigmeldung # 999; // Temporäre Nummer
    
    if (BAG.P.Aktion=c_BAG_Bereit) then begin
      "BAG.FM.Stück"        # BAG.IO.Plan.Out.Stk;
      BAG.FM.Gewicht.Brutt  # BAG.IO.Plan.Out.GewB;
      BAG.FM.Gewicht.Netto  # BAG.IO.Plan.Out.GewN;
// 2022-12-20 AH    BAG.FM.Menge          # Bag.FM.Gewicht.Netto;
      if (BAG.FM.MEH=BAG.IO.MEH.Out) then   // 2023-05-04 AH
        BAG.FM.Menge # BAG.IO.Plan.Out.Meng
      else if (BAG.FM.MEH='qm') then
        BAG.FM.Menge # BAG.FM.Breite * Cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" / 1000000.0
      else if (BAG.FM.MEH='Stk') then
        BAG.FM.Menge # cnvfi("BAG.FM.Stück")
      else if (BAG.FM.MEH='kg') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto
      else if (BAG.FM.MEH='t') then
        BAG.FM.Menge # Bag.FM.Gewicht.Netto / 1000.0
      else if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
        BAG.FM.Menge # cnvfi("BAG.FM.Stück") * "BAG.FM.Länge" / 1000.0;
      $edTara->wpcaptionfloat # BAG.FM.Gewicht.Brutt - BAG.FM.Gewicht.Netto;
    end;
  end;
  
  Lib_GuiCom:RunChildWindow(gMDI,gFrmMain,_WinAddHidden);

  gMdi->WinUpdate(_WinUpdOn);

end;


//========================================================================
//  AusMaske
//
//========================================================================
sub AusMaske();
local begin
  vCancel   : logic;
  vUserGrp  : alpha;
end;
begin
   ERROROUTPUT;    // 2023-02-09 AH

  vCancel # (gSelected<>1);
  // Zugriffliste wieder aktivieren
//  $ZL.BA1->wpdisabled # false;
  // gesamtes Fenster aktivieren
//  Lib_GuiCom:SetWindowState($BAG.Verwaltung,true);
  gSelected # 0;
//  mode # c_ModeList;
//  App_Main:Refreshmode();

  vUserGrp # gUsergroup;
  // Focus setzen:

  if (BAG.P.Aktion=c_BAG_Messen) then vCancel # false;

/*
  if (vUserGrp <> 'BETRIEB') AND (vUserGrp <> 'BETRIEB_TS') then
    $ZL.BA1->Winfocusset(false);
*/

  RecBufClear(707);
  BAG.FM.Nummer   # BAG.Nummer;
  BAG.FM.Position # BAG.P.Position;

  if (gBagFmBackProc<>'') then Call(gBagFmBackProc);

  RecRead(702,1,0);
  if ("Bag.P.Löschmarker" = '') and (vCancel=false) then begin
    if (BAG.P.Aktion=c_BAG_ArtPrd) or (BAG.P.Aktion=c_BAG_MatPrd) then begin
      if (Msg(99,'Noch mal?',_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdno) then begin
        ErrorOutput;
        RETURN;
      end;
    end;

    // WEITER FERTIG MELDEN...
    FMKopf(gBagFmBackProc);
  end;

  ErrorOutput;
end;


//========================================================================
//  AusWE
//
//========================================================================
sub AusWE();
local begin
  vStk      : int;
  vGewN     : float;
  vGewB     : float;
  vMenge    : float;
  vNachBA   : int;
  vNachPos  : int;
  vNachFert : int;
  vNeuFert  : int;
  vNeuInID  : int;
  vNeuOutID : int;
  vOK       : logic;
end;
begin

  if (gSelected<>0) then begin

    // neuen WE holen
    RecRead(506,0,_RecId,gSelected);
    gSelected # 0;

    // BA holen
    BAG.Nummer      # BAG.FM.Nummer;
    RecRead(700,1,0);

    // BA-Position holen
    BAG.P.Nummer    # BAG.FM.Nummer;
    BAG.P.Position  # BAG.FM.Position;
    RecRead(702,1,0);

    RecLink(200,506,8,_recFirst);   // Material holen

//    if (Msg(99,'genau 1?',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdyes) then
//      vOK # ErzeugeMatAusVSB_genau1()
//    else
      vOK # ErzeugeMatAusVSB();

    if (vOK=false) then begin
      ErrorOutput;
      RETURN;
    end;
    FMKopf(gBagFmBackProc);
    ErrorOutput;
  end;

//  mode # c_ModeList;
//  App_Main:Refreshmode();

  // Focus setzen:
  $ZL.BA1->Winfocusset(false);
end;


//========================================================================
//  ChoosePos
//
//========================================================================
sub ChoosePos(opt aAlleAnzeigen : logic) : int;
local begin
  vHdl  : int;
  vTmp  : int;
  v707  : int;
end;
begin
  v707 # RekSave(707);
  vHdl # WinOpen('BA1.P.Auswahl',_WinOpenDialog);

  if (aAlleAnzeigen) then begin
    vTmp # Winsearch(vHdl, 'ZL.BAG.P.Auswahl');
    if (vTmp>0) then begin
      WinEvtProcNameSet(vTmp, _WinEvtLstRecControl, '');
    end;
  end;

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.Nummer)+' '+BAG.Bemerkung;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Arbeitsgang wählen:');

  vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  RekRestore(v707);

  WinClose(vHdl);
  if (gSelected=0) then RETURN 0;
  RecRead(702,0,_RecId,gSelected);
  gSelected # 0;

  RETURN BAG.P.Position;
end;


//========================================================================
//  ChooseInput
//
//========================================================================
sub ChooseInput()
  : int;    // _winidok, _winidcancel, -8=Tabelle 2023-02-08  AH
local begin
  Erx     : int;
  vHdl    : int;
  vHdl2   : int;
  vA      : alpha;
  v707    : int;
  vTmp    : int;
  vRes    : int;
end;
begin

  if (RunAFX('BAG.FM.ChooseInput','')<>0) then begin
    if (AfxRes=_rOK) then RETURN _Winidok;
    if (AfxRes=_rLocked) then RETURN _Winidcancel;
  end;
//  if (Set.Installname='LZM') then begin
//    RETURN Call('SFX_BA1FMQS_Main:ChooseInput');
//  end;

  
  REPEAT
    vHdl # WinOpen(Lib_Guicom:GetAlternativeName('BA1.FM.I.Auswahl'),_WinOpenDialog);
    $ZL.BAG.IO.Auswahl_IN->wpDbKeyNo # 2;  // auf Input linken

    vTmp # Winsearch(vHdl,'LB.Info1');
    vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;
    vTmp # Winsearch(vHdl,'LB.Info3');
    vTmp->wpcaption # Translate('Einsatz wählen:');
    v707 # RekSave(707);
    vRes # vHdl->WinDialogRun(_WinDialogCenter,gMDI);
    if (vRes=-8) then begin   // 2023-03-13 AH
      WinClose(vHdl);
      RETURN -8;
    end;
    if (vRes<>-8) then vRes # _winidok; // 2023-02-09 AH
    WinClose(vHdl);

    RekRestore(v707);

    if (gSelected=0) then RETURN _Winidcancel;
    RecRead(701,0,_RecId,gSelected);
    gSelected # 0;

    // Weiterbearbeitung?
    if (BAG.IO.VonFertigMeld<>0) then begin
      v707 # RecBufCreate(707);
      Erx # RecLink(v707,701,18,_recFirst);
      if (erx<=_rLocked) and (v707->BAG.FM.Status<>1) then begin
        RecBufDestroy(v707);
        Msg(701025,'',0,0,0);
        CYCLE;
      end;
      RecBufDestroy(v707);
    end;

    // Rest prüfen
    if (BAG.P.Aktion<>c_BAG_Check) then begin // 04.12.2020
      if (BAG.IO.Plan.IN.GewN - BAG.IO.Ist.Out.GewN<=1.0) then begin
        if (Msg(701016, ANum(BAG.IO.Plan.IN.GewN - BAG.IO.Ist.Out.GewN,-1)+' kg',_WinIcoQuestion ,_WinDialogYesNo, 2)<>_WinIdYes) then RETURN _Winidcancel;
      end;
    end;

    // VSB-Material?
    if (BAG.IO.Materialtyp=c_IO_VSB) then begin
      Msg(701034,'',_WinIcoError,_WinDialogok,1);
      RETURN _WinidCancel;
    end;

    if (BAG.IO.Materialtyp<>c_IO_Mat) then begin
      Msg(701008,'',0,0,0);
      CYCLE;
    end;

  UNTIL (1=1);

  BAG.FM.InputBAG # BAG.IO.Nummer;
  BAG.FM.InputID  # BAG.IO.ID
  RETURN vRes;
end;


//========================================================================
//  ChooseMultiInput
//
//========================================================================
sub ChooseMultiInput(
  aInputList : handle;
) : logic;
local begin
  Erx   : int;
  vHdl  : int;
  vHdl2 : int;
  vA    : alpha;
  vGewN : float;
  vGewB : float;
  vStk  : int;
  vI    : int;
  vID   : int;
  vItem : handle;
  vJ    : int;
  vTmp  : int;
end;
begin

  if (RunAFX('BAG.FM.ChooseMultiInput',aint(aInputList))<>0) then RETURN AfxRes=_rOK;

  vHdl # WinOpen(Lib_guicom:GetAlternativename('BA1.FM.I.Spulen'),_WinOpenDialog);
  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;

  // Dataliste füllen ------------------------------
  begin
    vHdl2 # vHdl->WinSearch('dl.Input');
    vTmp # Winsearch(vHdl2, 'clm.Dicke');
    vTmp->wpFmtPostComma # Set.Stellen.Dicke;
    vTmp # Winsearch(vHdl2, 'clm.Breite');
    vTmp->wpFmtPostComma # Set.Stellen.Breite;
    vTmp # Winsearch(vHdl2, 'clm.Gewicht');
    vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
    vTmp # Winsearch(vHdl2, 'clm.Gewicht.Rest');
    vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
    vTmp # Winsearch(vHdl2, 'clm.Gewicht.Einsatz');
    vTmp->wpFmtPostComma # Set.Stellen.Gewicht;
    vTmp # Winsearch(vHdl2, 'clm.Menge');
    vTmp->wpFmtPostComma # Set.Stellen.Menge;
    vTmp # Winsearch(vHdl2, 'clm.Menge.Rest');
    vTmp->wpFmtPostComma # Set.Stellen.Menge;
    FOR ERx # RecLink(701,702,2,_RecFirst)
    LOOP ERx # RecLink(701,702,2,_RecNext)
    WHILE (erx<=_rLocked) do begin
      if (BAG.IO.Materialnr<>0) and (BAG.IO.Materialtyp=c_IO_Mat) then begin
        if (BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk<=0) then CYCLE;  // 22.04.2021 AH: Ohne Stückzahl überspringen
        vHdl2->WinLstDatLineAdd(BAG.IO.ID);
        vHdl2->WinLstCellSet(BAG.IO.Materialnr, 2,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Dicke, 3,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Breite, 4,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet("BAG.IO.Güte", 5,  _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.Stk, 6, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.GewB, 7, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(ANum(BAG.IO.Plan.Out.Meng, Set.Stellen.Menge)+' '+BAG.IO.MEH.Out, 8, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk, 9, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB,10, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(ANum(BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge, Set.Stellen.Menge)+' '+BAG.IO.MEH.Out,11, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(0,12, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(0.0,13, _WinLstDatLineLast);
        vHdl2->WinLstCellSet(0.0,14, _WinLstDatLineLast);
        //vGewB # vGewB + BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB;
        //vM # vM + BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge;
      end;
    END;
    //vHdl->WinLstDatLineAdd('Artikelnummer');
    vHdl2->wpcurrentint # 1;
    //RecBufClear(701);
    //BAG.IO.Plan.Out.GewB  # vGewB;
    //BAG.IO.Plan.Out.Meng  # vM;
  end // Dataliste füllen

  ERx # vHdl->WinDialogRun(_WinDialogCenter,gMDI);

  FOR vI # 1 loop inc(vI) while (vI<=WinLstDatLineInfo(vHdl2, _WinLstDatInfoCount)) do begin
    vHdl2->WinLstCellGet(vID,   1, vI);
    vHdl2->WinLstCellGet(vStk,  12, vI);
    vHdl2->WinLstCellGet(vGewN,  13, vI);
    vHdl2->WinLstCellGet(vGewB,  14, vI);
    if (vStk<>0) then begin
      Inc(vJ);
      vItem # CteOpen(_CteItem);
      vItem->spname   # Aint(vID);
      vItem->spcustom # AInt(vStk)+'|'+ANum(vGewN, Set.Stellen.Gewicht)+'|'+ANum(vGewB, Set.Stellen.Gewicht);
      aInputList->CteInsert(vItem);
    end;
  END;

  WinClose(vHdl);
  if (ERx<>_WinIDOK) then RETURN false;

  if (vJ=0) then RETURN false;

  BAG.FM.InputBAG # BAG.IO.Nummer;

  BAG.FM.InputID  # BAG.IO.ID
  RETURN true;
end;


//========================================================================
//  ChooseOutput
//
//========================================================================
sub ChooseOutput() : int;
local begin
  Erx   : int;
  vHdl  : int;
  vText : alpha(200);
  vTmp  : int;
  v707  : int;
  vDL   : int;
  vRes  : int;
end;
begin

  // bei Prüfen keine Fertigungsauswahl!
  if (BAG.P.Aktion=c_BAG_Check) or (BAG.P.Aktion=c_BAG_Paket) then begin
    Erx # RecLink(701,702,18,_RecFirsT);  // Output holen
    if (erx>_rLocked) then RETURN _winIdCancel;
    BAG.FM.OutputID   # BAG.IO.ID;
    BAG.FM.Fertigung  # BAG.IO.VonFertigung;
    RETURN _winIdOK;
  end;


  vHdl # WinOpen(Lib_GuiCom:GetAlternativeName('BA1.FM.O.Auswahl'),_WinOpenDialog);

//  if ("BAG.P.Typ.1In-1OutYN") then begin
  vDL # Winsearch(vHdl,'ZL.BAG.IO.Auswahl');

  Lib_GuiCom:RecallList(vDL);     // Usersettings holen
  
  if ("BAG.P.Typ.1In-1OutYN") or ("BAG.P.Typ.1In-yOutYN") then
    vDL->wpcustom # AInt(BAG.FM.InputID);
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.InputID;
  Erx # RecRead(701,1,0);
  if (erx<=_rLocked) then begin
    if (BAG.IO.BruderID<>0) then
      vDL->wpcustom # AInt(BAG.IO.BruderID);
  end
  else begin
    RecBufClear(701); // 17.05.2022 AH
  end;

//  end;

  vTmp # Winsearch(vHdl,'LB.Info1');
  vTmp->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;
  vTmp # Winsearch(vHdl,'LB.Info2');
  if (BAG.IO.Materialtyp=c_IO_Mat) then begin
    vText # Translate('Einsatz:')+' '+Translate('Mat.')+AInt(BAG.IO.Materialnr)+' '+ANum(BAG.IO.Dicke,Set.Stellen.Dicke);
    if (BAG.IO.Breite<>0.0) or ("BAG.IO.Länge"<>0.0) then
      vText # vText + ' x '+ANum(BAG.IO.Breite,Set.Stellen.Breite);
    if ("BAG.IO.Länge"<>0.0) then
      vText # vText + ' x '+ANum("BAG.IO.Länge","Set.Stellen.Länge");
    vText # vText + '   '+ANum(BAG.IO.Plan.Out.Meng,"Set.Stellen.Menge")+BAG.IO.MEH.Out;
    vTmp->wpcaption # vText;
  end;
  vTmp # Winsearch(vHdl,'LB.Info3');
  vTmp->wpcaption # Translate('Fertigung wählen:');
  v707 # RekSave(707);    // 13.10.2017
  vRes # vHdl->WinDialogRun(_WinDialogCenter,gMDI);
  if (vRes<>-8) then vRes # _winidok; // 2022-10-20 AH NICHT Tabelle?
  
  Lib_GuiCom:RememberList(vDL);     // Usersettings holen

  WinClose(vHdl);
  RekRestore(v707);
  if (gSelected=0) then RETURN _winIdCancel;
  RecRead(701,0,_RecId,gSelected);
  gSelected # 0;

  if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
    Msg(701009,'',0,0,0);
    RETURN _winIdCancel;
  end;

  if (BAG.P.Aktion<>c_BAG_SpaltSpulen) and (BAG.P.Aktion<>c_BAG_WalzSpulen) then begin
    // 06.03.2014 AH
    if (BAG.IO.Plan.In.Stk<=BAG.IO.Ist.In.Stk) and
      ((BAG.F.Fertigung<>999) or (BAG.IO.Plan.In.Stk<>0)) then begin
      Erx # Msg(701015,'',_WinIcoQuestion, _WinDialogYesNo, 2);
      if (Erx<>_WinIdYes) then RETURN _winIdCancel;
    end;
  end;

  BAG.FM.OutputID   # BAG.IO.ID;
  BAG.FM.Fertigung  # BAG.IO.VonFertigung;

  RETURN vRes;
end;


//========================================================================
//  AufVSBAktion
//              echtes fertiges Material dem Auftrag melden
//========================================================================
sub AufVSBAktion(
  aDatum  : date) : logic;
local begin
  Erx     : int;
  vBuf702 : int;
  vSLNr   : int;
end;
begin

  vBuf702 # ReKSave(702);
  Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf702);
    RETURN true;
//    RETURN false;
  end;
  Auf.P.Nummer    # BAG.P.Auftragsnr;   // Kundenauftrag holen
  Auf.P.Position  # BAG.P.Auftragspos;
  Erx # RecRead(401,1,0);
  vSLNr # BAG.P.Auftragspos2;

  RekRestore(vBuf702);
  if (Erx>_rLocked) then RETURN false;

  if (vSLNr<>0) then begin
    Auf.SL.Nummer   # Auf.P.Nummer;
    Auf.SL.Position # Auf.P.Position;
    Auf.SL.LfdNr    # vSLnr;
    Erx # RecRead(409,1,0);
    if (Erx>_rLocked) then RETURN false;
  end;

  RecBufClear(404);

  Auf.A.Nummer        # BAG.P.Auftragsnr;
  Auf.A.Position      # BAG.P.Auftragspos;
  Auf.A.Aktionstyp    # c_Akt_BA_Fertig;
  Auf.A.Aktionsnr     # BAG.FM.Nummer;
  Auf.A.Aktionspos    # BAG.FM.Position;
  Auf.A.Aktionspos2   # BAG.FM.Fertigung;
  Auf.A.Aktionsdatum  # aDatum;
  Auf.A.TerminStart   # aDatum;
  Auf.A.TerminEnde    # aDatum;
  Auf.A.Bemerkung     # c_AktBem_BA_Fertig+' '+BAG.P.Aktion2;
  
  Auf.A.Materialnr    # BAG.FM.Materialnr;

  if (Wgr_Data:IstMix(Auf.P.Wgr.Dateinr)) then
    Auf.A.ArtikelNr # BAG.FM.Artikelnr;


  Auf.A.Dicke         # Mat.Dicke;
  Auf.A.Breite        # Mat.Breite;
  "Auf.A.Länge"       # "Mat.Länge";
  Auf.A.MEH           # Auf.P.MEH.Einsatz;
  Auf.A.MEH.Preis     # Auf.P.MEH.Preis;

  "Auf.A.Stückzahl"   # "BAG.FM.Stück";
  Auf.A.Gewicht       # BAG.FM.Gewicht.Brutt;
  Auf.A.Nettogewicht  # BAG.FM.Gewicht.Netto;

  // 16.12.2014:
  if (Auf.A.MEH=Mat.MEH) then
    Auf.A.Menge       # Mat.Bestand.Menge
  else if (Auf.A.MEH=BAG.FM.MEH) then
    Auf.A.Menge       # BAG.FM.Menge
  else if (Auf.A.MEH='kg') then
    Auf.A.Menge       # Auf.A.Gewicht
  else if (Auf.A.MEH='t') then
    Auf.A.Menge       # Auf.A.Gewicht / 1000.0
  else if (Auf.A.MEH='Stk') then
    Auf.A.Menge       # Cnvfi("Auf.A.Stückzahl");

// 01.02.2017
/**
  if (Auf.A.MEH.Preis='kg') or (Auf.A.MEH.Preis='t') then begin
    if (VwA.Nummer<>Auf.P.Verwiegungsart) then begin
      Erx # RecLink(818,401,9,_recfirst); // Verwiegungsart holen
      if (erx>_rLocked) then begin
        RecBufClear(818);
        VWa.NettoYN # Y;
      end;
    end;
    if (VWa.NettoYN) then
      Auf.A.Menge.Preis # Mat.Gewicht.Netto
    else
      Auf.A.Menge.Preis # Mat.Gewicht.Brutto;
      if (Auf.A.MEh.Preis='t') then
        Auf.A.Menge.Preis # Rnd(Auf.A.Menge.Preis / 1000.0,Set.Stellen.Menge);
debugX(anum(auf.a.menge.preis,2));
  end**/
  // 16.12.2014:
  else if (Auf.A.MEH.Preis=Mat.MEH) then
    Auf.A.Menge.Preis # Mat.Bestand.Menge
  else if (Auf.A.MEH.Preis=BAG.FM.MEH) then
    Auf.A.Menge.Preis # BAG.FM.Menge
  else if (Auf.A.MEH.Preis='kg') then
    Auf.A.Menge.Preis # Auf.A.Gewicht
  else if (Auf.A.MEH.Preis='t') then
    Auf.A.Menge.Preis # Auf.A.Gewicht / 1000.0
  else if (Auf.A.MEH.Preis='Stk') then
    Auf.A.Menge.Preis # Cnvfi("Auf.A.Stückzahl");

  RunAFX('BAG.Set.Auf.Aktion','');

  RETURN Auf_A_Data:NeuAnlegen(n, (vSLNr<>0))=_rOK;

end;


//========================================================================
//  AbschlussPos  +ERR
//
//========================================================================
sub AbschlussPos(
  aBag    : int;
  aPos    : int;
  aDatum  : date;
  aZeit   : time;
  opt aSilent     : logic) : logic;
local begin
  Erx             : int;
  vA              : alpha;
  vGew            : float;
  vBuf703         : int;
  vBuf702         : int;
  vFahrVK         : logic;
  vOK             : logic;
  vM              : float;
  vStk            : int;
  vBuf440         : int;
  vBuf441         : int;
  vWasIstMitRest  : alpha;
  vMatDel         : logic;
  vSchrottGew     : float;
  vSchrottStk     : int;
  vSchrottAnzahl  : int;
  vNr             : int;
  vVorFahren      : int;
  vDiffTxt        : int;
  vCT1,vCT2       : caltime;
  vVSD            : logic;
  scndString      : alpha(4096);
  vPlanOutGew     : float;
  vIstOutGew      : float;
  vProzent        : float;
end;
begin DoLogProc;

  // Position holen
  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (erx>=_rLocked) then RETURN false;


  // Abschlussdatum darf NIE vor Fertigmeldungen liegen
  // sonst wird Schrottnullung vererbt...
// ST 2022-12-01: Fallback nach Terminprüfung
//  if (aDatum=0.0.0) then aDatum # today;
  if (aDatum<>0.0.0) then
    vCT1->vpDate # aDatum;
    
  vCT1->vpTime # aZeit;
  FOR Erx # RecLink(707,702,5,_recFirst)
  LOOP Erx # RecLink(707,702,5,_recnext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.FM.Datum=0.0.0) then CYCLE;
    vCT2->vpDate # BAG.FM.Datum;
    vCT2->vpTime # BAG.FM.Zeit;
    vCT1 # Max(vCT1, vCT2);
  END;
  aDatum  # vCT1->vpdate;
  aZeit   # vCT1->vptime;
  // ST 2022-12-01 Fallback nach Prüfung
  if (aDatum=0.0.0) then aDatum # today;

  if (BA1_P_Lib:StatusFreiZurProduktion()=false) then begin
    Error(702045,BAG.P.Status);
    RETURN false;
  end;

  // Vorgängercheck
  vOK # BA1_P_Data:SindVorgaengerAbgeschlossen(var vVorFahren, false);
  if (vOK=falsE) then begin
    Error(702024,'');
    RETURN false;
  end;

  // Ankerfunktion?
  if (RunAFX('BAG.P.Abschluss','')<>0) then begin
    if (AfxRes<>_rOk) then RETURN false;
  end;


  if ("BAG.P.Löschmarker"='*') or (BAG.P.Fertig.Dat<>0.0.0) then begin
    if (!BA1_Kosten:UpdatePosition(aBAG, aPos,aSilent)) then
        Error(702025,'');

    Error(702009,'');
    RETURN false;
  end;

  //  VSB-Position? -> Kann nicht fertiggemeldet werden!
  if (BAG.P.Typ.VSBYN) then begin
    Error(702008,'');
    RETURN false;
  end;


  if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    RETURN BA1_FM_MatPrd_Data:Abschluss(aDatum, aZeit, aSilent);
  end;


  vGew # 0.0;
  // 06.11.2014 : Beim Fahren testen, ob kompletter Einsatz im Lager leer ist. Wenn nicht, KEIN Verschrotten vom Einsatz möglich !!!
  if (BAG.P.aktion=c_BAG_Fahr09) then begin
    // Einsatz loopen
    FOR Erx # recLink(701,702,2,_RecFirst)
    LOOP Erx # recLink(701,702,2,_RecNext)
    WHILE (erx<=_rLocked) do begin
      if (BAG.IO.MaterialRstNr<>0) then begin
        Erx # Mat_Data:Read(BAG.IO.MaterialRstNr);  // Restkarte holen
        if (erx>=200) then begin
// 25.08.2020 AH          vGew # vGew + (Mat.Gewicht.Netto - BAG.IO.Plan.Out.GewN);
// 12.11.2020 AH          if (Mat.Bestand.Gew>0.0) or (Mat.Bestand.Stk>0) then begin
          if (Mat.Bestand.Stk>0) then begin
            vWasIstMitRest # 'wennLeer';
            BREAK;
          end;
        end;
      end;
    END;
//    if (vGew>0.0) then vWasIstMitRest # '!';
  end;


  vGew # 0.0;
  // Einsatz loopen
  FOR Erx # recLink(701,702,2,_RecFirst)
  LOOP Erx # recLink(701,702,2,_RecNext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.P.aktion=c_BAG_Fahr09) then begin //or (BAG.P.aktion=c_BAG_Bereit) then begin  // 11.11.2021 AH
      if (BAG.IO.BruderID<=0) then begin
        vGew # vGew + BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN;
        
        if (Set.BA.AbschlWieWarn='N') then begin  // 2023-08-15 AH
          vPlanOutGew # vPlanOutGew + BAG.IO.Plan.Out.GewN;
          vIstOutGew  # vIstOutGew + BAG.IO.Ist.Out.GewN;
        end
        else begin
          vPlanOutGew # vPlanOutGew + BAG.IO.Plan.Out.GewB; //[+] MR 2166/136
          vIstOutGew  # vIstOutGew + BAG.IO.Ist.Out.GewB;  //[+] MR 2166/136
        end;
      end;

      // 16.07.2019 AH:
      if (BAG.IO.Materialtyp=c_IO_Mat) and
        (BAG.IO.MaterialRstnr<>0) then begin
        Erx # Mat_Data:Read(BAG.IO.MaterialRstNr);  // Restkarte holen
        if (erx>=200) then begin
          vSchrottGew # vSchrottGew + Mat.Bestand.Gew;
//debugx('KEY200 '+anum(Mat.Bestand.Gew,0));
          vSchrottStk # vSchrottStk + Mat.Bestand.Stk;
          vSchrottAnzahl # vSchrottanzahl + 1;
        end;
      end;
      if (BAG.IO.Materialtyp=c_IO_VSB) and (Set.LFS.MatBeiAbschl='A') then begin
        Error(702036,'');
        RETURN false;
      end;
    end
    else begin
      if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
        Erx # Mat_Data:Read(BAG.IO.MaterialRstNr);  // Restkarte holen
        if (erx>=200) then begin

          vSchrottGew # vSchrottGew + Mat.Bestand.Gew;
          vSchrottStk # vSchrottStk + Mat.Bestand.Stk;
          vSchrottAnzahl # vSchrottanzahl + 1;

          // ST 2022-03-03 Projekt 2151/128:
          //      Schrottgewioht immer vom Nettogewicht berechnen
          //vGew # vGew + Mat.Bestand.Gew;
          if (Mat.Gewicht.Netto = 0.0) then
            Mat.Gewicht.Netto # Mat.Bestand.Gew;
          vGew # vGew + Mat.Gewicht.Netto;
          
          if (Set.BA.AbschlWieWarn='N') then begin  // 2023-08-15 AH
            vPlanOutGew # vPlanOutGew + BAG.IO.Plan.Out.GewN;
            vIstOutGew  # vIstOutGew + BAG.IO.Ist.Out.GewN;
          end
          else begin
            vPlanOutGew # vPlanOutGew + BAG.IO.Plan.Out.GewB; //[+] MR 2166/136
            vIstOutGew  # vIstOutGew + BAG.IO.Ist.Out.GewB;  //[+] MR 2166/136
          end;
        end;
      end;
    end;

    // Artikel mit ECHTEN Chargen?
    if (BAG.IO.Materialtyp=c_IO_Beistell) or
      ((BAG.P.Aktion<>c_BAG_ArtPrd) and (BAG.IO.Materialtyp=c_IO_Art)) then begin
      if (BAG.IO.Charge='') then begin
        Error(702037,'');
        RETURN false;
      end;
    end;
  END;


  if (aSilent=n) then begin
    if (BAG.P.Aktion<>c_BAG_Fahr09) AND (Bag.P.Aktion<>c_BAG_Umlager) then begin  // TODO ArG.Typ.ReservInput
/*** 2023-02-03 AH
      if(vPlanOutGew <0.0) then vPlanOutGew # vPlanOutGew * (-1.0);
      if(vIstOutGew <0.0) then vIstOutGew # vIstOutGew * (-1.0);
      //[+/-] 01.02.2022 MR Edit einbau von Prozentanteil in Messagebox nach Ticket 2166/136
      if((vIstOutGew <= vPlanOutGew) and (vIstOutGew != 0.0) and (vPlanOutGew != 0.0)) then begin
        vProzent # 100.0 - ((vIstOutGew /vPlanOutGew )*100.0);
        if (Msg(702010,ANum(vPlanOutGew - vIstOutGew,"Set.Stellen.Gewicht")+' kg|'+ANum(vProzent,2),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      end
      else begin
        if (Msg(702057,ANum(vPlanOutGew - vIstOutGew,"Set.Stellen.Gewicht")+' kg',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      end;
***/
      if (vPlanOutGew<>0.0) then begin
        vProzent # 100.0 - ((vIstOutGew /vPlanOutGew )*100.0);
        if (Msg(702010,ANum(vSchrottGew,"Set.Stellen.Gewicht")+' kg|'+ANum(vProzent,2),_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      end
      else begin
        if (Msg(702057,ANum(vSchrottGew,"Set.Stellen.Gewicht")+' kg',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
      end;

    end
    else begin
      // mehrere LFS vorhanden??
      if (Set.LFS.proKommissYN) then begin
        // Prüfen, ob jeder LFS mind. eine Verwiegung enthält...
        vBuf440 # RekSave(440);
        vBuf441 # RekSave(441);
        vOK # y;

        FOR Erx # RecLink(440,702,14,_recFirst)     // LFS loopen
        LOOP Erx # RecLink(440,702,14,_recNext)
        WHILE (erx<=_rLocked) and (vOK) do begin
          if (RecLinkInfo(441,440,4,_RecCount)>0) then begin
            vOK # n;
            Erx # RecLink(441,440,4,_RecFirst); // Positionen loopen
            WHILE (erx<=_rLocked) do begin
              if (Lfs.P.Datum.Verbucht<>0.0.0) then begin
                vOK # y;
                BREAK;
              end;
              Erx # RecLink(441,440,4,_recNext);
            END;
          end;
        END;
        RekRestore(vBuf440);
        RekRestore(vBuf441);

        if (vOK=false) then begin
          Msg(702034,'!',0,0,0);
          RETURN false;
        end;
      end;

      if (Bag.P.Aktion<>c_BAG_Umlager) then
        if (Msg(702018,ANum(vGew,"Set.Stellen.Gewicht")+' kg',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;

      if (vWasIstMitRest='') then begin
        vWasIstMitRest # Set.LFS.MatBeiAbschl;
        if (vWasIstMitRest='J') then vWasIstMitRest # '*';
        if (vWasIstMitRest='N') then vWasIstMitRest # '!';
        if (vWasIstMitRest='A') then begin
//          if (vGew<=0.0) then begin
//            vWasIstMitRest # '*';
//          end
//          else begin
          Erx # Msg(702035,aint(vSchrottAnzahl)+'|'+aint(vSchrottStk)+'|'+anum(vSchrottGew,0),_WinIcoQuestion,_WinDialogYesNoCancel,3);
          if (Erx=_WinIdCancel) then RETURN false;
          if (erx=_WinIdyes) then vWasIstMitRest # '*';
          if (Erx=_WinIdNo) then vWasIstMitRest  # '!';
//          end;
        end;
      end;
    end;
    
    if (vVorFahren>0) then begin
      if (Msg(702048,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then RETURN false;
    end;

    if (aDatum=0.0.0) then begin
      REPEAT
        if (Dlg_Standard:Datum(translate('Abschlussdatum'),var aDatum, today)=false) then begin
          RETURN false;
        end;
      UNTIL (aDatum<>0.0.0);
    end;
  end;
  if (aDatum=0.0.0) then aDatum # today;

  if (vVorFahren>0) then begin
    vVorFahren # 0;
    vOK # BA1_P_Data:SindVorgaengerAbgeschlossen(var vVorFahren, true);
    if (vOK=falsE) then begin
      Error(702024,'');
      RETURN false;
    end;
  end;

  if (Lib_Faktura:Abschlusstest(aDatum) = false) then begin
    Error(001400 ,Translate('Abschlussdatum') + '|'+ CnvAd(aDatum));
    RETURN false;
  end;

  // Ankerfunktion?
  if (aSilent) then vA # 'Y' else vA # '';
  if (RunAFX('BAG.P.Abschluss.Pre',vA)<>0) then begin
    if (AfxRes<>_rOk) then RETURN false;
  end;


  TRANSON;

  // Arbeitsgang-Position löschen
  Erx # RecRead(702,1,_recSingleLock);
  if (erx<>_rOK) then begin
    TRANSBRK;
    Error(702020,AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position));  // ST 2009-02-02
    RETURN false;
  end;
  "BAG.P.Löschmarker" # '*';
  BAG.P.Fertig.Dat    # aDatum;
  BA1_Data:SetStatus(c_BagStatus_Fertig);
  if (aDatum=today) then begin
    BAG.P.Fertig.Zeit   # now;
    BAG.P.FErtig.User   # gUsername;
  end;
  Erx # BA1_P_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    TRANSBRK;
    Error(702012,'689');
    RETURN false;
  end;

  // Auftragsaktionen updaten...
  BA1_P_Data:UpdateAufAktion(n);

  // INPUT LOOPEN *************************************************
  Erx # recLink(701,702,2,_RecFirst);   // Input loopen
  WHILE (erx<=_rLocked) do begin

    // VSB-Material? -> aus BA rausnehmen ------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_VSB) then begin

      // Output löschen
      Erx # RecRead(701,1,_recLock);
      if (Erx=_rOK) then begin
        "BAG.IO.LöschenYN" # y;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
      end;
      if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
        TRANSBRK;
        Error(010034,AInt(BAG.F.Nummer));
        ERROROUTPUT;  // 01.07.2019
        RETURN false;
      end;

      if (BA1_F_Data:UpdateOutput(701,y)=false) then begin
        TRANSBRK;
        Error(010034,AInt(BAG.F.Nummer));
        ERROROUTPUT;  // 01.07.2019
        RETURN false;
      end;

      // Einsatzmaterial reaktivieren?
      if (BA1_Mat_Data:VSBFreigeben()=false) then begin
        TRANSBRK;
        Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
        RETURN false;
      end;
      Erx # BA1_IO_Data:Delete(0,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        Error(010036,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.ID));
        RETURN false;
      end;

      Erx # recLink(701,702,2,_recFirst);
      CYCLE;
    end; // VSB-Material


    // Artikel? -> Reservierungen aufheben ---------------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Art) then begin
      // Reservierung aufheben...
      if (BA1_Art_Data:ArtFreigeben()=false) then begin
// 06.05.2010 AI : auch bei keiner Res. weitermachen
//        TRANSBRK;
//        Error(701006,'');
//        RETURN false;
      end;
    end;


    // BeistelleArtikel? -> Abgang buchen und Kosten summieren -------------------------
    if (BAG.IO.MaterialTyp=c_IO_Beistell) then begin
    
      if (BAG.P.Aktion=c_BAG_Fahr09) or (Bag.P.Aktion=c_BAG_Umlager) then begin // 17.02.2020
        Erx # recLink(701,702,2,_recNext);
        CYCLE;
      end;
    
      erx # RecLink(250,701,8,_recFirst);     // Artikel holen
      if (erx<=_rLocked) then begin
        erx # RecLink(252,701,17,_recFirst);  // Charge holen
        if (erx<=_rLocked) then begin

          // Ankerfunktion starten
          if (RunAFX('BAG.FM.BeistellKost','')<>0) then begin
            if (AfxRes<>_rOK) then begin
              TRANSBRK;
              Error(702012,'899');
              RETURN false;
            end;
          end
          else begin  // STANDARD
            // Gesamtkosen des ARtikel errechnen und in IO speichern...
            RecbufClear(254);
            if (Art.C.EKDurchschnitt<>0.0) then begin
              Art.P.MEH # Art.MEH;
              Art.P.PEH # Art.PEH;
              Art.P.PreisW1 # Art.C.EKDurchschnitt;
            end
            else if (Art.C.EKLetzter<>0.0) then begin
              Art.P.MEH # Art.MEH;
              Art.P.PEH # Art.PEH;
              Art.P.PreisW1 # Art.C.EKLetzter;
            end
            else begin
              Art_P_Data:LiesPreis(c_art_PRD,0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('Ø-EK',0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('L-EK',0);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('L-EK',-1);
              if (Art.P.PreisW1=0.0) then
                Art_P_Data:LiesPreis('EK',0);
            end;
            if (BAG.IO.Meh.In<>Art.P.MEH) and (Art.P.MEH<>'') then begin
              TRANSBRK;
              Error(702012,'899');
              RETURN false;
            end;
            Erx # RecRead(701,1,_recLock);
            if (erx=_rOK) then begin
              BAG.IO.GesamtKostW1 # Art.P.PreisW1 * BAG.IO.Plan.In.Menge / CnvfI(Art.P.PEH);
              Erx # RekReplace(701,_recUnlock,'AUTO');
            end;
            if (erx<>_rOK) then begin // 2022-07-05 AH DEADLOCK
              TRANSBRK;
              Error(702012,thisline);
              RETURN false;
            end;
          end;

          // Reservierung aufheben...
          if (BA1_Art_Data:ArtFreigeben()=false) then begin
            TRANSBRK;
            Error(701006,'');
            RETURN false;
          end;

          // Bewegung buchen...
          RecBufClear(253);
          Art.J.Datum           # aDatum;
          Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
          "Art.J.Stückzahl"     # (-1) * BAG.IO.PLan.In.Stk;
          Art.J.Menge           # (-1.0) * BAG.IO.Plan.In.Menge;
          "Art.J.Trägertyp"     # c_Akt_BA;
          "Art.J.Trägernummer1" # BAG.P.Nummer;
          "Art.J.Trägernummer2" # BAG.P.Position;
          "Art.J.Trägernummer3" # BAG.IO.ID;
          vOK # Art_Data:Bewegung(0.0, 0.0);
          if (vOK=false) then begin
            TRANSBRK;
            Error(702012,'881');
            RETURN false;
          end;
        end;

      end;
    end;

    Erx # RecLink(701,702,2,_RecNext);
  END;


  // INPUT LOOPEN.2 *************************************************
  Erx # recLink(701,702,2,_RecFirst);   // Input loopen
  WHILE (erx<=_rLocked) do begin

    // echtes Material? --------------------------------------------------
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin

      // Lohnfahrauftrag??
      if (BAG.P.Aktion=c_BAG_Fahr) and (BAG.P.ZielVerkaufYN) then begin
        if (Lfs_LFA_Data:AbschlussInput(BAG.P.Nummer, BAG.IO.ID)=false) then begin
          TRANSBRK;
//          Msg(702012,ErgA,0,0,0);
          RETURN false;
        end;
      end;

      // 15.10.2021 AH
      if (BAG.P.Aktion=c_BAG_Versand) then begin
        Erx # Mat_Data:Read(BAG.IO.MaterialRstNr);  // Restkarte holen
        if (erx<200) then begin
          TRANSBRK;
          Error(702012,'1769 @ Restkarte M'+aint(BAG.IO.MaterialRstNr) + ' nicht gefunden!');
          RETURN false;
        end;
        if ("Mat.Löschmarker"='') then begin
          TRANSBRK;
          Error(702012,'1774 @ Restkarte M'+aint(BAG.IO.MaterialRstNr) + ' noch im Bestand!');
          RETURN false;
        end;
        // alles gut!
        CYCLE;
      end;


      // Restkarte lesen, !! Achtung !! Umlagerarbeitsgänge haben keine Restkarte
      if (BAG.P.Aktion<>c_BAG_Umlager) then begin
        Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
        /* 27.04.2015 wieder aktiviert :*/
        if (erx<>_rOK) or
          ("Mat.Löschmarker"<>'') or (Mat.Ausgangsdatum<>0.0.0) then begin
          TRANSBRK;
          Error(702012,'753 @ Restkarte M'+aint(BAG.IO.MaterialRstNr) + ' ist schon gelöscht!');
          RETURN false;
        end;
      end;

      // bei NICHT Fahren, Einsatz schrotten.....................
      // TODO ArG.Typ.ReservInput=FALSE     if (ArG.Aktion2<>BAG.P.Aktion2) then  erx # RecLink(828,702,8,_recFirst);
//      if (BAG.P.Aktion<>c_BAG_Fahr09) AND(BAG.P.Aktion<>c_BAG_Umlager) then begin
      if (BA1_P_Data:ReservierenStattStatus(BAG.P.Aktion,701)=false) then begin
        Erx # RecRead(200,1,_recSingleLock);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          ERror(702012,'1867');
          RETURN false;
        end;
        Mat.Kommission    # '';
        Mat.Auftragsnr    # 0;
        Mat.Auftragspos   # 0;
        Mat.Auftragspos2  # 0;
        Mat.KommKundennr  # 0;

        // "Mat.Löschmarker" # '*';
        Mat_Data:SetLoeschmarker('*');
        Mat.Ausgangsdatum # aDatum;

        Mat_Data:SetStatus(c_Status_BAGverschnitt); // auf "Verschnitt" setzen

        // Schrottartikel ggf. buchen...
        Erx # RekLink(819,200,1,_recFirst);   // Warengruppe holen
        RunAFX('BAG.FM.FindSchrottArtikel','');
        if (Wgr.Schrottartikel<>'') and (Mat.Bestand.Gew>0.0) then begin
          Erx # RecLink(250,819,2,_recFirst); // Artikel holen
          if (erx>_rLocked) then begin
            TRANSBRK;
            Error(702040,Wgr.Schrottartikel);
            RETURN false;
          end;

          RecBufClear(252);
          Art.C.ArtikelNr   # Art.Nummer;
          Art.C.Adressnr    # Set.EigeneAdressnr;
          Art.C.Anschriftnr # 1;
//            Art_Data:ReadCharge();

          // Bewegung buchen...
//              vStk # Cnvif(Lib_Einheiten:WandleMEH(250, vStk, Mat.Bestand.Gew, 0.0, '', vStk));
          vStk # Mat.Bestand.Stk;
          if (vStk=0) then vStk # 1;
          vM # Lib_Einheiten:WandleMEH(250, Mat.Bestand.Stk, Mat.Bestand.Gew, 0.0, '', Art.MEH);

          RecBufClear(253);
          Art.J.Datum           # aDatum;
          Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
          "Art.J.Stückzahl"     # vStk;
          Art.J.Menge           # vM;
          "Art.J.Trägertyp"     # c_Akt_BA;
          "Art.J.Trägernummer1" # BAG.P.Nummer;
          "Art.J.Trägernummer2" # BAG.P.Position;
          "Art.J.Trägernummer3" # 0;
          vOK # Art_Data:Bewegung(0.0, 0.0,0, true);
          if (vOK=false) then begin
            TRANSBRK;
            Error(702012,'1188');
            RETURN false;
          end;

          // 30.11.2012 AI: Schrottcharge merken !!!
          Erx # RecRead(701,1,_recLock);
          if (erx=_rOK) then begin
            BAG.IO.Artikelnr  # Art.C.Artikelnr;
            BAG.IO.Charge     # Art.C.Charge.Intern;
            Erx # RekReplace(701,_recUnlock,'AUTO');
          end;
          if (erx<>_rOK) then begin // 2022-07-05 AH DEADLOCK
            TRANSBRK;
            Error(702012,thisline);
            RETURN false;
          end;
        end;  // Schrottartikel

        Erx # Mat_Data:Replace(_recUnlock,'AUTO');
        if (erx<>_rOK) then begin
          TRANSBRK;
          Error(702012,'908');
          RETURN false;
        end;

        // 17.02.2010  AI
        // alle Reservierungen entfernen auf der Schrottkarte
        WHILE (RecLink(203,200,13,_recFirst)<=_rLocked) do begin
          if (Mat_Rsv_data:Entfernen()=false) then begin
            TRANSBRK;
            Error(702012,'1191');
            RETURN false;
          end;
        END;

      end
      else begin  // Einsatz war RESERIVERT?

        Erx # RecRead(701,1,_recSingleLock);
        if (Erx=_rOK) then begin
          BAG.IO.Plan.Out.Stk   #  BAG.IO.Ist.Out.Stk;
          BAG.IO.Plan.Out.GewN  #  BAG.IO.Ist.Out.GewN;
          BAG.IO.Plan.Out.GewB  #  BAG.IO.Ist.Out.GewB;
          BAG.IO.Plan.Out.Meng  #  BAG.IO.Ist.Out.Menge;
          Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        end;
        if (erx<>_rOK) then begin
          TRANSBRK;
          Error(702012,'987');
          RETURN false;
        end;

        // Reservierung entfernen -----------------------------------------
        RecBufClear(203);
        Mat.R.Materialnr      # BAG.IO.Materialnr;
        "Mat.R.Trägertyp"     # c_Akt_BAInput;
        "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
        "Mat.R.TrägerNummer2" # BAG.IO.ID;
        Erx # RecRead(203,5,0);
        if (erx<=_rMultikey) then begin
          if (Mat_Rsv_data:Entfernen()=false) then begin
            TRANSBRK;
            Error(702012,'1978');
            RETURN false;
          end;
          RecRead(200,1,0);
          if (Mat.Status=c_Status_BAGZumFahren) then begin
            Erx # RecRead(200,1,_recSingleLock);
            if (Erx=_rOK) then begin
              if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
                Mat_Data:SetStatus(c_Status_EKVSB);      // wieder VSB-EK machen
              end
              else begin
                if (Mat.Auftragsnr=0) then
                  Mat_Data:SetStatus(c_Status_Frei)     // komplett freies Material
                else
                  Mat_Data:SetStatus(c_Status_VSB);     // VSB für Kundenauftrag
              end;
              Erx # Mat_Data:Replace(_recUnlock,'AUTO');
            end;
            if (erx<>_rOK) then RETURN false;
          end;

        end;

        // Verschrotten nur bei Fahren, nicht bei Umlagerung
        if (BAG.P.Aktion=c_BAG_Fahr09) then begin
          // Karte hat weiter keine Reservierungen?
          // -> dann auch schrotten
          vMatDel # n;
          if (vWasIstMitRest='wennLeer') and (Mat.Bestand.Stk<=0) then begin    // 12.11.2020 AH: Wenn keine STÜCK
            vMatDel # y;
          end
          else if (vWasIstMitRest='') and
            (Mat.Bestand.Stk<=0) and (Mat.Bestand.Gew<=0.0) then begin
            vMatDel # y;
          end
          else if (vWasIstMitRest='*') then vMatDel # y;

          if (vMatDel) then begin
            // 05.05.2017 AH: Abschluss beim Fahren MIT VERSCHROTTUNG legt RESTKARTE an...
            // wenn NICHT aus Weiterbearbeitung, dann eine Restkarte bilden zum Verschrotten
            if (BAG.IO.VonID = 0) and
             ((Mat.Bestand.Gew>0.0) or (Mat.Bestand.Stk>0)) then begin  // 25.08.2020 AH:
              vNr # BA1_Mat_Data:BildeFahrRest(Mat.Nummer, aDatum, aZeit);
              if (vNr<0) then begin
                TRANSBRK;
                Error(702012,'1745');
                RETURN false;
              end;
              Erx # RecRead(701,1,_RecLock);
              if (erx=_rOK) then begin
                BAG.IO.MaterialRstNr # vNr;
                Erx # RekReplace(701);
              end;
              if (erx<>_rOK) then begin // 2022-07-05 AH DEADLOCK
                TRANSBRK;
                Error(702012,thisline);
                RETURN false;
              end;
            end;
            Mat_Subs:Verschrotten(false, '', c_Status_BAGRestFahren);

          end;
        end // EO if (BAG.P.Aktion=c_BAG_Fahr09) then begin
        else begin    // 12.05.2022 AH
//debugx('Verschrotte!');
          if (Mat.Bestand.Stk<=0) and (Mat.Bestand.Gew<=0.0) and (Mat.Bestand.Menge<=0.0) then begin
            Mat_Subs:Verschrotten(false, '', c_Status_BagVerschnitt);
          end;
        end;


      end;

    end; // echtes Material

    Erx # RecLink(701,702,2,_RecNext);
  END;


if (cDebug) and (cDebuglog<>'') then
  Lib_Debug:Protokoll(cDebugLog, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : Abschluss');
  
  // Geplante Mengen aus Aufträgen entfernen -----------------------------
  // für VSB und VERSAND
  vBuf702 # RekSave(702);
  if (BAG.P.Aktion=c_BAG_Fahr) and (BAG.P.ZielVerkaufYN) then
    vFahrVK # y;
  Erx # RecLink(701,702,3,_recFirst);       // OUTPUT loopen
  WHILE (Erx<=_rLocked) do begin

    // nur Weiterbearbeitungen prüfen
    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      Erx # RecLink(702,701,4,_recFirst);   // Nachfolger holen

      // theoretischen Versand löschen?
      if (BAG.P.Aktion=c_BAG_Versand) then begin
        VsP_data:BaGInput2Ablage();
      end;

      if (BAG.P.Typ.VSBYN) or (BAG.P.Aktion=c_BAG_Versand) then begin
if (cDebug) and (cDebuglog<>'') then
  Lib_Debug:Protokoll(cDebugLog, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : ist VSB');
        Auf.P.Nummer      # BAG.P.Auftragsnr;
        Auf.P.Position    # BAG.P.Auftragspos;
        Erx # RecRead(401,1,0);       // Auftrag holen
        if (erx<=_rLocked) then begin
          Auf.A.Aktionsnr   # BAG.IO.VonBAG;
          Auf.A.Aktionspos  # BAG.IO.VonPosition;
          Auf.A.Aktionspos2 # BAG.IO.ID;
          Auf.A.Aktionstyp  # c_Akt_BA_Plan;
         // Fahren? 19.08.2014
//          if (vFahrVK) then
//            Auf.A.Aktionstyp  # c_Akt_BA_Plan_Fahr;
          if (vFahrVK) then begin // 01.12.2015 AH : "BA FA" suchen, sonst "BA S"
            Auf.A.Aktionstyp  # c_Akt_BA_Plan_Fahr;
            Erx # RecRead(404,2,0);
            if (erx>_rMultikey) then begin
              Auf.A.Aktionsnr   # BAG.IO.VonBAG;
              Auf.A.Aktionspos  # BAG.IO.VonPosition;
              Auf.A.Aktionspos2 # BAG.IO.ID;
              Auf.A.Aktionstyp  # c_Akt_BA_Plan;
            end;
          end;

if (cDebug) and (cDebuglog<>'') then
  Lib_Debug:Protokoll(cDebugLog, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : Suche Akt'+aint(Auf.A.Aktionsnr)+'/'+aint(Auf.A.Aktionspos)+'/'+aint(Auf.A.Aktionspos2));

          Erx # RecRead(404,2,0);
          if (erx>_rMultikey) then begin  // NICHT GEFUNDEN??? -> weitermachen...
if (cDebug) and (cDebuglog<>'') then
  Lib_Debug:Protokoll(cDebugLog, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : AKTION FEHLT!!!');
          
//            TRANSBRK;
//            Error(010038,cnvai(BAG.IO.VonBAG)+'/'+cnvai(BAG.IO.VonPosition));
//            RETURN false;
          end
          else begin
if (cDebug) and (cDebuglog<>'') then
  Lib_Debug:Protokoll(cDebugLog, 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : Aktion wird gelöscht!');
            if (Auf_A_Data:Entfernen(y)=false) then begin
              TRANSBRK;
              RekRestore(vBuf702);
              Error(010039,AInt(BAG.IO.VonBAG)+'/'+AInt(BAG.IO.VonPosition)+'|'+AInt(Auf.A.Nummer)+'/'+AInt(auf.A.Position)+'/'+AInt(Auf.a.Aktion));
              RETURN false;
            end;
          end;

        end;
      end; // ist VSB/Versand

      RecBufCopy(vBuf702,702);

    end; // Weiterbearbeitung

    Erx # RecLink(701,702,3,_recNext);
  END;
  RecBufDestroy(vBuf702);


  // Fahrauftrag? -> Lieferschein verbuchen!
  if (BAG.P.Aktion=c_BAG_Fahr) or (BAG.P.Aktion=c_BAG_Umlager) then begin

    FOR Erx # RecLink(440,702,14,_recFirst)     // Lieferscheine loopen
    LOOP Erx # RecLink(440,702,14,_recNext)
    WHILE (erx<=_rLocked) do begin

      // Ursprungs-Positionen löschen
      Erx # RecLink(441,440,4,_RecFirst);
      WHILE (Erx<=_rLocked) do begin
        vVSD # vVSD or (Lfs.P.Versandpoolnr>0);
        if (LFS.P.Datum.Verbucht=0.0.0) then begin
          if (Lfs_VLDAW_Data:Pos_VLDAW_Verbuchen(y)=false) then begin
            TRANSBRK;
            ErrorOutput;
            RETURN false;
          end;
          Erx # RekDelete(441,0,'MAN');
          if (erx<>_rOK) then begin
            TRANSBRK;
            Error(702442,AInt(Lfs.P.Nummer)+'/'+AInt(Lfs.P.Position)); // ST 2009-02-02
            RETURN false;
          end;
          Erx # RecLink(441,440,4,0);
          Erx # RecLink(441,440,4,0);
          CYCLE;
        end;
        Erx # RecLink(441,440,4,_RecNext);
      END;

      // Kopfgewichte addieren...
      Lfs_Data:SumLFS();

      // LFS-Kopf verbuchen...
      Erx # RecRead(440,1,_recSingleLock);
      if (Erx=_rOK) then begin
        Lfs.Datum.Verbucht # aDatum;
        Erx # RekReplace(440,_recUnlock,'AUTO');
      end;
      if (erx<>_rOK) then begin
        TRANSBRK;
        Error(702440,'');
        RETURN false;
      end;
      if (vVSD) then VSD_Data:PruefeObAllesErledigtBeiLFS();

    END;

  end;  // Fahren


  // alle Fertigungen neu errechnen
// 20.05.2015 AH WOZU?? Ändert dann 703er!!!
//BA1_P_Data:ErrechnePlanmengen();


  // Kosten errechnen
  vBuf702 # RekSave(702);
/**
  Erx # RecLink(702,700,1,_RecFirst);   // Positionen loopen
  WHILE (Erx<=_rLocked) do begin
    if (BAG.P.Aktion<>c_BAG_VSB) then begin
      if (BA1_Kosten:UpdatePosition(BAG.Nummer, BAG.P.Position)=false) then begin
        TRANSBRK;
        RekRestore(vBuf702);
        Error(702025,'');
        RETURN false;
      end;
    end;
    Erx # RecLink(702,700,1,_RecNext);
  END;
***/

  if (BAG.P.Aktion<>c_BAG_Umlager) then begin
    // Keine Kostenumlage bei Umlagern

    // 13.03.2020 AH: auch hier Kostenänderungen fakturaseitig beachten
    vDiffTxt # TextOpen(20);
    if (BA1_Kosten:UpdatePosition(aBAG, aPos,aSilent, false, false, vDiffTxt, false)=false) then begin
      TRANSBRK;
      TextClose(vDiffTxt);
      RekRestore(vBuf702);
      Error(702025,'');
      RETURN false;
    end;
    Erl_Data:ParseDiffText(vDiffTxt, false, 'BAG-Abschluss');
    TextClose(vDiffTxt);

  end;

  RekRestore(vBuf702);


  // Fahrauftrag? Kosten in Auf.Aktion updaten
  if (BAG.P.Aktion=c_BAG_Fahr) then begin

    FOR Erx # RecLink(440,702,14,_recFirst)     // Lieferscheine loopen
    LOOP Erx # RecLink(440,702,14,_recNext)
    WHILE (erx<=_rLocked) do begin
      FOR Erx # RecLink(441,440,4,_RecFirst)    // Positionen loopen
      LOOP Erx # RecLink(441,440,4,_RecNext)
      WHILE (Erx<=_rLocked) do begin
        if (Lfs.P.Materialnr<>0) and
          (Lfs.P.Datum.Verbucht<>0.0.0) and (Lfs.P.Auftragsnr<>0) and (Lfs.Kundennummer<>0) then begin
          Erx # RecLink(200,441,4,_recFirst);   // Material holen
          if (erx<=_rLocked) then begin
            RecBufClear(404);
            Auf.A.Aktionsnr     # Lfs.P.Nummer;
            Auf.A.Aktionspos    # Lfs.P.Position;
            Auf.A.Aktionspos2   # 0;
            Auf.A.Aktionstyp    # c_Akt_LFS;
            Erx # RecRead(404,2,0);
            if (Erx<=_rMultikey) then begin
              Erx # RecRead(404,1,_recLock);
              if (erx=_rOK) then begin
                Auf.A.EKPreisSummeW1  # Rnd(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2);
                Auf.A.InterneKostW1   # Rnd(Mat.Kosten * Mat.Bestand.Gew / 1000.0,2);
                Erx # RekReplace(404,_recUnlock, 'AUTO');
              end;
              if (erx<>_rOK) then begin // 2022-07-05 AH DEADLOCK
                TRANSBRK;
                Error(702012,thisline);
                RETURN false;
              end;
            end;
          end;
        end;
      END;
      
    END;  // LFs-Kopf
  end;

  vBuf702 # RekSave(702);

  // Gesamten BA prüfen...
  RecLink(700,702,1,_recFirst);   // Kopf holen
  if (BA1_Data:BerechneMarker()=false) then begin
    RekRestore(vbuf702);
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  // 09.01.2013 AI Projekt 1347/96 : LFS nicht refreshen, da sonst Versprung?!?!
  if (gZLList<>0) and (gFile<>440) then begin
    gZLList->WinUpdate(_WinUpdOn, _WinLstRecFromRecid | _WinLstRecDoSelect);
  end;

  RekRestore(vbuf702);

  // Ankerfunktion?
  if (RunAFX('BAG.P.AbschlussPost',Aint(aBAG)+'/'+Aint(aPos))<>0) then begin
    if (AfxRes<>_rOk) then RETURN false;
  end;

  if (aSilent=n) then begin
    Error(702011,'');   // Erfolg!
  end;

  RETURN true;
end;


//========================================================================
//  _MatMindernLaut707
//
//========================================================================
sub _MatMindernLaut707(
  aEtkTxt : int;
  ) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vUrStk  : int;
  vStk    : int;
  vGew    : float;
  vBuf701 : int;
  vA      : alpha;
  vM,vM2  : float;
end;
begin DoLogProc;

  Erx # RecRead(200,1,_recSingleLock);
  if (Erx<>_rOK) then begin
    Error(010043, Translate('Material')+' '+aint(Mat.Nummer));
    RETURN false;
  end;
  vGew    # Mat.Bestand.Gew;
  vUrStk  # Mat.Bestand.Stk;
  Mat.Gewicht.Netto   # Mat.Gewicht.Netto   - BAG.FM.Gewicht.Netto;
  Mat.Gewicht.Brutto  # Mat.Gewicht.Brutto  - BAG.FM.Gewicht.Brutt;   // 25.10.2010 war netto
  // ggf. Stückzahl auch mindern
  if ("BAG.P.Typ.1In-1OutYN") or (BAG.P.Aktion=c_BAG_spulen) or
    (BAG.P.Aktion=c_BAG_Paket) or (BAG.P.Aktion=c_BAG_MatPrd) then
    Mat.Bestand.Stk     # Mat.Bestand.Stk - "BAG.FM.Stück";
/*** 2022-12-20 AH
  if ((BAG.P.Aktion=c_BAG_Saegen) or (BAG.P.Aktion=c_BAG_Ablaeng)) and
    ("Mat.Länge"<>0.0) and (Mat.Bestand.Stk<>0) then begin
    "Mat.Länge" # Rnd( (BAG.IO.Ist.In.Menge - (BAG.IO.Ist.Out.Menge+BAG.FM.Menge)) / cnvfi(Mat.Bestand.Stk) * 1000.0, "set.Stellen.Länge");
    if ("Mat.Länge"<0.0) then "mat.Länge" # 0.0;
  end;
***/
  Mat.Bestand.Gew     # -1.0;  // freimachen zur Berechnung
  vM # 0.0;
  if (Mat.MEH=BAG.FM.MEH) then
    vM # BAG.FM.Menge
  else if (Mat.MEH=BAG.FM.MEH2) then
    vM # BAG.FM.Menge2
  else if (Mat.MEH='Stk') then
    vM # cnvfi("BAG.FM.Stück")
  else
    vM # Rnd(Lib_Berechnungen:Dreisatz(cnvfi(vUrStk-Mat.Bestand.Stk), cnvfi(vUrStk), Mat.Bestand.Menge) ,Set.Stellen.Menge);

  Mat.Bestand.Menge # Mat.Bestand.Menge - vM;

  vM2 # Mat.Bestand.Menge;
  if (vM=0.0) or (vM2=0.0) then begin
    Mat.Bestand.Menge # 0.0;    // 01.12.2014
    Erx # Mat_Data:Replace(_recUnlock,'AUTO');
  end
  else begin
    Erx # Mat_Data:Replace(_reclock,'AUTO');
    if (Erx=_rOK) then begin
      Mat.Bestand.Menge # vM2;
      Erx # RekReplace(200,_recunlock,'AUTO');
    end;
  end;
  if (erx<>_rOK) then RETURN false;

  vGew # Mat.Bestand.Gew - vGew;

  if (BAG.P.Aktion<>c_BAG_Fahr09) then begin
    vA # c_AKt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+AInt(BAG.FM.Fertigung)+'/'+AInt(BAG.FM.Fertigmeldung);
    if ("BAG.P.Typ.1In-1OutYN") or (BAG.P.Aktion=c_BAG_spulen) or (BAG.P.Aktion=c_BAG_MatPrd) or
      (BAG.P.Aktion=c_BAG_Paket) then begin
      if (Mat_Data:Bestandsbuch(-"BAG.FM.Stück", vGew, -vM, 0.0, 0.0, vA, BAG.FM.Datum, BAG.FM.Zeit, c_Akt_BA_Fertig, BAG.FM.Nummer, BAG.FM.Position, BAG.FM.Fertigung, BAG.FM.Fertigmeldung)=false) then
        RETURN false;
// 25.05.2022 AH
if (Mat.Bestand.Stk>0) or (Mat.Bestand.Gew>0.0) or (Mat.Bestand.Menge>0.0) then begin
  if (aEtkTxt<>0) then
    TextAddLine(aEtkTxt, '200|'+aint(RecInfo(200,_recID)));
end;
    end
    else begin
      if (Mat_Data:Bestandsbuch(0, vGew, -vM, 0.0, 0.0, vA, BAG.FM.Datum, BAG.FM.Zeit, c_Akt_BA_Fertig, BAG.FM.Nummer, BAG.FM.Position, BAG.FM.Fertigung, BAG.FM.Fertigmeldung)=false) then
        RETURN false;
    end;
    if (BAG.F.ReservierenYN) then begin
      if (BA1_Mat_Data:MinderReservierung(BAG.F.Auftragsnummer, BAG.F.Auftragspos, "BAG.F.ReservFürKunde", "BAG.FM.Stück", BAG.FM.Gewicht.Netto)=false) then
        RETURN false;
    end;
  end
  else begin
    vA # c_AKt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+AInt(BAG.FM.Fertigung)+'/'+AInt(BAG.FM.Fertigmeldung);
    if (Mat_Data:Bestandsbuch(-1 * "BAG.Fm.Stück", vGew, -vM, 0.0, 0.0, vA, BAG.FM.Datum, BAG.FM.Zeit, c_Akt_BA_Fertig, BAG.FM.Nummer, BAG.FM.Position, BAG.FM.Fertigung, BAG.FM.Fertigmeldung)=false) then
      RETURN false;
  end;

  // IO-Input-Posten anpassen -----------------------------------------------
  // bei Weiterbearbeitungen muss auch der theoretische IO verändert werden
  // 2009
  if (BAG.IO.BruderID<>0)  then begin
    vBuf701 # RekSave(701);
    BAG.IO.Nummer # BAG.IO.Nummer;
    BAG.IO.ID     # BAG.IO.BruderID;
    Erx # RecRead(701,1,0);   // Bruder vom Input holen
    if (erx<=_rLocked) then begin
      Erx # RecRead(701,1,_recSingleLock);
      if (Erx=_rLocked) then begin
        Error(010043, Translate('Einsatz'));
        RETURN false;
      end;
      BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + "BAG.FM.Stück";
      BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + BAG.FM.Gewicht.Netto;
      BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + BAG.FM.Gewicht.Brutt;
      if (BAG.FM.MEH=BAG.IO.MEH.Out) then
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge
      else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'' ) then
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge2
      else if (BAG.IO.MEH.Out='kg') then
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Gewicht.Netto
      else if (BAG.IO.MEH.Out='t') then
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + (BAG.FM.Gewicht.Netto / 1000.0)
      else if (BAG.IO.MEH.Out='Stk') then
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + cnvfi("BAG.FM.Stück")
      else
        BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge +
                              Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
      Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
      if (erx<>_rOK) then RETURN false;
    end;
    RekRestore(vBuf701);
  end;

  //Erx # RecRead(701,1,_recsingleLock);
  Erx # RecRead(701,1,_recLock); // MR 2022-08-02 Fix: Fail bei Paketieren mittels MDE
  if (Erx=_rLocked) then begin
    Error(010043, Translate('Einsatz'));
    RETURN false;
  end;
  BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + "BAG.FM.Stück";
  BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + BAG.FM.Gewicht.Brutt;

  if (BAG.FM.MEH=BAG.IO.MEH.Out) then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge2
  else if (BAG.IO.MEH.Out='kg') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Gewicht.Netto
  else if (BAG.IO.MEH.Out='t') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + (BAG.FM.Gewicht.Netto / 1000.0)
  else if (BAG.IO.MEH.Out='Stk') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + cnvfi("BAG.FM.Stück")
  // für MATMEH
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge2
  else begin
    vM # Rnd(Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out) ,Set.Stellen.Menge);
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + vM;
  end;

  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN false;


  // FAHR-Reservierung anpassen ------------------------------------------
  // TODO ArG.Typ.ReservInput=true     if (ArG.Aktion2<>BAG.P.Aktion2) then  erx # RecLink(828,702,8,_recFirst);
  if (BAG.P.Aktion=c_BAG_Fahr09) then begin
    RecBufClear(203);
    Mat.R.Materialnr      # BAG.IO.Materialnr;
    "Mat.R.Trägertyp"     # c_Akt_BAInput;
    "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
    "Mat.R.TrägerNummer2" # BAG.IO.ID;
    Erx # RecRead(203,5,0);
    if (erx<=_rMultikey) then begin

      // Verwiegungsart holen
      Erx # RecLink(818,200,10,_recFirst);
      if (Erx>_rLocked) then begin
        RecBufClear(818);
        VwA.NettoYN # y;
      end;

      Erx # RecRead(203,1,_recSingleLock);
      if (Erx<>_Rok) then RETURN false;
      "Mat.R.Stückzahl"     # BAG.IO.Plan.Out.Stk - BAG.IO.Ist.Out.Stk;
      if (VWA.NettoYN) then
        Mat.R.Gewicht       # BAG.IO.Plan.Out.GewN - BAG.IO.Ist.Out.GewN
      else
        Mat.R.Gewicht       # BAG.IO.Plan.Out.GewB - BAG.IO.Ist.Out.GewB;

      // für MATMEH
      if (Mat.MEH=BAG.IO.MEH.Out) then
        Mat.R.Menge         # BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge
      else
        Mat.R.Menge         # Lib_Einheiten:WandleMEH(701, "Mat.R.Stückzahl", Mat.R.Gewicht, BAG.IO.Plan.Out.Meng - BAG.IO.Ist.Out.Menge, BAG.IO.MEH.Out, Mat.MEH);

      if (Mat_Rsv_Data:Update()=false) then RETURN false;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  EinsatzMatMindern
//
//========================================================================
sub EinsatzMatMindern(
  aEtkTxt       : int;
  aAbschlussYN  : logic;
  var aEKSum    : float;
  var aMatEK    : float;
  ) : logic;
local begin
  Erx     : int;
  vOK     : logic;
  vUrStk  : int;
  vStk    : int;
  vGew    : float;
  vBuf701 : int;
  vA      : alpha;
  vM,vM2  : float;
  vLautBE : logic;
  vX      : float;
end;
begin DoLogProc;

  // Einsatz mindern -------------------------------------------------------
  // 1. Einsatz?
  Erx # RecLink(200,701,11,_RecFirst);  // Restkarte holen
  if (erx<>_rOK) then RETURN false;

  // 2023-01-19 AH
  if (VwA.Nummer<>BAG.FM.Verwiegungart) then begin
    Erx # RekLink(818,707,6,_recfirst);     // Verwiegungsart holen
    if (Erx>_rLocked) then VwA.NettoYN # y;
  end;
  if (VwA.NettoYN) then
    vX # BAG.FM.Gewicht.Netto
  else
    vX # BAG.FM.Gewicht.Brutt;
  if (Mat.Bestand.Gew<>0.0) then begin
    vX # vX / Mat.Bestand.Gew;  // über GEWICHT Einsatzanteil errechnen
    if (Mat.MEH='kg') then
      aMatEK # ((Mat.Bestand.Menge / 1000.0 * Mat.EK.Preis) * vX)   // wenn Gewichtseinheit, dann ist Tonnenpreis ist der genauste!
    else if (Mat.MEH='t') then
      aMatEK # ((Mat.Bestand.Menge * Mat.EK.Preis) * vX)            // wenn Gewichtseinheit, dann ist Tonnenpreis ist der genauste!
    else
      aMatEK # ((Mat.Bestand.Menge * Mat.EK.PreisProMEH) * vX);     // wenn NICHT Gewichtseinheit, dann eben über Einzelpreis
  end;

  // BEISTELLUNGEN...
  FOR Erx # RecLink(708,707,12,_recFirst) // BAG-Bewegungen loopen
  LOOP Erx # RecLink(708,707,12,_recNext)
  WHILE (erx<=_rLocked) do begin

//    if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    if (BAG.FM.B.VonID<>0) then begin
      vLautBE # true;
      // Buffer "missbrauchen"
      "BAG.FM.Stück"          # "BAG.FM.B.Stück";
      BAG.FM.Gewicht.Netto    # BAG.FM.B.Gew.Netto;
      BAG.FM.Gewicht.Brutt    # BAG.FM.B.Gew.Brutto;
      BAG.FM.Menge            # BAG.FM.B.Menge;
      BAG.FM.MEH              # BAG.FM.B.MEH;
      BAG.FM.Menge2           # 0.0;
      BAG.FM.MEH2             # '';
      Erx # RecLink(701,708,5,_recFirst);   // VonID holen
      if (Erx<>_rOK) then RETURN false;
      Erx # RecLink(200,701,11,_RecFirst);  // Restkarte holen
      if (erx<>_rOK) then RETURN false;

      if (_MatMindernLaut707(aEtkTxt)=false) then begin
        RecRead(707,1,0);
        RETURN false;
      end;
      RecRead(707,1,0);
      CYCLE;
    end;


    Erx # RecLink(252,708,2,_recFirst); // Charge holen
    if (erx>_rLocked) then RETURN false;
    Erx # RecLink(250,252,1,_recFirst); // Charge holen
    if (erx>_rLocked) then RETURN false;

    // Einsatz mindern bei NICHT Fahren --> sonst machts der LFS ja schon --------
    if (BAG.P.Aktion<>c_BAG_Fahr) or (1=1) then begin
      if (BAG.FM.MEH='Stk') then vStk # cnvif(BAG.FM.Menge)
      else vStk # 0;

      // Bewegung buchen...
      RecBufClear(253);
      Art.J.Datum           # BAG.FM.Datum;
      Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung);
      "Art.J.Stückzahl"     # vStk;
      Art.J.Menge           # (-1.0) * BAG.FM.B.Menge;
      "Art.J.Trägertyp"     # c_Akt_BA;
      "Art.J.Trägernummer1" # BAG.FM.Nummer;
      "Art.J.Trägernummer2" # BAG.FM.Position;
      "Art.J.Trägernummer3" # BAG.FM.Fertigung;
      vOK # Art_Data:Bewegung(0.0, 0.0);
      if (vOK=false) then RETURN false;
    end;

    if (Art.PEH=0) then Art.PEH # 1;
    if (BAG.FM.B.MEH=Art.MEH) then
      aEKSum # aEKSum + (BAG.FM.B.Menge * Art.C.EKDurchschnitt / cnvfi(Art.PEH));
  END;

  if (vLautBE) then RETURN true;

  RETURN _MatMindernLaut707(aEtkTxt);
end;


//========================================================================
//  EinsatzArtMindern   +ERR
//
//========================================================================
sub EinsatzArtMindern(
  aAbschlussYN  : logic;
  var aEKSum    : float) : logic;
local begin
  Erx     : int;
  vGew    : float;
  vOK     : logic;
  vStk    : int;
  vEKSum  : float;
end;
begin DoLogProc;

  Erx # RecRead(701,1,_recSingleLock);
  if (Erx<>_rOK) then RETURN false;

  // BEISTELLUNGEN...
  FOR Erx # RecLink(708,707,12,_recFirst) // BAG-Bewegungen loopen
  LOOP Erx # RecLink(708,707,12,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.FM.B.VonID<>0) then CYCLE;
    // Einsatz mindern bei NICHT Fahren --> sonst machts der LFS ja schon --------
    if (BAG.P.Aktion<>c_BAG_Fahr) then begin
      Erx # RecLink(252,708,2,_recFirst); // Charge holen
      if (erx>_rLocked) then RETURN false;
      Erx # RecLink(250,252,1,_recFirst); // Charge holen
      if (erx>_rLocked) then RETURN false;
      vStk # 0;

      // Bewegung buchen...
      RecBufClear(253);
      Art.J.Datum           # BAG.FM.Datum;
      Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung);
      "Art.J.Stückzahl"     # vStk;
      Art.J.Menge           # (-1.0) * BAG.FM.B.Menge;
      "Art.J.Trägertyp"     # c_Akt_BA;
      "Art.J.Trägernummer1" # BAG.FM.Nummer;
      "Art.J.Trägernummer2" # BAG.FM.Position;
      "Art.J.Trägernummer3" # BAG.FM.Fertigung;
      vOK # Art_Data:Bewegung(0.0, 0.0);
      if (vOK=false) then RETURN false;
      if (Art.PEH=0) then Art.PEH # 1;
      if (BAG.FM.B.MEH=Art.MEH) then
        vEKSum # BAG.FM.B.Menge * Art.C.EKDurchschnitt / cnvfi(Art.PEH);
    end;

    if (BAG.FM.B.Artikelnr=BAG.IO.Artikelnr) and (BAG.FM.B.MEH=BAG.IO.MEH.In) then
      BAG.IO.Ist.In.Menge # BAG.IO.Ist.In.Menge - BAG.FM.B.Menge;
  END;

  // IO-Input-Posten anpassen -----------------------------------------------
// LFA-Update
  BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + "BAG.FM.Stück";
  BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + BAG.FM.Gewicht.Brutt;
  if (BAG.FM.MEH=BAG.IO.MEH.Out) then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge2
  else if (BAG.IO.MEH.Out='kg') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Gewicht.Netto
  else if (BAG.IO.MEH.Out='t') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + (BAG.FM.Gewicht.Netto / 1000.0)
  else if (BAG.IO.MEH.Out='Stk') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + cnvfi("BAG.FM.Stück")
  else
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge +
                          Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);

  Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  if (erx<>_rOK) then RETURN false;

  aEKSum # vEKSum;
  RETURN true;
end;


//========================================================================
//  FeritgMatAnlegen
//
//========================================================================
sub FertigMatAnlegen(
  aBeistellKosten : float;
  aEKWert         : float;
  opt aMatNr      : int;
  opt aInvDat     : date;
  opt aPakNr      : int) : logic;
local begin
  Erx         : int;
  vNeueNr     : int;
  vVorNr      : int;
  vStatus     : int;
  vBuf100     : int;
  vBuf702     : int;
  vNeuID      : int;
  vAktID      : int;
  vSeite      : alpha;
  vNextAktion : alpha;
  vNextVSB    : logic;
  vNextLFAVK  : logic;
  vNextAktRes : logic;
  v702        : int;
  vPool       : int;
  vVSBAktBuf  : int;
  vVSDAdr     : int;
  vVSDAnschr  : int;
  vM          : float;
  vPreisFakt  : float;
  vDirektVorg : int;

  vSetEtk     : logic;
  vSetAF      : logic;
  vSetRest    : logic;
  vSetVpg     : logic;
  vSetAnalyse : logic;
  vSetRAD     : logic;
  
  v400        : int;
  v401        : int;
  vZielMEH    : alpha;
end;
begin DoLogProc;

  vAktID # BAG.IO.ID;

  // Bruder-Ausbringung ansehen
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
//debug('read IO A:'+cnvai(bag.io.nummer)+'/'+cnvai(bag.io.ID))
  Erx # RecRead(701,1,0);
  if (erx<>_rOK) then begin
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
    RETURN false;
  end;

  // Ursprung holen
  BAG.IO.Nummer # BAG.IO.Nummer;
  BAG.IO.ID     # BAG.IO.UrsprungsID;
//debug('read IO B:'+cnvai(bag.io.nummer)+'/'+cnvai(bag.io.ID));
  Erx # RecRead(701,1,0);
  if (erx<>_rOK) then begin
    Error(707101,AInt(BAG.IO.UrsprungsID)); // ST 2009-02-03
    RETURN false;
  end;

/*
  if (BAG.IO.MaterialNr=0) then begin
    Error(019999,'Ursprung nicht gefunden!');
    RETURN false;
  end;
  vVorNr  # BAG.IO.MaterialNr;
*/

  // Restore Bruder
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
  Erx # RecRead(701,1,0);

  vStatus # c_Status_BAGOutput;
  if (BAG.IO.NachBAG<>0) then begin     // Weiterbearbeitung?
    vBuf702 # RekSave(702);

    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      vNextAktion   # BAG.P.Aktion;
      // TODO nextAktRes # ArG.Typ.ReservInput     if (ArG.Aktion2<>BAG.P.Aktion2) then  erx # RecLink(828,702,8,_recFirst);
      vNextVSB      # BAG.P.Typ.VSBYN;
      if (BAG.P.Aktion=c_BAG_Versand) then begin
        // ST 2021-10-08 Projekt 2166/99
        //  Falls aktuelle Fertigung eine Kommission hat, dann die Zielanschrift der Kommission nehmen, BAG P als Fallback
        vVSDAdr     # BAG.P.Zieladresse;
        vVSDAnschr  # BAG.P.Zielanschrift;
/*** 02.11.2021 AH
        if (BAG.F.Kommission <> '') then begin
          v400 # RekSave(400);
          v401 # RekSave(401);
          Erx # Auf_Data:Read(BAG.F.Auftragsnummer,BAG.F.Auftragspos,true);
          if (Erx = 401) then begin
            vVSDAdr     # Auf.Lieferadresse;
            vVSDAnschr  # Auf.Lieferanschrift;
          end;
          RekRestore(v401);
          RekRestore(v400);
        end;
***/
      end;
      vNextLFAVK  # (BAG.P.Aktion=c_BAG_Fahr) and (BAG.P.ZielVerkaufYN);
      vStatus # BA1_Mat_Data:StatusLautEinsatz(BAG.P.Aktion,BAG.P.Auftragsnr);
    end;

    RekRestore(vBuf702);
  end;

  if (aMatNr=0) then begin
    // neue Nummer bestimmen
    vNeueNr # Lib_Nummern:ReadNummer('Material');
    if (vNeueNr<>0) then begin
      Lib_Nummern:SaveNummer()
    end
    else begin
      Error(902001,'Material|'+LockedBy);     // ST 2009-02-03
      RETURN false;
    end;
  end
  else begin
    vNeueNr # aMatnr;
  end;



  // Mat-Aktionsliste füllen -----------------------------------------------
  // Einsatz holen...
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.InputID;
  Erx # RecRead(701,1,0);
  if (erx<>_rOK) then begin
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.InputID));
    RETURN false;
  end;

  // Restkarte holen...
  Erx # RecLink(200,701,11,_RecFirst);
  if (erx>_rLocked) then begin
    // Einsatzkarte holen...
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
    if (erx<200) then begin
      Error(010040,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.IO.Materialnr));
      RETURN false;
    end;
  end;

//xxx  vVorNr              # Mat.Nummer;
//xebug('Material: '+cnvai(mat.nummer)+'   ID :'+cnvai(bag.io.id));
//xebug('BA IO Rest: '+cnvai(BAG.IO.MaterialRstNr));
  if (BAG.IO.BruderID=0) then
    vVorNr              # BAG.IO.Materialnr;//Mat.Nummer
  else
    vVorNr              # "Mat.Vorgänger";

//xebug('bruderID: '+cnvai(bag.io.bruderid)+'   vorNr:'+cnvai(vVorNr));
  if (BAG.BuchungsAlgoNr=3) then      // 19.08.2020 AH:
    vVorNr              # BAG.IO.Materialnr;


  // Aktion anlegen...
  if (vVorNr<>Mat.Nummer) then begin
    Erx # Mat_Data:Read(vVorNr);
    if (erx<200) then begin
      Error(707101,AInt(vVorNr));   // ST 2009-02-03
      RETURN false;
    end;
  end;


  RecBufClear(204);
//  Mat.A.Aktionsmat    # Mat.Nummer;
  Mat.A.Aktionsmat    # vVorNr;
  Mat.A.Entstanden    # vNeueNr;
  Mat.A.Aktionstyp    # c_Akt_BA_Fertig;
  Mat.A.Aktionsnr     # BAG.FM.Nummer;
  Mat.A.Aktionspos    # BAG.FM.Position;
  Mat.A.Aktionspos2   # BAG.FM.Fertigung;
  Mat.A.Aktionspos3   # BAG.FM.Fertigmeldung;
  Mat.A.Aktionsdatum  # BAG.FM.Datum;
  Mat.A.Aktionszeit   # BAG.FM.Zeit;
  Mat.A.TerminStart   # BAG.FM.Datum;
  Mat.A.TerminEnde    # BAG.FM.Datum;

  if (VwA.Nummer<>BAG.FM.Verwiegungart) then begin
    Erx # RekLink(818,707,6,_recfirst);     // Verwiegungsart holen
    if (Erx>_rLocked) then VwA.NettoYN # y;
  end;
  if (VWa.NettoYN) then
    Mat.A.Gewicht     # BAG.FM.Gewicht.Netto
  else
    Mat.A.Gewicht     # BAG.FM.Gewicht.Brutt;

  "Mat.A.Stückzahl"   # "BAG.FM.Stück";
  if (Mat.MEH='Stk') then
    Mat.A.Menge       # cnvfi("Mat.A.Stückzahl")
  else if (Mat.MEH='kg') then
    Mat.A.Menge       # Rnd(Mat.A.Gewicht, set.Stellen.Menge)
  else if (Mat.MEH='t') then
    Mat.A.Menge       # Rnd(Mat.A.Gewicht / 1000.0, set.Stellen.Menge)
  else if (Mat.MEH=BAG.FM.MEH) then
    Mat.A.Menge       # Rnd(BAG.FM.Menge, set.Stellen.Menge)
  else if (Mat.MEH=BAG.FM.MEH2) then
    Mat.A.Menge       # Rnd(BAG.FM.Menge2, set.Stellen.Menge);

  Mat.A.Bemerkung     # c_AktBem_BA_fertig;
  if (RunAFX('BAG.FM.Set.MatABemerkung','')=0) then
    Mat.A.Bemerkung # Mat.A.Bemerkung +' '+BAG.P.Aktion2;
  
  if (Mat_A_Data:Insert(0,'AUTO')<>_rOK) then begin
    RecBufClear(200);
    Error(707102,AInt(vVorNr)); // ST 2009-02-03
    RETURN false;
  end;

  // Einsatzkarte nochmal holen...
  // bzw. Restkarte holen...
  Erx # RecLink(200,701,11,_RecFirst);
  if (erx>_rLocked) then begin
    // Einsatzkarte holen...
    Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
    if (erx>=200) then Erx # _rOK;
  end;
  vDirektVorg # Mat.Nummer;

//xebug('Abm:'+cnvaf(mat.dicke)+' '+cnvaf(mat.breite)+' '+cnvaf("mat.länge"));


  // Verpackung holen
  Erx # RecLink(704,703,6,_recfirst);
  if (Erx>_rLockeD) then RecBufClear(704);

  vSetEtk     # y;
  vSetAF      # y;
  vSetRest    # y;
  vSetVpg     # y;
  vSetAnalyse # y;
  vSetRAD     # y;
  if (Set.Installname='TSC') then vSetRAD # false;
  
  // neue Karte generieren -------------------------------------------------

  // Spulenkerne behalten?
  case (BAG.P.Aktion) of    // 18.05.2022
    c_BAG_SpaltSpulen, c_BAG_Spulen, c_BAG_WalzSpulen :
      Mat.Spulbreite # BAG.FM.Spulbreite;

    c_BAG_Messen, c_BAG_Fahr, c_BAG_Check, c_BAG_Split, c_BAG_Gluehen,
    c_BAG_Pack, c_BAG_Paket, c_BAG_Bereit, c_BAG_Umlager, c_BAG_Versand : begin
    // Spule behalten!
    end;
    otherwise
      Mat.Spulbreite # 0.0;
  end;
  

  case (BAG.P.Aktion) of

    c_BAG_Paket : begin // 2023-01-05 AH
      vSetAF # false;
    end;

    c_BAG_Bereit : begin
      vSetRad # false;
    end;


    c_BAG_MatPrd : begin
      vSetEtk     # false;
      vSetAF      # false;
      vSetRest    # false;
      vSetVpg     # false;
      vSetAnalyse # false;
      vSetRAD     # false;
    end;


    c_BAG_AbCoil : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      Mat.RID # BAG.FM.RID;
      Mat.RAD # BAG.FM.RAD;
      vSetRAD     # false;
    end;


    c_BAG_Ablaeng : begin
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.LängenTol.Von", var "Mat.LängenTol.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      Mat.RID # BAG.FM.RID;
      Mat.RAD # BAG.FM.RAD;
      vSetRAD     # false;
    end;


    c_BAG_Saegen : begin
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.LängenTol.Von", var "Mat.LängenTol.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      // 2022-10-26 AH vSetRAD     # false;
      Mat.RID # BAG.FM.RID;
      Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_Divers : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      //  ST 2021-12-22 Bei Divers auch Endabmessungen übernehmen, wenn Fertigung keine Breite vorgegeben hat
      if (BAG.F.Breite<>0.0) OR  ((BAG.F.Breite=0.0) AND (BAG.FM.Breite <> 0.0))  then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_Fahr, c_BAG_Fahr09 : begin
      Mat.Lageradresse   # BAG.P.Zieladresse;
      Mat.Lageranschrift # BAG.P.Zielanschrift;
      Mat.LagerStichwort # BAG.P.Zielstichwort;
      Mat.Eingangsdatum  # BAG.FM.Datum;
      vSetEtk # false;
      vSetVpg # (BAG.Vpg.Nummer<>0);
      vSetAF  # false;
      vSetRAD # false;
    end;


    c_BAG_Kant : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_Obf, c_BAG_Gluehen : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_SpaltSpulen,    c_BAG_Spalt : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_Tafel : begin
      // 2023-01-27 AH : bei Formteilen gibt es gar keine Abmessungen d.h. die werden genullt!
//      if (BAG.Fm.Dicke=0.0) and (BAG.F.Dicke=0.0) and
      if (BAG.F.Breite=0.0) and (BAG.FM.Breite=0.0) and ("BAG.F.Länge"=0.0) and ("BAG.FM.Länge"=0.0) then begin
//        BAG.FM.Dicke          # -1.0;
        BAG.FM.Breite         # -1.0;
        "BAG.FM.Länge"        # -1.0;
      end;
      if (BAG.F.Dicke<>0.0) or (BAG.FM.Dicke<>0.0) then begin     // 22.06.2022 AH, oder wenn FM.Abemssung vorhanden
        BAG.FM.Dicke        # max(BAG.FM.Dicke, 0.0);
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
//      if (BAG.F.Fertigung<999) or
      if (BAG.F.Breite<>0.0) or (BAG.FM.Breite<>0.0) then begin
        BAG.FM.Breite         # max(BAG.FM.Breite, 0.0);
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
//      if (BAG.F.Fertigung<999) or
      if ("BAG.F.Länge"<>0.0) or ("BAG.FM.Länge"<>0.0) then begin
        "BAG.FM.Länge"        # max("BAG.FM.Länge", 0.0);
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      Mat.RID # BAG.FM.RID;
      Mat.RAD # BAG.FM.RAD;
      vSetRAD     # false;
    end;


    c_BAG_Pack : begin
      if (BAG.F.Dicke<>0.0) then begin
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      // 12.04.2016 AH
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
    end;


    c_BAG_WalzSpulen : begin
      Mat.Dicke             # BAG.FM.Dicke;
      Mat.Dickentol         # BAG.F.Dickentol;
      MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      "Mat.Länge"             # "BAG.FM.Länge";
      "Mat.Längentol"         # "BAG.F.Längentol";
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_Walz, c_BAG_Schael : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke             # BAG.FM.Dicke;
        Mat.Dickentol         # BAG.F.Dickentol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      "Mat.Länge"             # "BAG.FM.Länge";
      "Mat.Längentol"         # "BAG.F.Längentol";
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;


    c_BAG_QTeil : begin
      if (BAG.F.Dicke<>0.0) then begin
        Mat.Dicke           # BAG.FM.Dicke;
        Mat.Dickentol       # BAG.F.DickenTol;
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
      end;
      if (BAG.F.Breite<>0.0) then begin
        Mat.Breite            # BAG.FM.Breite;
        Mat.Breitentol        # BAG.F.BreitenTol;
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
      end;
      if ("BAG.F.Länge"<>0.0) then begin
        "Mat.Länge"           # "BAG.FM.Länge";
        "Mat.Längentol"       # "BAG.F.Längentol";
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
      if ("BAG.F.Güte"<>'') then
        "Mat.Güte"            # "BAG.F.Güte";
      if ("BAG.F.Gütenstufe"<>'') then
        "Mat.Gütenstufe"      # "BAG.F.Gütenstufe";
      if (BAG.FM.RID<>0.0) then Mat.RID # BAG.FM.RID;
      if (BAG.FM.RAD<>0.0) then Mat.RAD # BAG.FM.RAD;
    end;

    c_BAG_Check : begin
      // 23.11.2021
      if (BAG.FM.Dicke.1 + BAG.FM.Dicke.2 + BAG.FM.Dicke.3<>0.0) or
        (BAG.FM.Breite.1 + BAG.FM.Breite.2 + BAG.FM.Breite.3<>0.0) or
        ("BAG.FM.Länge.1" + "BAG.FM.Länge.2" + "BAG.FM.Länge.3"<>0.0) then begin
        MinMaxVon3(BAG.FM.Dicke.1, BAG.FM.Dicke.2, BAG.FM.Dicke.3, var Mat.Dicke.Von, var Mat.Dicke.Bis);
        MinMaxVon3(BAG.FM.Breite.1, BAG.FM.Breite.2, BAG.FM.Breite.3, var Mat.Breite.Von, var Mat.Breite.Bis);
        MinMaxVon3("BAG.FM.Länge.1", "BAG.FM.Länge.2", "BAG.FM.Länge.3", var "Mat.Länge.Von", var "Mat.Länge.Bis");
      end;
    end;

  end;  // switch BAG.P.Aktion


  // 19.06.2020 AH:
  if (Set.BA.Ziel.AktivJN) and (BAG.P.Zieladresse<>0) then begin
    Mat.Lageradresse   # BAG.P.Zieladresse;
    Mat.Lageranschrift # BAG.P.Zielanschrift;
    Mat.LagerStichwort # BAG.P.Zielstichwort;
  end;


  // ANALYSE SETZEN ------------------------------------------------
  // Arbeitsgang holen
  if (vSetAnalyse) then begin
    if (ArG.ClearMechanik2) then
      Mat_Data:ClearAnalyse(y);   // 2. Analyse leeren

    // ggf. Analyse eintregen
    if (BAG.FM.Analysenummer<>0) then begin
      // 18.03.2019 AH: Analyse ZWEI, nicht eins
      Mat.Analysenummer2 # BAG.FM.Analysenummer;
      Lys_Data:CopyToMat();
      // 17.12.2018 AH:
      if (Mat.AnalyseNummer2=Lys.K.Analysenr) and (Lys.K.Lieferant=0) then begin
        Erx # RecRead(230,1,_recLock);
        if (Erx=_rOK) then begin
          Lys.K.Chargennummer   # Mat.Chargennummer;
          Lys.K.Coilnummer      # Mat.Coilnummer;
          Lys.K.Lieferant       # Mat.Lieferant;
          Erx # RekReplace(230);
        end;
        if (Erx<>_rOK) then begin         // 2022-07-05 AH DEADLOCK
          RecBufClear(200);
          Error(1010,thisline);
          RETURN false;
        end;
      end;
    end;
  end;


  // AUSFÜHRUNGEN SETZEN ------------------------------------------------
//  if (BAG.P.aktion=c_BAG_Fahr) or (BAG.P.aktion=c_BAG_Fahr09) then begin
  if (vSetAF=false) then begin
    // Ausführungen kopieren ********************
    if (Mat_Data:CopyAF(vNeueNr)=false) then begin
      RecBufClear(200);
      Error(999999,thisline);
      RETURN false;
    end;
  end
  else begin
    "Mat.AusführungOben"  # BAG.FM.AusfOben;
    "Mat.AusführungUnten" # BAG.FM.AusfUnten;
    // Ausführung kopieren
    Erx # RecLink(705, 707, 13, _recFirst);
    WHILE (erx<=_rLocked) do begin
      RecBufClear(201);
      Mat.AF.Nummer       # vNeueNr;
      Mat.AF.Seite        # BAG.AF.Seite;
      Mat.AF.lfdNr        # BAG.AF.lfdNr;
      Mat.AF.ObfNr        # BAG.AF.ObfNr;
      Mat.AF.Bezeichnung  # BAG.AF.Bezeichnung;
      Mat.AF.Zusatz       # BAG.AF.Zusatz;
      Mat.AF.Bemerkung    # BAG.AF.Bemerkung;
      "Mat.AF.Kürzel"     # "BAG.AF.Kürzel";
      REPEAT
        Erx # RekInsert(201,0,'AUTO');
        if (Erx=_rDeadLock) then begin
          RecBufClear(200);
          Error(1010,thisline);
          RETURN false;
        end;
        if (Erx<>_rOK) then Mat.AF.lfdNr # Mat.AF.lfdNr + 1;
      UNTIL (Erx=_rOK);
      Erx # RecLink(705, 707, 13, _recNext);
    END;
  end;

  // RESTLICHE DATEN SETZEN ------------------------
  if (vSetRest) then begin
    Mat.Lagerplatz        # BAG.FM.Lagerplatz;
    Mat.Verwiegungsart    # BAG.FM.Verwiegungart;
    Mat.ResttafelYN       # BAG.FM.ResttafelYN;

    if (BAG.F.Warengruppe<>0) then
      Mat.Warengruppe     # BAG.F.Warengruppe;

    if (BAG.FM.Werksnummer<>'') then
      Mat.Werksnummer     # BAG.FM.Werksnummer;

    // nur Kommission umsetzen, wenn gefüllt...sont BEHALTEN
    if (BAG.F.Kommission<>'') then begin
      Mat.Kommission        # BAG.F.Kommission;
      Mat.Auftragsnr        # BAG.F.Auftragsnummer;
      Mat.Auftragspos       # BAG.F.Auftragspos;
      Mat.Auftragspos2      # BAG.F.AuftragsFertig;
    end;

    // Lohnmaterial wird Eigentum
    if (BAG.F.WirdEigenYN) and (Mat.EigenmaterialYN=n) then begin
      Mat.EigenmaterialYN   # y;
      "Mat.Übernahmedatum"  # BAG.FM.Datum;
      vBuf100 # RecBufCreate(100);
      vBuf100->Adr.Nummer # Set.EigeneAdressnr;
      RecRead(vBuf100,1,0);
      Mat.Lieferant         # vBuf100->Adr.Lieferantennr;
      RecBufDestroy(vBuf100);
      vBuf100 # 0;
    end;
  end;  // SetRest


  // VERPACKUNGSDATEN SETZEN ---------------------------------------------

  // 20.07.2012 AI : beim Fahren gibt es diese Daten nicht! Projekt 1161/403
//  if (BAG.P.Aktion<>c_BAG_Fahr) then begin
  if (vSetEtk) then begin
    Mat.Rechtwinkligkeit  # BAG.FM.Rechtwinklig;
    Mat.Ebenheit          # BAG.FM.Ebenheit;
    "Mat.Säbeligkeit"     # "BAG.FM.Säbeligkeit";
    "Mat.SäbelProM"       # "BAG.FM.SäbelProM";
    "Mat.Etk.Güte"        # "BAG.F.Etk.Güte";
    Mat.Etk.Dicke         # BAG.F.Etk.Dicke;
    Mat.Etk.Breite        # BAG.F.Etk.Breite;
    "Mat.Etk.Länge"       # "BAG.F.Etk.Länge";
  end;

  // 20.07.2012 AI : Verpackung beim Fahren nur nehmen, wenn wirklich vorhanden! Projekt 1161/403
//  if (BAG.P.Aktion<>c_BAG_Fahr) or (BAG.Vpg.Nummer<>0) then begin
  if (vSetVpg) and (BAG.Vpg.Nummer<>0) then begin   // 23.02.2022 AH, auch nur wenn Datensatz da
    Mat.AbbindungL        # BAG.VPG.AbbindungL;
    Mat.AbbindungQ        # BAG.VPG.AbbindungQ;
    Mat.Zwischenlage      # BAG.VPG.Zwischenlage;
    Mat.Unterlage         # BAG.VPG.Unterlage;
    Mat.StehendYN         # BAG.VPG.StehendYN;
    Mat.LiegendYN         # BAG.VPG.LiegendYN;
    Mat.Nettoabzug        # BAG.VPG.Nettoabzug;
    "Mat.Stapelhöhe"      # "BAG.VPG.Stapelhöhe";
    "Mat.Stapelhöhenabzug"# "BAG.VPG.StapelhAbzug";
    Mat.Umverpackung      # BAG.VPG.Umverpackung;
    Mat.Wicklung          # BAG.VPG.Wicklung;
    Mat.Etikettentyp      # BAG.Vpg.Etikettentyp;
    if (Set.Installname='BSP') then begin
      if (Mat.Etikettentyp = 0) then Mat.Etikettentyp # 110;
    end
    else begin
      if (Mat.Etikettentyp = 0) and (BAg.F.Kommission<>'') then Mat.Etikettentyp # 100;
    end;

    // ST 2022-11-22 BugFix: Bemerkungsteil war hier

  end;

  // ST 2022-11-22 BugFix: Bemerkungsteil ist jetzt unabhängig der Verpackung
  if (BAG.FM.Bemerkung <> '') then begin
    if (Mat.Bemerkung2='') or (BAG.P.Aktion=c_BAG_Check) then begin
      Mat.Bemerkung2 # 'PrdBem: '+BAG.FM.Bemerkung;
    end
    else begin
      Mat.Bemerkung2 # StrCut(StrAdj(Mat.Bemerkung2 + ' PrdBem: '+BAG.FM.Bemerkung,_StrBegin), 1, 72);
    end;
  end;
  
  if (Set.Installname='BSP') and ((BAG.P.Aktion=c_Bag_Fahr) and (BAG.P.ZielVerkaufYN=false)) then
    if (Mat.Etikettentyp = 0) then Mat.Etikettentyp # 110;


 // ST 2022-07-21 2314/18: Dirty Fix für WSB  wegen Urlaubsvertretung
  if (Set.Installname='WSB') AND (Mat.Etikettentyp = 0) AND (BAg.F.Kommission<>'') then
    Mat.Etikettentyp # 100;
    

  // ST 2013-03-15: Bei "Back In Stock" - Verwiegung soll ein Eingangsetikett gedruckt werden, falls ungeplant
  if (vSetRest) then begin
    if (Mat.Etikettentyp = 0) AND (BAG.FM.Fertigung > 900) then
      Mat.Etikettentyp # Set.Ein.WE.Etikett;
    if (Mat.Etikettentyp = 0) then
      Mat.Etikettentyp # Set.BA.FM.Frei.Etk;
  end;


  // GRUNDLEGENDES SETZEN ------------------------
  Mat.Nummer            # vNeueNr;
  "Mat.Vorgänger"       # vVorNr;
  Mat_Data:SetLoeschmarker('');
  Mat.Ausgangsdatum     # 0.0.0;
//  if (BAG.FM.Status=1) and (BAG.P.Aktion=c_BAG_Fahr) then begin // 2022-12-21 AH
// 2023-02-06 AH WARUM???     Mat.Ausgangsdatum     # today;
//  end;

  Mat.Paketnr           # aPaknr;
  if (BAG.F.KundenartNr<>'') then Mat.KundenArtNr       # BAG.F.KundenArtNr;
  
  // MENGEN SETZEN ---------------------------
  Mat.Bestand.Stk       # "BAG.FM.Stück";;

//  if (Mat.MEH=BAG.FM.MEH) then
//    Mat.Bestand.Menge   # BAG.FM.Menge
//  else if (Mat.MEH=BAG.FM.MEH2) then
//    Mat.Bestand.Menge   # BAG.FM.Menge2
//  else
//    Mat.Bestand.Menge   # 0.0;

  Mat.Reserviert.Stk    # 0;
  Mat.Reserviert2.Stk   # 0;
  Mat.Reserviert.Gew    # 0.0;
  Mat.Reserviert2.Gew   # 0.0;
  Mat.Reserviert.Menge  # 0.0;
  Mat.Reserviert2.Meng  # 0.0;
  Mat.Gewicht.Netto     # BAG.FM.Gewicht.Netto;
  Mat.Gewicht.Brutto    # BAG.FM.Gewicht.Brutt;
  // 16.01.2019 AH
//  Mat.Bestand.Gew       # -1.0;        // freimachen zur Berechnung
  if (VWa.NettoYN) then
    Mat.Bestand.Gew   # Mat.Gewicht.Netto
  else
    Mat.Bestand.Gew     # Mat.Gewicht.Brutto;


  // 2023-01-19
// 2023-03-21 AH  vZielMEH # BAG.F.MEH;
  vZielMEH # BAG.IO.MEH.In;
 
  if (BAG.FM.Artikelnr<>'')  then begin
    Mat.Strukturnr      # BAG.FM.Artikelnr;
    // ST 2013-07-26: Artikelmeh nur lesen, wenn Wgr Materialtyp <> 200 ist
    RekLink(819,200,1,0); // Warengruppe lesen
    if (Wgr.Dateinummer <> 200) then begin
      Erx # RekLink(250,200,26,_recFirst);  // Artikel holen
      if (Erx>_rLocked) then begin
        Mat.Strukturnr # '';
      end
      else begin  // 24.06.2015
        vZielMEH # Art.MEH;
      end;
    end;
  end;
  if (Mat.Strukturnr='-') then begin
    Mat.Strukturnr      # '';
    vZielMEH            # 'kg';
  end;

//debugx(BAG.FM.MEH+'/'+bag.fm.meh2+' nach '+vZielMEH);
  if (Mat.MEH<>vZielMEH) then begin // or
//    ((vZielMEH<>'t') and (vZielMEH<>'kg')) then begin   // 2023-01-23 AH wenn z.B: Stk->Stk
//          if (Mat.MEH=vZielMEH) then vPreisFakt # 1.0 else
          if (Mat.MEH='kg') and (vZielMEH='t') then vPreisFakt # 1000.0
          else if (Mat.MEH='t') and (vZielMEH='kg') then vPreisFakt # 0.001;
//debugx('KEY200 '+anum(Mat.EK.Preis,2)+'/t ; '+anum(mat.ek.preispromeh,2)+'/'+Mat.MEH+'  fakt:'+anum(vPreisFakt,3));
          if (vPreisfakt<>0.0) then begin
            Mat.EK.PreisProMEH    # Rnd(Mat.EK.PreisProMEH * vPreisFakt,2);
            Mat.KostenProMEH      # Rnd(Mat.KostenProMEH * vPreisFakt,2);
            Mat.EK.EffektivProME  # Rnd(Mat.EK.EffektivProME * vPreisFakt,2);
          end
          else begin  // 2023-01-19 AH MEH wird verändert!
            if (vZielMEH=BAG.FM.MEH) then
              vM # BAG.FM.Menge
            else if (vZielMEH=BAG.FM.MEH2) then
              vM # BAG.FM.Menge2
            else if (vZielMEH='Stk') then
              vM # cnvfi("BAG.Fm.Stück");
            else if (vZielMEH='t') and (BAG.FM.MEH='kg') then
              vM # BAG.FM.Menge / 1000.0
            else if (vZielMEH='t') and (BAG.FM.MEH2='kg') then
              vM # BAG.FM.Menge2 / 1000.0;
            else if (vZielMEH='kg') and (BAG.FM.MEH='t') then
              vM # BAG.FM.Menge * 1000.0;
            else if (vZielMEH='kg') and (BAG.FM.MEH2='t') then
              vM # BAG.FM.Menge2 * 1000.0;
            else begin
//debugx('wandle!');
              vM # Rnd( Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, vZielMEH) ,Set.Stellen.Menge);
           end;
           Mat.Bestand.Menge # vM;
/*
            vPreisFakt # Mat.EK.PreisproMEH;
            Mat.EK.PreisproMEH # 0.0;
            if (vM<>0.0) then begin // Kosten auch anpassen
              Mat.EK.PreisproMEH # Rnd(aEKWert / vM,2);
              if (vPreisFakt<>0.0) then begin
                vPreisfakt # Mat.EK.PreisProMEH / vPreisFakt;
                Mat.KostenproMEH      # Mat.KostenproMEH * vPreisFakt;
                Mat.EK.EffektivProME  # Mat.EK.PreisProMEH + Mat.KostenproMEH;
              end;
            end;
*/
          end;
          Mat.MEH               # vZielMEH;
//        end;
//      end;
//    end;
    Mat.EK.PreisProMEH    # 0.0;
    Mat.KostenProMEH      # 0.0;
    Mat.EK.EffektivProME  # 0.0;
    if (Mat.Bestand.Gew<>0.0) then begin
       vPreisFakt # Mat.EK.Preis;
       Mat.EK.Preis        # aEKWert / Mat.Bestand.Gew * 1000.0;
      if (vPreisFakt<>0.0) then begin
        vPreisfakt      # Mat.EK.Preis / vPreisFakt;
        Mat.Kosten      # Mat.Kosten * vPreisFakt;
        Mat.EK.Effektiv # Mat.EK.Preis + Mat.Kosten;
      end;
    end;
  end   // MEH-Wechsel
  else begin    // 2023-04-27  AH
            if (vZielMEH=BAG.FM.MEH) then
              vM # BAG.FM.Menge
            else if (vZielMEH=BAG.FM.MEH2) then
              vM # BAG.FM.Menge2
            else if (vZielMEH='Stk') then
              vM # cnvfi("BAG.Fm.Stück");
            else if (vZielMEH='t') and (BAG.FM.MEH='kg') then
              vM # BAG.FM.Menge / 1000.0
            else if (vZielMEH='t') and (BAG.FM.MEH2='kg') then
              vM # BAG.FM.Menge2 / 1000.0;
            else if (vZielMEH='kg') and (BAG.FM.MEH='t') then
              vM # BAG.FM.Menge * 1000.0;
            else if (vZielMEH='kg') and (BAG.FM.MEH2='t') then
              vM # BAG.FM.Menge2 * 1000.0;
            else begin
//debugx('wandle!');
              vM # Rnd( Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, vZielMEH) ,Set.Stellen.Menge);
           end;
           Mat.Bestand.Menge # vM;
  end;
//debugx('neues Mat:'+anum(Mat.Bestand.Menge,2));


  // RAD ERRECHNEN ------------------------------------------------- 16.01.2019 AH
  if (vSetRAD) and (Mat.RID<>0.0) and (BAG.FM.RAD=0.0) then begin
    // 2023-02-09 AH : nur Coils mit RAD errechnen, Proj. 2483/4
    Erx # RekLink(819,200,1,_recFirst);   // Warengruppe holen
    if (Wgr.Materialtyp='') or (Wgr.Materialtyp='CO') then begin
      Mat.RAD # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(Mat.Bestand.Gew, Mat.Bestand.Stk, Mat.Breite, Mat.Dichte, Mat.RID);
    end;
  end;

  if (BAG.FM.Status=1) then begin     // "Gut"-Verwiegung
    Mat_Data:SetStatus(vStatus);      // auf fertig setzen
    // ST 2009-08-13    Projekt: 1161/95
    // Fertigmeldung von geplanten Schrottkarten
    // Material bekommt Status "SCHROTT" und wird nicht gelöscht
    if (Bag.F.PlanSchrottYN) then begin
      Mat_Data:SetLoeschmarker('');             // Nicht löschen
      Mat_Data:SetStatus(c_Status_BAGSchrott);  // Status Schrott
    end;
  end
  else begin                      // "schlechte"-Verwiegungen
    Mat_Data:SetStatus(BAG.FM.Status);
  end;

  // RINGNUMMER ERZEUGEN...
  Mat.EtikettId # 0;
  //  Mat.Ringnummer # cnvai("Mat.Vorgänger",_FmtNumNoGroup)+'/'+cnvai(BAG.F.Fertigung,_FmtNumNoGroup,0,2)+'/';
  // Ankerfunktion starten
  RunAFX('BAG.FM.NeuesMat',aint(vDirektVorg));

  Mat.Nummer            # vNeueNr;
  Erx # Mat_Data:Insert(0,'AUTO',BAG.FM.Datum, aInvDat)
  if (erx<>_rOK) then begin
    RecBufClear(200);
    Error(707103,'');
    RETURN false;
  end;
//debugx('KEY200 '+anum(Mat.EK.PreisProMEH,2)+'pm * '+anum(mat.bestand.Menge,2)+mat.MEH+' zu '+anum(mat.ek.preis,2)+'pt * '+anum(Mat.Bestand.gew,3)+'kg');
                                                            // machnmal ROLLBACK?
  // Ankerfunktion starten
  RunAFX('BAG.FM.NeuesMat.Post','');

  // Ausfall löschen...
  if (BAG.FM.Status=c_Status_BAGAusfall) then begin
    Erx # RecRead(200,1,_recSingleLock);
    if (Erx=_rOK) then begin
      Mat.Ausgangsdatum   # BAG.FM.Datum
//debugx('AUSGANG KEY200');
      Mat_Data:SetLoeschmarker('*');
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      Error(707103,'');
      RETURN false;
    end;
  end;
  if (Mat.Status=c_Status_VSB) then begin
    vVSBAktBuf # RekSave(404);
  end;

  // Aktion für Beistellungskosten?
  if (aBeistellKosten<>0.0) then begin
    RecBufClear(204);
    Mat.A.Aktionsmat    # vNeueNr;
    Mat.A.Entstanden    # 0;
    Mat.A.Aktionstyp    # c_Akt_BA_Beistell;
    Mat.A.Aktionsnr     # BAG.FM.Nummer;
    Mat.A.Aktionspos    # BAG.FM.Position;
    Mat.A.Aktionspos2   # BAG.FM.Fertigung;
    Mat.A.Aktionspos3   # BAG.FM.Fertigmeldung;
    Mat.A.Aktionsdatum  # BAG.FM.Datum;
    Mat.A.Aktionszeit   # BAG.FM.Zeit;
    Mat.A.Bemerkung     # c_AktBem_BABeistell;
    if (Mat.Bestand.Gew<>0.0) then
      Mat.A.KostenW1    # aBeistellKosten / Mat.Bestand.Gew * 1000.0;
    if (Mat_A_Data:Insert(0,'AUTO')<>_rOK) then begin
      Error(707102,AInt(vVorNr)); // ST 2009-02-03
      RETURN false;
    end;
    if (Mat_A_Data:Vererben()=false) then begin
      Error(707102,AInt(vVorNr)); // ST 2009-02-03
      RETURN false;
    end;
  end;

//  BspBug: bis hier passiert NICHT

  // Vorgängerkosten dieses BAs in die neue Karte kopieren...
  if (BAG.BuchungsAlgoNr<>3) then
    BA1_Kosten:HoleVorgaengerKosten();

  // evtl. Material reservieren?
  if (vNextAktion=c_BAG_Fahr09) then begin  // TODO ArG.Typ.ReservInput : or vNextAktRes
    // Reservieruen für FAHREN NACH Anlage weiter unten....
  end
  else if (BAG.FM.Status=1) and (BAG.F.ReservierenYN) and (BAG.F.Auftragsnummer=0) and (BAG.P.Aktion<>c_BAG_Fahr09) then begin
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    "Mat.R.Trägertyp"     # '';
    "Mat.R.TrägerNummer1" # 0;
    "Mat.R.TrägerNummer2" # 0;
    Mat.R.Kundennummer    # "BAG.F.ReservFürKunde";
    vBuf100 # RecBufCreate(100);
    RecLink(vBuf100,203,3,_recFirst); // Kunde holen
    Mat.R.KundenSW        # vBuf100->Adr.Stichwort;
    RecBufDestroy(vBuf100);
    Mat.R.Auftragsnr      # BAG.F.Auftragsnummer;
    Mat.R.AuftragsPos     # BAG.F.AuftragsPos;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707104,AInt(Mat.Nummer));
      RETURN false;
   end;
  end;

  // theoretischen Output ändern -------------------------------------------
  RecBufClear(701);
  BAG.IO.Nummer         # BAG.FM.Nummer;
  BAG.IO.ID             # BAG.FM.BruderID;

  // MatPrd muss die einzelnen Entnahmemengen HIER nicht als FERTIG addieren!!
/*  if (BAG.P.Aktion=c_BAG_MatPrd) or
     (BAG.P.Aktion<>c_BAG_Spulen) then begin
    Erx # RecRead(701,1,0);
    if (erx<>_rOK) then begin
      Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
      RETURN false;
    end;
  end
  else begin
*/
    Erx # RecRead(701,1,_recSingleLock);
    if (erx<>_rOK) then begin
      Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
      RETURN false;
    end;
    if (BAG.P.Aktion<>c_BAG_Spulen) and (BAG.P.Aktion<>c_BAG_Paket) then
      BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + "BAG.FM.Stück";
    BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + BAG.FM.Gewicht.Netto;
    BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + BAG.FM.Gewicht.Brutt;
    if (BAG.FM.Meh=BAG.IO.MEH.In) then
      BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + BAG.FM.Menge;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');     // BspBug: vielleicht?
    if (erx<>_rOK) then begin
      Error(707105,'');
      RETURN false;
    end;
//  end;


  // 16.07.2019 AH:
  if (vNextVSB) then begin
    v702 # RekSave(702);
    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      BA1_F_Data:UpdateVSB(false);      // BspBug: vielleicht?
    end;
    RekRestore(v702);
  end;


  // neuen IO-Posten anlegen -----------------------------------------------
  BAG.IO.VonID # vAktID;

  BAG.IO.VonBAG         # BAG.FM.Nummer;
  BAG.IO.VonPosition    # BAG.FM.Position;
  BAG.IO.VonFertigung   # BAG.FM.Fertigung;
  BAG.IO.VonFertigmeld  # BAG.FM.Fertigmeldung;

  // SPERRE?
  if (BAG.FM.Status<>1) then begin
    BAG.IO.NachBAG        # 0;
    BAG.IO.NachPosition   # 0;
    BAG.IO.NachFertigung  # 0;
    BAG.IO.NachID         # 0;
  end;

  BAG.IO.ID             # 1;
  BAG.IO.Materialtyp    # c_IO_Mat;
  BAG.IO.Materialnr     # vNeueNr;
  BAG.IO.MaterialRstnr  # vNeueNr;
  BAG.IO.BruderID       # BAG.FM.BruderID;

  BAG.IO.Ist.IN.Stk     # "BAG.FM.Stück";
  BAG.IO.Ist.IN.GewN    # BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.IN.GewB    # BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.IN) then
    BAG.IO.Ist.IN.Menge # BAG.FM.Menge
  else if (BAG.FM.Meh2=BAG.IO.MEH.IN) and (BAG.FM.MEH2<>'') then
    BAG.IO.Ist.IN.Menge # BAG.FM.Menge2
  else
    BAG.IO.Ist.IN.Menge # 0.0;

  BAG.IO.Plan.IN.Stk    # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.IN.GewN   # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.IN.GewB   # BAG.IO.Ist.IN.GewB;
  BAG.IO.Plan.IN.Menge  # BAG.IO.Ist.IN.Menge;

  BAG.IO.Plan.Out.Stk   # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Ist.IN.GewB;
  if (BAG.FM.Meh=BAG.IO.MEH.Out) then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge2
  else
    BAG.IO.Plan.Out.Meng # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);

  // 2009
  BAG.IO.Ist.Out.Stk    # 0;
  BAG.IO.Ist.Out.GewN   # 0.0;
  BAG.IO.Ist.Out.GewB   # 0.0;
  BAG.IO.Ist.Out.Menge  # 0.0;
// BspBug: passiert IMMER:
// 2022-08-09 AH
  REPEAT
    Erx # BA1_IO_Data:Insert(0,'AUTO')
    if (Erx=_rDeadLock) then begin
      Error(707106,'');
      RETURN false;
    end;
    if (Erx<>_rOK) then begin
      BAG.IO.ID # BAG.IO.ID + 1;
      CYCLE;
    end;
    BREAK;
  UNTIL (1=1);

  if (BAG.FM.Status=1) and (vNextAktion=c_BAG_Fahr09) then begin  // TODO ArG.Typ.ReservInput : or vNextRes
    // FAHR-Reservierung neu anlegen ---------------------------------------
    RecBufClear(203);
    Mat.R.Materialnr      # Mat.Nummer;
    "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
    Mat.R.Gewicht         # Mat.Bestand.Gew;
    // für MATMEH
    Mat.R.Menge           # Mat.Bestand.Menge;

    Mat.R.Bemerkung       # vNextAktion;
    "Mat.R.Trägertyp"     # c_Akt_BAInput;
    "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
    "Mat.R.TrägerNummer2" # BAG.IO.ID;
    if (Mat_Rsv_Data:Neuanlegen()=false) then begin
      Error(707106,''); // ST 2009-02-03
      RETURN false;
    end;
  end;

  vNeuID # BAG.IO.ID;

  // Fertigungsmengen erhöhen ----------------------------------------------      BspBug: passiert IMMER
  Erx # Recread(703,1,_RecSingleLock);
  if (Erx=_rOK) then begin
    BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    + BAG.FM.Gewicht.Netto;
    BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    + "BAG.FM.Stück";

    // für MATMEH
    vM # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.F.MEH);
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + vM;

    Erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    Error(707107,'');   // ST 2009-02-03
    RETURN false;
  end;

  // BA-Daten setzen -------------------------------------------------------
  Erx # RecRead(707,1,_recSingleLock);
  if (Erx=_rOK) then begin
    BAG.FM.Materialnr # vNeueNr;
    BAG.FM.OutputID   # vNeuID;
    Erx # Rekreplace(707,_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    Error(707108,'');  // ST 2009-02-03
    RETURN false;
  end;

  // Auftragsaktion anlegen ------------------------------------------------
  if (BAG.FM.Status=1) and (vStatus=c_Status_BAGOutKunde) then begin      // VSB für Auftrag!!!
    if (BAG.P.ZielVerkaufYN=n) or (BAG.P.Aktion<>c_BAG_Fahr) then begin
      if (AufVSBAktion(BAG.FM.Datum)=n) then begin
        Error(10041,AInt(BAG.F.Nummer)+'/'+AInt(BAg.F.Position)+'/'+AInt(BAG.F.Fertigung)+'|'+AInt(BAG.F.Auftragsnummer)+'/'+AInt(BAG.F.Auftragspos));
        RETURN false;
      end;
    end;
  end;


  if (vNextLFAVK) then begin
    TunnelFMdurchLFA();
  end;



  // Lohnfahrauftrag?? dann evtl. LFS refreshen
  if (BAG.FM.Status=1) and (BAG.P.Aktion=c_BAG_Fahr) then begin
    // zugehörigen Lohnlieferschein generieren...
    if (Lfs_LFA_Data:Fertigmeldung(BAG.Nummer, vNeuID, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
      RETURN false;
    end;
  end;

  // nachfolgender LFA? dann LFS updaten,,,
  // bzw. VERSAND? dann VSP updaten...
  if (BAG.FM.Status=1) and (BAG.IO.NachBAG<>0) then begin
    vBuf702 # RekSave(702);

    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      if (BAG.P.Aktion=c_BAG_Fahr) then begin
        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
          Error(707109,AInt(Bag.P.Nummer)+'/'+AInt(Bag.P.Position));
          ERROROUTPUT;  // 01.07.2019
          RETURN false;
        end;
      end;

    end;

    RekRestore(vBuf702);
  end;


  // evtl. Material in Versandpool -----------------------------------------
  if (BAG.FM.Status=1) and (vVSDAdr<>0) then begin
    // nur tatsächlich vorhandenes MAterial
    RecBufClear(655);
    VsP.Vorgangstyp       # c_VSPTyp_BAG;
    VsP.Vorgangsnr        # BAG.FM.Nummer;
    VsP.Vorgangspos1      # BAG.FM.OutputID;
    VsP.Vorgangspos2      # 0;
    VsP.Materialnr        # Mat.Nummer;
    VsP.Ziel.Adresse      # vVSDAdr;
    VsP.Ziel.Anschrift    # vVSDAnschr;
    VsP.Ziel.Lagerplatz   # '';
    VsP.Ziel.Tour         # '';
    if (VsP_Data:SavePool()=0) then begin
      RETURN false;
    end;

   vBuf702 # RekSave(702);
   Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) then begin
      VsP_Data:ErzeugePoolZumVersand();
    end;
    RekRestore(vBuf702);
  end;

  // ERFOLG!
  RETURN true;
end;


//========================================================================
//  FertigArtAnlegen    +ERR
//    CHARGE ist geladen!!!
//========================================================================
sub FertigArtAnlegen(aBeistellKosten : float) : logic
local begin
  Erx     : int;
  vBuf702 : int;
  vNeuID  : int;
  vAktID  : int;
  vOK     : logic;
  vM      : float;
end;
begin DoLogProc;

  vAktID # BAG.IO.ID;

  // Bruder-Ausbringung ansehen
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
  Erx # RecRead(701,1,0);
  if (erx<>_rOK) then begin
    Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
    RETURN false;
  end;


  // Ursprung holen
  BAG.IO.Nummer # BAG.IO.Nummer;
  BAG.IO.ID     # BAG.IO.UrsprungsID;
  Erx # RecRead(701,1,0);
  if (erx<>_rOK) then begin
    Error(707101,AInt(BAG.IO.ID));    // ST 2009-02-03
    RETURN false;
  end;


  // Restore Bruder
  BAG.IO.Nummer # BAG.FM.Nummer;
  BAG.IO.ID     # BAG.FM.BruderID;
  Erx # RecRead(701,1,0);

  // neuen Charge generieren -------------------------------------------------
  // neue Charge generieren, wenn KEIN Fahren oder Fahren KEIN Verkauf ist --------
  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    if (BAG.P.ZielVerkaufYN=n) then begin
      Art.C.Adressnr      # BAG.P.Zieladresse;
      Art.C.Anschriftnr   # BAG.P.Zielanschrift;
      Art.C.Charge.Intern # '';
    end;
  end
  else if (BAG.P.Aktion=c_BAG_ArtPrd) then begin

    Erx # RecLink(252,701,17,_recFirst);  // Charge holen
    if (erx>_rLocked) then RETURN false;

//    Art.C.Adressnr      # BAG.P.Zieladresse;
//    Art.C.Anschriftnr   # BAG.P.Zielanschrift;
    Art.C.Charge.Intern # '';
    Art.C.Zustand       # BAG.FM.Art.Zustand;
    // eigene/intnere Produkton im Haus?
    Art.C.Adressnr      # BAG.P.Zieladresse;
    Art.C.Anschriftnr   # BAG.P.Zielanschrift;
    if (Art.C.Adressnr=0) then begin
      Art.C.Adressnr    # Set.EigeneAdressnr;
      Art.C.Anschriftnr # 1;
    end;

    // ZUGANG Bewegung buchen...
    RecBufClear(253);
    Art.J.Datum           # BAG.FM.Datum;
    Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung);
    "Art.J.Stückzahl"     # "BAG.FM.Stück";
    Art.J.Menge           # BAG.FM.Menge;
    "Art.J.Trägertyp"     # c_Akt_BA;
    "Art.J.Trägernummer1" # BAG.FM.Nummer;
    "Art.J.Trägernummer2" # BAG.FM.Position;
    "Art.J.Trägernummer3" # BAG.FM.Fertigung;
    vOK # Art_Data:Bewegung(aBeistellkosten, 0.0);
    if (vOK=false) then RETURN false;

  end
  else begin
    RETURN false; // falscher Arbietsgang!!!!!!!!!!!
  end;



  // evtl. Material reservieren?
  // theoretischen Output ändern -------------------------------------------
  // im EINSATZMINDERN!!!
  // bzw. bei ArtPrd HIER:
  if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
    RecBufClear(701);
    BAG.IO.Nummer         # BAG.FM.Nummer;
    BAG.IO.ID             # BAG.FM.BruderID;
    Erx # RecRead(701,1,_recSingleLock);
    if (erx<>_rOK) then begin
      Error(010027,AInt(BAG.FM.Nummer)+'|'+AInt(BAG.FM.BruderID));
      RETURN false;
    end;
    if (BAG.P.Aktion<>c_BAG_Spulen) and (BAG.P.Aktion<>c_BAG_Paket) then
      BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + "BAG.FM.Stück";

//BAG.IO.Ist.In.Stk  # 555;
//todo('A');

    BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + BAG.FM.Gewicht.Netto;
    BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + BAG.FM.Gewicht.Brutt;
    if (BAG.FM.Meh=BAG.IO.MEH.In) then
      BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + BAG.FM.Menge;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(707105,'');
      RETURN false;
    end;
  end;


  // neuen IO-Posten anlegen -----------------------------------------------
  BAG.IO.VonID # vAktID;

  BAG.IO.VonBAG         # BAG.FM.Nummer;
  BAG.IO.VonPosition    # BAG.FM.Position;
  BAG.IO.VonFertigung   # BAG.FM.Fertigung;
  BAG.IO.VonFertigmeld  # BAG.FM.Fertigmeldung;

  BAG.IO.ID             # 1;
  BAG.IO.Materialtyp    # c_IO_Art;
  BAG.IO.Materialnr     # 0;
  BAG.IO.MaterialRstnr  # 0;

  BAG.IO.Artikelnr      # Art.C.Artikelnr;
  BAG.IO.Lageradresse   # Art.C.Adressnr;
  BAG.IO.Lageranschr    # Art.C.Anschriftnr;
  BAG.IO.Charge         # Art.C.Charge.Intern;

  BAG.IO.BruderID       # BAG.FM.BruderID;
  BAG.IO.Ist.IN.Stk     # "BAG.FM.Stück";
  BAG.IO.Ist.IN.GewN    # BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.IN.GewB    # BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.IN) then
    BAG.IO.Ist.IN.Menge # BAG.FM.Menge
  else
    BAG.IO.Ist.IN.Menge # 0.0;

  BAG.IO.Plan.IN.Stk    # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.IN.GewN   # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.IN.GewB   # BAG.IO.Ist.IN.GewB;
  BAG.IO.Plan.IN.Menge  # BAG.IO.Ist.IN.Menge;

  BAG.IO.Plan.Out.Stk   # BAG.IO.Ist.IN.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Ist.IN.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Ist.IN.GewB;
  if (BAG.FM.Meh=BAG.IO.MEH.Out) then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge
  else if (BAG.FM.MEH2=BAG.IO.MEH.Out) and (BAG.FM.MEH2<>'') then
    BAG.IO.Plan.Out.Meng # BAG.FM.Menge2
  else
    BAG.IO.Plan.Out.Meng # 0.0;

  REPEAT    // 2022-08-09 AH
    Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (Erx=_rDeadLock) then begin
      Error(707107,'');
      RETURN false;
    end;
    if (erx<>_rOK) then begin
      BAG.IO.ID # BAG.IO.ID + 1;
      CYCLE;
    end;
    BREAK;
  UNTIL (1=1);

  vNeuID # BAG.IO.ID;


  // Fertigungsmengen erhöhen ----------------------------------------------
  Erx # Recread(703,1,_RecSingleLock);
  if (Erx=_rOK) then begin
    BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    + BAG.FM.Gewicht.Netto;
    BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    + "BAG.FM.Stück";

    // für MATMEH
    vM # Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.F.MEH);
    BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + vM;

    erx # BA1_F_Data:Replace(_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    Error(707107,'');       //  ST 2009-02-03
    RETURN false;
  end;

  // BA-Daten setzen -------------------------------------------------------
  Erx # RecRead(707,1,_recSingleLock);
  if (Erx=_rOK) then begin
    BAG.FM.OutputID   # vNeuID;
    erx # Rekreplace(707,_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    Error(707108,'');  // ST 2009-02-03
    RETURN false;
  end;

  // Auftragsaktion anlegen ------------------------------------------------
  if (BAG.F.Auftragsnummer<>0) then begin      // VSB für Auftrag!!!
    if (BAG.P.ZielVerkaufYN=n) or (BAG.P.Aktion<>c_BAG_Fahr) then
      if (AufVSBAktion(BAG.FM.Datum)=n) then begin
        Error(10041,AInt(BAG.F.Nummer)+'/'+AInt(BAg.F.Position)+'/'+AInt(BAG.F.Fertigung)+'|'+AInt(BAG.F.Auftragsnummer)+'/'+AInt(BAG.F.Auftragspos));
        RETURN false;
      end;
  end;


  // Lohnfahrauftrag?? dann evtl. LFS refreshen
  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    // zugehörigen Lohnlieferschein generieren...
    if (Lfs_LFA_Data:Fertigmeldung(BAG.Nummer, vNeuID, BAG.FM.Datum, BAG.FM.Zeit)=false) then begin
      RETURN false;
    end;
  end;

  // nachfolgender LFA? dann LFS updaten
  if (BAG.IO.NachBAG<>0) then begin
    vBuf702 # RekSave(702);

    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) and (BAG.P.Aktion=c_BAG_Fahr) then begin

      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
        Error(707109,'!'); // ST 2009-02-03
        ERROROUTPUT;  // 01.07.2019
        RETURN false;
      end;
    end;

    RekRestore(vBuf702);
  end;



  // ERFOLG!
  RETURN true;
end;


//========================================================================
//  SaveFM  + ERR
//
//========================================================================
sub SaveFM(
  aMitAnalyse       : logic;
  aEntstehenWeitere : logic;
) : logic;
local begin
  Erx     : int;
  vBuf707 : int;
  v705    : int;
end;
begin

  vBuf707 # RekSave(707);

  BAG.FM.UnverbuchtYN   # true;
  BAG.FM.Nummer         # BAG.F.Nummer;
//  if (aNr<>0) then BAG.FM.Nummer # aNr;
  BAG.FM.Anlage.Datum   # today;
  BAG.FM.Anlage.Zeit    # now;
  BAG.FM.Anlage.User    # gUsername;
  BAG.FM.Fertigmeldung  # 1;
//  if (aFM<>0) then BAG.FM.Fertigmeldung  # aFM;
  REPEAT
    Erx # RekInsert(707,_recUnlock,'MAN');
    if (Erx=_rDeadLock) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    if (Erx<>_rOK) then BAG.FM.Fertigmeldung # BAG.FM.Fertigmeldung + 1;
    if (BAG.FM.Fertigmeldung>30000) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
  UNTIL (erx=_rOK);

//DbaLog(_LogInfo, N, 'Insert 707:'+aint(BAG.FM.Nummer)+'/'+aint(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung));


  // ggf. Analyse gleich mit speichern...
  if (aMitAnalyse) then begin
    Lys.K.Datum           # BAG.FM.Datum;
    Lys.K.Quelle          # Translate('Fertigmeldung');
    "Lys.K.Trägernummer1" # BAG.FM.Nummer;
    "Lys.K.Trägernummer2" # BAG.FM.Position;
    "Lys.K.Trägernummer3" # BAG.FM.Fertigung;
    "Lys.K.Trägernummer4" # BAG.FM.Fertigmeldung;
    if (Lys_Data:Anlegen()=false) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    Erx # RecRead(707,1,_recLock);
    if (Erx=_rOK) then begin
      BAG.FM.Analysenummer # Lys.K.Analysenr;
      Erx # RekReplace(707,_recunlock,'MAN');
    end;
    if (Erx<>_rOK) then begin         // 2022-07-05 AH DEADLOCK
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
  end;


  // angehängte Daten umnummerieren --------------------------------------------------
  Erx # RecLink(710,vBuf707,10,_recFirst);  // Fehler loopen
  WHILE (Erx<=_rLocked) do begin

    if (aentstehenWeitere) then begin
      BAG.FM.Fh.Nummer      # BAG.FM.Nummer;
      BAG.FM.Fh.Fertigmeld  # BAG.FM.Fertigmeldung;
      Erx # RekInsert(710,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        RecBufDestroy(vBuf707);
        RETURN false;
      end;
      BAG.FM.Fh.Nummer      # vBuf707->BAG.FM.Nummer;
      BAG.FM.Fh.Fertigmeld  # vBuf707->BAG.FM.Fertigmeldung;
      Recread(710,1,0);
      Erx # RecLink(710,vBuf707,10,_recNext);
      CYCLE;
    end;

    Erx # RecRead(710,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.FM.Fh.Nummer      # BAG.FM.Nummer;
      BAG.FM.Fh.Fertigmeld  # BAG.FM.Fertigmeldung;
      erx # RekReplace(710,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    Erx # RecLink(710,vBuf707,10,_recFirst);
  END;


  Erx # RecLink(708,vBuf707,12,_recFirst);  // Bewegungen loopen
  WHILE (Erx<=_rLocked) do begin

    if (aentstehenWeitere) then begin
      BAG.FM.B.Nummer      # BAG.FM.Nummer;
      BAG.FM.B.Fertigmeld  # BAG.FM.Fertigmeldung;
      Erx # RekInsert(708,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        RecBufDestroy(vBuf707);
        RETURN false;
      end;
      BAG.FM.B.Nummer      # vBuf707->BAG.FM.Nummer;
      BAG.FM.B.Fertigmeld  # vBuf707->BAG.FM.Fertigmeldung;
      Recread(708,1,0);
      Erx # RecLink(708,vBuf707,12,_recNext);
      CYCLE;
    end;

    Erx # RecRead(708,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.FM.B.Nummer       # BAG.FM.Nummer;
      BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
      Erx # RekReplace(708,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    Erx # RecLink(708,vBuf707,12,_recFirst);
  END;

  // ALLE Ausführungen in der Ziel-FM LÖSCHEN    2022-10-18 AH
  WHILE (RecLink(705, 707, 13, _recFirst)<=_rOK) do begin
    RekDelete(705);
  END;

  Erx # RecLink(705, vBuf707, 13, _recFirst);  // Ausfuehrung loopen
  WHILE (Erx<=_rLocked) do begin

    // 2023-07-25 AH    mach PLATZ
    v705 # Reksave(705);
    BAG.AF.Nummer        # BAG.FM.Nummer;
    BAG.AF.Fertigmeldung # BAG.FM.Fertigmeldung;
    Erx # RecRead(705,1,0);
    if (erx=_rOK) then begin
      RekDelete(705);
    end;
    RekRestore(v705);


    if (aentstehenWeitere) then begin
      BAG.AF.Nummer         # BAG.FM.Nummer;
      BAG.AF.Fertigmeldung  # BAG.FM.Fertigmeldung;
      Erx # RekInsert(705,_recUnlock,'MAN');
      if (erx<>_rOK) then begin
        RecBufDestroy(vBuf707);
        RETURN false;
      end;
      BAG.AF.Nummer         # vBuf707->BAG.FM.Nummer;
      BAG.AF.Fertigmeldung  # vBuf707->BAG.FM.Fertigmeldung;
      Recread(705,1,0);
      Erx # RecLink(705,vBuf707,13,_recNext);
      CYCLE;
    end;


    Erx # RecRead(705,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.AF.Nummer        # BAG.FM.Nummer;
      BAG.AF.Fertigmeldung # BAG.FM.Fertigmeldung;
      Erx # RekReplace(705,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    Erx # RecLink(705,vBuf707,13,_recFirst);
  END;
  RecBufDestroy(vBuf707);

  RETURN true;
end;


//========================================================================
//========================================================================
sub TauscheInUndOut(var aInvDat : date) : int
local begin
  Erx     : int;
  vMat1   : int;
  vMat2   : int;
  v707    : int;
  vUrMat  : int;
  vErr    : alpha(1000);
end;
begin

  vMat2 # Lib_Nummern:ReadNummer('Material');
  Erx # RecLink(200,701,11,_RecFirst);  // Restkarte holen
//debugx('tauscherei...');
//debugx('KEY701 Mat:'+aint(BAG.IO.Materialnr)+'  Rst:'+aint(BAG.IO.MaterialRstNr));
  if (erx<>_rOK) or (vMat2=0) then RETURN -1;

  Lib_Nummern:SaveNummer();
  vMat1 # Mat.Nummer;
  vErr # Mat_Data:Rename(Mat.Nummer, vMat2, var aInvDat);
  if (vErr<>'') then RETURN -1;

  // Mat.Aktionen umbiegen...
  if (BAG.IO.BruderID=0) then
    vUrMat              # BAG.IO.Materialnr
  else
    vUrMat              # "Mat.Vorgänger";
  Mat.Nummer # vUrMat;
//debugx('UR:'+aint(vUrMat)+'   tausche:'+aint(vMat1)+' -> '+aint(vMat2));
  FOR Erx # RecLink(204,200,14,_RecFirst)
  LOOP Erx # RecLink(204,200,14,_RecNext)
  WHILE (erx<=_rLocked) do begin
    if (Mat.A.Entstanden=vMat1) then begin
      Erx # RecRead(204,1,_recLock);
      if (Erx=_rOK) then begin
        Mat.A.Entstanden # vMat2;
        Erx # RekReplace(204);
      end;
      if (Erx<>_rOK) then RETURN -1;        // 2022-07-05 AH DEADLOCK
    end;
  END;
 
  // Inputs umbiegen...
  if (BAG.IO.MaterialRstNr=vMat1) or (BAG.IO.MaterialNr=vMat1) then begin
    Erx # RecRead(701,1,_recLock);
    if (Erx=_rOK) then begin
      if (BAG.IO.MaterialRstNr=vMat1) then
        BAG.IO.MaterialRstNr # vMat2;
      if (BAG.IO.MaterialNr=vMat1) then
        BAG.IO.MaterialNr # vMat2;
      Erx # RekReplace(701);
    end;
    if (Erx<>_rOK) then RETURN -1;        // 2022-07-05 AH DEADLOCK
  end;

  // 2022-08-09 AH : bei Fahren mit TAUSCH UND KOMMISSION muss auch die LFS-Pos. korrigiert werden, da sonst Status nicht stimmt!!
  if (BAG.P.Aktion=c_BAG_Fahr09) then begin
    Erx # RecLink(441,701,13,_recFirst);  // LFS-Pos. holen
    if (erx<=_rLocked) then begin
      Erx # RecRead(441,1,_reCLock);
      if (Erx=_rDeadLock) then RETURN -1;
      Lfs.P.Materialnr # vMat2;
      Erx # Rekreplace(441);
      if (Erx<>_rOK) then RETURN -1;
    end;
  end;


  // FMs umbiegen...
  if (BAG.IO.VonFertigmeld<>0) then begin
    v707 # RekSave(707);
    Erx # RecLink(707,701,18,_recFirst);    // ausFM holen
    if (erx<=_rLocked) and (BAG.FM.Materialnr=vMat1) then begin
      Erx # RecRead(707,1,_recLock);
      if (Erx=_rOK) then begin
        BAG.FM.Materialnr # vMat2;
        Erx # RekReplace(707);
      end;
      if (Erx<>_rOK) then RETURN -1;        // 2022-07-05 AH DEADLOCK
    end;
    RekRestore(v707);
  end;

  RETURN vMat1;
end;


//========================================================================
//  Verbchue707 + ERR
//========================================================================
sub Verbuche707(
  aEtkTxt     : int;
  aPakNr      : int;) : logic;
local begin
  Erx           : int;
  vAbschlussYN  : logic;
  v252          : int;
  vEKSum        : float;
  vMatWert      : float;
  v707          : int;
  vMatNr        : int;
  vInvDat       : date;
end;
begin

  if (BAG.FM.UnverbuchtYN=false) then RETURN false;

  vAbschlussYN # false;

  v707 # RekSave(707);

  // Arbeitsgang holen
  Erx # RecLink(828,702,8,_recfirst);
  if (erx>_rLockeD) then RecbufClear(828);

  // Einsatz mindern ------------------------------------------------------
  // Artikelproduktion???
  if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
    if (BA1_F_ArtPrd_Data:Verbuchen(var vEKSum)=false) then begin
      RecBufDestroy(v707);
      Error(708002,'');
      RETURN false;
    end;
  end
  else if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    // Einsatzmaterial "verbrauchen"
    if (EinsatzMatMindern(aEtkTxt, vAbschlussYN, var vEKSum, var vMatWert)=false) then begin
      RecBufDestroy(v707);
      Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
      RETURN false;
    end;
  end
  else begin  // "normale" Produktion
//debugx(ArG.Aktion+' KEY701'+' '+aint(BAG.IO.MaterialNr)+'/'+aint(BAG.IO.MaterialRstNr));
    // 07.11.2018 AH: Tauschen?
    if (ArG.TauscheInOutYN) then begin
      if (BAG.IO.VonFertigmeld=0) then begin
        RecBufDestroy(v707);
        Error(708002,'');
        RETURN false;
      end;
      if (BAG.IO.MaterialNr=BAG.IO.MaterialRstNr) then begin
//        (BAG.IO.Materialtyp=c_IO_Mat) then begin
        if ("BAG.P.Typ.1In-1OutYN"=false) then begin
          RecBufDestroy(v707);
          Error(708002,'');
          RETURN false;
        end;
        if (aPakNr=0) then aPakNr # Mat.Paketnr;    // 08.09.2021 AH: Paketnr verschieben (pug)
        vMatNr # TauscheInUndOut(var vInvDat);
        if (vMatNr<0) then begin
          RecBufDestroy(v707);
          Error(708002,'xxx');
          RETURN false;
        end;
      end;
    end;

    
    BAG.IO.Nummer # BAG.FM.Nummer;
    BAG.IO.ID     # BAG.FM.InputID;
    Erx # RecRead(701,1,0);   // Einsatz holen
    if (Erx > _rLocked) then begin    // ST 2009-08-28 Sicherheitsabfrage hibnzugef∑gt
      RecBufDestroy(v707);
      Error(010027,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
      RETURN false;
    end;

    // Einsatzmaterial "verbrauchen"
    if (BAG.IO.MaterialTyp=c_IO_Mat) then begin

      if (EinsatzMatMindern(aEtkTxt, vAbschlussYN, var vEKSum, var vMatWert)=false) then begin
        RecBufDestroy(v707);
        Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
        RETURN false;
      end;

    end
    else if (BAG.IO.MaterialTyp=c_IO_Art) then begin

      // Chargen buffern...
      Erx # RecLink(252,701,17,_recFirst);  // Charge holen
      if (erx>_rLocked) then begin
        RecBufDestroy(v707);
        Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
        RETURN false;
      end;
      v252 # RekSave(252);

      if (EinsatzArtMindern(vAbschlussYN,var vEKSum)=false) then begin
        RecBufDestroy(v252);
        RecBufDestroy(v707);
        Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
        RETURN false;
      end;

      RekRestore(v252);  // RESTORE
    end;
  end;  // normale Prd.


  // Fertigmaterial anlegen -----------------------------------------------------
  RecBufCopy(v707, 707);    // 01.08.2017 AH
  if (BAG.P.Aktion=c_BAG_MatPrd) then begin
    if (BA1_FM_MatPrd_Data:FertigMatAnlegen(vEKSum)=false) then RETURN false;
  end
  else begin
    if (BAG.FM.MaterialTyp=c_IO_Mat) then begin
      if (FertigMatAnlegen(vEKSum, vMatWert, vMatNr, vInvDat, aPakNr)=false) then RETURN false;
    end
    else if (BAG.FM.MaterialTyp=c_IO_Art) then begin
      if (FertigArtAnlegen(vEKSum)=false) then RETURN false;
    end;
  end;

  // falls es ein Fahren für einen Versand ist,
  // die Verwiegung auch ggf. in dem zu Grunde liegenden VERSAND-BA eintragen.....
  if (BAG.F.zuVersand<>0) and (BAG.P.Aktion=c_BAG_Fahr09) then begin
    if (Vsd_Data:FMaufVersandLFA()=false) then begin
      RecBufDestroy(v707);
      Error(707011,AInt(BAG.F.ZuVersand)+'/'+AInt(BAG.F.ZuVersand.Pos));
      RETURN false;
    end;
  end;


  RekRestore(v707);
  Erx # RecRead(707,1,0);
  if (Erx>_rLocked) then RETURN false;


  // ggf. Unverbucht-Flag löschen
  if (BAG.FM.UnverbuchtYN) then begin
    Erx # RecRead(707,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.FM.UnverbuchtYN # false;
      Erx # RekReplace(707,_recunlock,'AUTO');
    end;
    RETURN (erx=_rOK);
  end;


  RETURN true;
end;


//========================================================================
//  VererbeReservierung
//========================================================================
sub VererbeReservierung(opt aWieRes : alpha);
local begin
  Erx : int;
  vOK : logic;
end;
begin
  // Reservierungen vorhanden?
  if ("BAG.P.Typ.1In-1OutYN") then begin
    RecLink(702, 707, 2, _recFirst);  // BA-Position holen
    BAG.IO.Nummer # BAG.FM.Nummer;
    BAG.IO.ID     # BAG.FM.InputID;
    RecRead(701,1,0);   // Einsatz holen
    if (BAG.FM.Materialnr<>0) and (BAG.P.ZielVerkaufYN = false) and // bei Verkauf NIE reservieren
      (BAG.IO.Materialtyp=c_IO_Mat) or (BAG.IO.Materialtyp=c_IO_VSB) then begin
      Erx # Mat_Data:Read(BAG.IO.Materialnr); // Material holen
      if (erx>=200) then begin
        // NUR allgemeine Reservierungen übernehmen...
        vOK # false;
        Erx # RecLink(203,200,13,_recFirst);
        WHILE (erx<=_rLocked) and (vOK=false) do begin
          if ("Mat.R.Trägertyp"='') then vOK # y;
          Erx # RecLink(203,200,13,_recNext);
        END;

        if (vOK) then begin
          // ST 2021-05-04 2200/20: Bugfix bei MDE Benutzung
          if (gUsergroup = 'JOB-SERVER') OR (gUsergroup = 'SOA_SERVER') OR (gUsername=*'SOA*') then aWieRes # 'N';
//            vOK # true;
//          else
//            vOK # (Msg(707010,'',_WinIcoQuestion, _WinDialogYesNo, 2)=_WinIdYes);
//          if (Msg(707010,'',_WinIcoQuestion, _WinDialogYesNo, 2)=_WinIdYes) then begin
//          if (vOK) then begin
          if (aWieRes='') then
            if (Msg(707010,'',_WinIcoQuestion, _WinDialogYesNo, 2)=_WinIdYes) then aWieRes # 'J';
          if (aWieRes=^'J') then begin
            TRANSON;
            Erx # RecLink(203,200,13,_recFirst);
            WHILE (Erx<=_rLocked) do begin
              if ("Mat.R.Trägertyp"='') then begin

                Erx # RecRead(203,1,_recSingleLock);
                if (Erx=_rOK) then begin
                  Mat.R.Materialnr # BAG.FM.Materialnr;
                  Erx # RekReplace(203,_recUnlock,'AUTO');
                end;
                if (erx<>_rOK) then begin
                  Erx # 999;
                  BREAK;
                end;
                Erx # RecLink(203,200,13,_recFirst);
              end
              else begin
                Erx # RecLink(203,200,13,_recNext);
              end;
            END;
            if (erx=999) then
              TRANSBRK
            else
              TRANSOFF;

            // Einsatz neu errechnen...
            Mat_Rsv_data:RecalcAll();

            // Fertigmaterial neu errechnen
            RecLink(200,707,7,_recFirst);   // Fertigmaterial holen
            Mat_Rsv_data:RecalcAll();
          end;
        end;
      end;
    end;
  end;
end;


//========================================================================
//  Verbuchen +ERR
//    700,702,703 muss geladen sein, ausserdem:
//    MAT: RESTKARTE
//    BAG-IO: INPUT
//
//  Ablauf:
// JE EinzelStk:
//  1. FM anlegen (ggf. Analyse, Anhänge umkopieren)
//  2. "Verbuche707":
//  2.1   "EinsatzMatmindern":
//  2.1.1   Gew. abziehen		                  2
//  2.1.2   Bestandsbuch		                  2
//  2.2   "FertigMatAnlegen":
//  2.2.1   MatAkt anlegen	                  3
//  2.2.2   NEUES Mat anlegen		              3
//  2.2.3   theo.Output ändern		            2?  BFS ab hier manchmal: obere Schritte fehlen, aber darunter passieren!?
//  2.2.4   neuen IO anlegen	                3
//  2.2.5   Fertigungsmenge ändern	          2?
//  2.2.6   FM mit neuer Mat.Nr./IO updaten   ?
//
//  3. Etikettendruck
//
//========================================================================
sub Verbuchen(
  opt aMitEtk     : logic;
  opt aMitAnalyse : logic;
  opt aEinzeln    : logic;
  opt aEtkTxt     : int;
  opt aKeepAppOff : logic)    // 02.03.2020 AH
  : logic;
local begin
  Erx           : int;
  vOK           : logic;
  vAnz          : int;
  v200          : int;
  v700          : int;
  v701          : int;
  v702          : int;
  v703          : int;
  v707          : int;
  vGesStk       : int;
  vGesB         : float;
  vGesN         : float;
  vGesM         : float;
  vGesM2        : float;
  vTxt          : int;
  vA            : alpha;
end;
begin DoLogProc;

  if (BAG.FM.Datum=today) then BAG.FM.Zeit # now;

  // 08.04.2013
  if (BAG.FM.Materialtyp<>c_IO_Mat) and (BAG.FM.Materialtyp<>c_IO_Art) then RETURN false;

  // 29.11.2010 AI:
  if (BAG.F.Nummer<>BAG.FM.InputBAG) then RETURN false;


  APPOFF(); // 24.03.2017 AH

  vA # 'N';
  if (aEinzeln) then vA # 'Y';
  if (RunAFX('BAG.FM.Verbuchen.Einzeln',vA)<>0) then begin
    aEinzeln # (AfxRes=_rOK);
  end;

  v200 # Reksave(200);
  v700 # RekSave(700);
  v701 # RekSave(701);
  v702 # RekSave(702);
  v703 # RekSave(703);
  vGesStk # "BAG.FM.Stück";
  vGesB   # BAG.FM.Gewicht.Brutt;
  vGesN   # BAG.FM.Gewicht.Netto;
  vGesM   # BAG.FM.Menge;
  vGesM2  # BAG.FM.Menge2;

  if (aEtkTxt=0) then     // 25.05.2022 AH, IMMER über TXT
    vTxt # TextOpen(16);  // Für Etiketten die 707 merken

  TRANSON;

  vAnz # 1;
  // 28.08.2018 AH
  if (aEinzeln) and (vGesStk<>0) then begin
    "BAG.FM.Stück"        # 1;
    BAG.FM.Gewicht.Brutt  # Rnd(vGesB / cnvfi(vGesStk), Set.Stellen.Gewicht);
    BAG.FM.Gewicht.Netto  # Rnd(vGesN / cnvfi(vGesStk), Set.Stellen.Gewicht);
    BAG.FM.Menge          # Rnd(vGesM / cnvfi(vGesStk), Set.Stellen.Menge);
    BAG.FM.Menge2         # Rnd(vGesM2 / cnvfi(vGesStk), Set.Stellen.Menge);
    vAnz # vGesStk;
// 25.05.2022 AH IMMER - S.O.   vTxt # aEtkTxt;
//    if (aEtkTxt=0) then begin
//      vTxt # TextOpen(16);  // Für Etiketten die 707 merken
//26.11.2018      aEtkTxt # vTxt;
//    end;
  end;

  WHILE (vAnz>0) do begin

    dec(vAnz);
    RecBufCopy(v200, 200);
    RecBufCopy(v700, 700);
    RecBufCopy(v701, 701);
    RecBufCopy(v702, 702);
    RecBufCopy(v703, 703);
    RecRead(701,1,0);
    RecRead(703,1,0);
    
    if (vAnz=0) then begin
      BAG.FM.Gewicht.Brutt  # vGesB;
      BAG.FM.Gewicht.Netto  # vGesN;
      BAG.FM.Menge          # vGesM;
      BAG.FM.Menge2         # vGesM2;
    end
    else begin
      vGesB   # vGesB - BAG.FM.Gewicht.Brutt;
      vGesN   # vGesN - BAG.FM.Gewicht.Netto;
      vGesM   # vGesM - BAG.FM.Menge;
      vGesM2  # vGesM2 - BAG.FM.Menge2;;
    end;
       
    // ST 2021-11-02 Bugfix für Analysen: Tmp Nummer wiederherstellen
    BAG.FM.Nummer           # myTmpNummer;
    BAG.FM.Fertigmeldung    # 999;
    
    // Datensatz + Anhänge speichern
    if (SaveFM(aMitAnalyse, vAnz>0)=false) then begin
      // wieder auf Temporär setzen
      BAG.FM.Nummer           # myTmpNummer;
      BAG.FM.Fertigmeldung    # 999;
      TRANSBRK;
      APPON();
      if (vTxt<>0) then TextClose(vTxt);
      RekRestore(v200);
      RekRestore(v700);
      RekRestore(v701);
      RekRestore(v702);
      RekRestore(v703);
      RETURN false;
    end;

    // FM verbuchen
    if (aEtkTxt<>0) then
      vOK # VerBuche707(aEtkTxt, 0)
    else
      vOK # VerBuche707(vTxt, 0)
    if (vOK=false) then begin
      // Datensatz + Anhänge wieder zu TEMP machen (04.03.2015)
  //    SaveFM(aMitAnalyse, myTmpNummer, 999);
      // wieder auf Temporär setzen
      BAG.FM.Nummer           # myTmpNummer;
      BAG.FM.Fertigmeldung    # 999;
      TRANSBRK;
      APPON();
      if (vTxt<>0) then TextClose(vTxt);
      RekRestore(v700);
      RekRestore(v701);
      RekRestore(v702);
      RekRestore(v703);
      RETURN false;
    end;

//debugX('Add mat to EtkTxt');
    if (aEtkTxt<>0) then
      TextAddLine(aEtkTxt, '707|'+aint(RecInfo(707,_recID)))
    else if (vTxt<>0) then
      TextAddLine(vTxt, '707|'+aint(RecInfo(707,_recID)));
  END;  // Einzelpakete
  
  TRANSOFF;

  RecBufDestroy(v200);
  RecBufDestroy(v700);
  RecBufDestroy(v701);
  RecBufDestroy(v702);
  RecBufDestroy(v703);

  if (aKeepAppOff=false) then APPON();

  // ggf. Etikett drucken...
  if (aMitEtk) AND (BAG.FM.MaterialTyp=c_IO_Mat) and
      (BAG.P.Aktion<>c_BAG_Fahr) then begin
    v707 # RekSave(707);
    if (RunAFX('BAG.FM.Verbuchen.Etikettenlauf',aint(vTxt))>=0) then begin
      if (Set.SQL.SoaYN) then
        Winsleep(500);    // wegen SQL
      if (vTxt<>0) then begin
        FOR vA # TextLineRead(vTxt, 1, _TextLineDelete)
        LOOP vA # TextLineRead(vTxt, 1, _TextLineDelete)
        WHILE (vA<>'') do begin
          if (StrCut(vA,1,3)='707') then begin
            RecRead(707,0,_recId, cnvia(Str_token(vA,'|',2)));
            if (BAG.FM.Materialnr<>0) then Mat_Data:Read(BAG.FM.Materialnr);    // 08.10.2018 AH
            Etikettendruck();
          end
          else if (StrCut(vA,1,3)='200') then begin
//            RecRead(701,0,_recId, cnvia(Str_token(vA,'|',2)));
//            if (BAG.IO.Materialnr<>0) then Mat_Data:Read(BAG.IO.Materialnr);
            RecRead(200,0,_recId, cnvia(Str_token(vA,'|',2)));
            if (Lib_Dokumente:RekReadFrm(200, 'Abbuchungsetikett') <= _rLocked) then begin
              Lib_Dokumente:PrintForm(200,'Abbuchungsetikett',false);
            end;
          end;
        END;
        TextClose(vTxt);
      end
      else begin
        Etikettendruck();
      end;
    end;
    RekRestore(v707);
  end;

//26.11.2018  if (vTxt<>0) then TextClose(vTxt);
//  if (vTxt<>0) and (aEtkTxt=0) then TextClose(vTxt);

  // ggf. Reservierungen vom Vormaterial übernehmen
  if (BAG.P.Aktion=c_BAG_Fahr) then
    VererbeReservierung(Set.LFS.ResTransfer)    // 05.04.2022 AH
  else
    VererbeReservierung();

  RunAFX('BAG.FM.Verbuchen.Inner.Post','');   // 12.04.2021 AH: BFS

  RETURN true;
end;


//========================================================================
//  AbschlussKopf   +ERR
//
//========================================================================
sub AbschlussKopf(aBA : int) : logic;
local begin
  Erx     : int;
  vHdl    : int;
  vBAG    : int;
  vPos    : int;
end;
begin DoLogProc;

  BAG.Nummer # aBA;
  Erx # RecRead(700,1,0);
  if (erx>_rLocked) then RETURN false;

  vBAG  # BAG.Nummer;

  // Position wählen
  vPos # ChoosePos();
  if (vPos=0) then RETURN false;

  // Fahraufträge oder Versandarbeitsgänge werden über Lieferschein fertiggemeldet
  if (BAG.P.Aktion=c_BAG_Fahr)
// 15.10.2021 AH   OR (BAG.P.Aktion=c_BAG_Versand)
  then begin
    Error(702014,'');
    ErrorOutput;
    RETURN false;
  end;

  //RETURN AbschlussPos(vBag, vPos, today, now)
  RETURN AbschlussPos(vBag, vPos, 0.0.0, now)
end;


//========================================================================
//  FMKopf  +ERR
//
//========================================================================
sub FMKopf(opt aProc : alpha) : logic;
local begin
  Erx         : int;
  vHdl        : int;
  v707        : int;
  vGew        : float;
  vM          : float;
  vInputList  : handle;
  vItem       : int;
  vOK         : logic;
  vVorPos     : int;
  v702        : int;
  vDL         : int;
  vDlg        : int;
  vKey        : int;
  vPerTabelle   : logic;
  vPerKombiTab  : logic;
end;
begin DoLogProc;
//if (gusername='AH') then lib_debug:startbluemode();
  if ((Rechte[Rgt_BA_Fertigmelden])=false) then RETURN false;

  // AFX
  if (RunAFX('BAG.FM.FMKopf',aProc)<>0) then RETURN (AfxRes=_rOK);

  gBagFmBackProc # aProc;

  if (BAG.FM.Nummer<>0) then begin
    BAG.Nummer # BAG.FM.Nummer;
  end
  else begin
    RecBufClear(707);   // FM leeren
  end;
  Erx # RecRead(700,1,0);
  if (erx>_rLocked) then RETURN false;

  // keine Pos. angegeben?
  if (BAG.FM.Position=0) then begin    // dann Position wählen
    BAG.FM.Position # ChoosePos();
    if (BAG.FM.Position=0) then RETURN false;
  end;

  // Anfragen könne nicht fertiggemeldet werden!
  if (BA1_P_Lib:StatusFreiZurProduktion()=false) then begin
    Error(702045,BAG.P.Status);
    RETURN false;
  end;
  //  VSB-Position? -> Kann nicht fertiggemeldet werden!
  if (BAG.P.Typ.VSBYN) then begin
    Error(702008,'');
    RETURN false;
  end;
  if (BAG.P.Aktion=c_BAG_Fahr) then begin
    Error(702014,'');
    RETURN false;
  end;

  // schon erledigt? -> Ende
  if ("BAG.P.Löschmarker"='*') then begin
    Error(702009,'');
    RETURN false;
  end;

/***
  // 20.09.2021 AH: TUNNEL-FM
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp<>c_IO_BAG) then begin
      vVorPos # -1;
      BREAK;
    end;
    if (vVorPos=0) then vVorPos # BAG.IO.VonPosition;
    if (vVorPos<>BAG.IO.VonPosition) then begin
      vVorPos # -1;
      BREAK;
    end;
  END;
  if (vVorPos>0) then begin
    if (Msg(99,'Alle Vorgängerpositionen theoretisch fertigmelden?',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes) then begin
      v707 # RekSave(707);
      v702 # RekSave(702);
      if (BA1_FM_Theo_subs:FMTheorie(BAG.P.Nummer, vVorPos, today,y,n,n,0,y)=false) then begin
        RekRestore(v702);
        RekRestore(v707);
        Erroroutput;
        RETURN false;
      end;
      RekRestore(v707);
      RekRestore(v702);
    end;
  end;
***/


  BAG.FM.Nummer   # BAG.P.Nummer;   //BAG.Nummer;
  BAG.FM.Position # BAG.P.Position; //BAG.FM.Position;

  REPEAT
    // Input wählen
    if (BAG.FM.InputID=0) then begin
      if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
        BAG.FM.InputBAG # BAG.P.Nummer;
        BAG.FM.InputID  # 0;
      end
      else if (BAG.P.Aktion=c_BAG_WalzSpulen) then begin
        Erx # RecLink(701,702,2,_recFirst);   // 1. Input holen
      end
      else if (BAG.P.Aktion=c_BAG_SpaltSpulen) then begin
        RecBufClear(701); // KEIN Einsatz vorgegeben

        vDlg # WinOpen(Lib_GuiCom:GetAlternativeName('BA1.F.Auswahl.SpSpulen'),_WinOpenDialog);
        
        vHdl # Winsearch(vDLG,'LB.Info1');
        vHdl->wpcaption # c_AKt_BA+' '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position)+' '+BAG.P.Bezeichnung;
        vHdl # Winsearch(vDLG,'LB.Info3');
        vHdl->wpcaption #  Translate('Fertigung wählen:');
        vDL # Winsearch(vDLG,'ZL.BAG.F.Auswahl');
        Lib_GuiCom:RecallList(vDL);       // Usersettings holen
        vDlg->WinDialogRun(_WinDialogCenter,gMDI);
        Lib_GuiCom:RememberList(vDL);     // Usersettings holen
        WinClose(vDlg);
        if (gSelected=0) then RETURN false;
        RecRead(703,0,_RecId,gSelected);
        gSelected # 0;

//        vInputList # CteOpen(_CteTree);
        FertigAbfrage(BAG.FM.Nummer, BAG.FM.Position, BAG.FM.Fertigung, BAG.FM.InputBAG, BAG.FM.InputID, BAG.FM.OutputID);//, vInputList);
        RETURN true;
// 17.05.2022 AH
//        vInputList # CteOpen(_CteTree);
//        // ALLE Einsätze nutzen...
//        FOR ERx # RecLink(701,702,2,_RecFirst)    // Input loopen
//        LOOP ERx # RecLink(701,702,2,_RecNext)
//        WHILE (erx<=_rLocked) do begin
//          vItem # CteOpen(_CteItem);
//          vItem->spname   # Aint(BAG.IO.ID);
//          vItem->spcustom # AInt(0)+'|'+ANum(BAG.IO.Plan.Out.GewN, Set.Stellen.Gewicht)+'|'+ANum(BAG.IO.Plan.Out.GewB, Set.Stellen.Gewicht);
//          vInputList->CteInsert(vItem);
//          BAG.FM.InputID  # BAG.IO.ID;
//          BAG.FM.InputBAG # BAG.IO.Nummer;
//        END;
      end
      else if (BAG.P.Aktion=c_BAG_MatPrd) then begin
      end
      else if (BAG.P.Aktion=c_BAG_Messen) then begin    // 07.05.2021 AH
        if (BA1_FM_Messen:FM()=false) then RETURN false;
      end
      else if (BAG.P.Aktion=c_BAG_Spulen) or (BAG.P.Aktion=c_BAG_Paket) then begin
        // Inputbaum aufbauen...
        vInputList # CteOpen(_CteTree);
        if (ChooseMultiInput(vInputList)=false) then begin
          vInputList->CteClear(true);
          Cteclose(vInputList);
          RETURN false;
        end;
        RecbufClear(701);
      end
      else begin
        Erx # ChooseInput();
        if (Erx=_winidcancel) then RETURN false;
        if (Erx=-8) then vPerKombiTab # true;  // 2023-02-09 AH Tabelle?
      end;
    end;


    if (vPerKombiTab) then begin
    end
    else begin
      // Output wählen
      if (BAG.FM.OutputID=0) then begin
        if (BAG.P.Aktion=c_BAG_ArtPrd) then begin
          Erx # RecLink(703,702,4,_recFirst); // 1. Fertigung holen
          if (erx>_rLocked) then RETURN false;
          Erx # RecLink(701,703,4,_RecFirst); //  Output holen
          if (erx>_rLocked) then RETURN false;
          BAG.FM.OutputID   # BAG.IO.ID;
          BAG.FM.Fertigung  # BAG.F.Fertigung;
        end
        else begin
          vKey # ChooseOutput();
  //debugx(aint(vKEY)+'/'+aint(gSelected));
          if (vKey<>_WinIdok) and (vKey<>-8) then begin // weder per Tabelle noch Maske?
            if (vInputList<>0) then begin
              vInputList->CteClear(true);
              Cteclose(vInputList);
            end;
            RETURN false;
          end;
          if (vKey=-8) then begin // per Tabelle?
            vPerTabelle # true;
          end;
        end;
      end;
    end;

    FertigAbfrage(BAG.FM.Nummer, BAG.FM.Position, BAG.FM.Fertigung, BAG.FM.InputBAG, BAG.FM.InputID, BAG.FM.OutputID, vInputList, vPerTabelle, vPerKombiTab);

    RETURN true;

  UNTIL (1=2);

  RETURN true;
end;


//========================================================================
//  FMGesamt
//
//========================================================================
sub FMGesamt(aBA : int) : logic;
local begin
  Erx     : int;
end;
begin DoLogProc;

  BAG.Nummer # aBA;
  Erx # RecRead(700,1,0);
  if (erx>_rLocked) then RETURN false;

  // BA schon fertig??
  if (BAG.Fertig.Datum<>0.0.0) then begin
    Msg(702008,'',0,0,0);
    RETURN false;
  end;

  if (RecLinkInfo(702,700,1,_RecCount)<>1) then begin
todo('Gesamt FM für mehrstufigen BA!');
    RETURN false;
  end;


  Erx # RecLink(702,700,1,_RecFirst);   // 1. Position holen
  // BA-Pos schon fertig??
  if (BAG.P.Fertig.Dat<>0.0.0) then begin
    Msg(702008,'',0,0,0);
    RETURN false;
  end;


  if (Msg(700001,'',_WinIcoQuestion,_WinDialogYesNo,2)<>_WinIdYes) then RETURN false;


  Erx # RecLink(701,702,2,_recFirst);   // Einsatz loopen
  WHILE (erx<=_rLocked) do begin

todo('buche(vVonID');

    Erx # RecLink(701,702,2, _recNext);
  END;

todo('Ges. abschliessen');

  RETURN true;
end;


//========================================================================
//  FMTheorie                                     ST 2009-07-30 P.1161/86
//  Meldet eine Betriebsauftragsposition mit den geplanten Werten fertig
//========================================================================
sub FMTheorie(
  aBA             : int;
  opt aBAPos      : int;
  opt aDatum      : date;
  opt aSilent     : logic;
  opt aKeinAbschluss  : logic;
  opt aEtikett    : logic;
  opt aStatus     : int;
) : logic;
begin DoLogProc;
  RETURN BA1_FM_Theo_subs:FMTheorie(aBA, aBAPos, aDatum, aSilent, aKeinAbschluss, aEtikett, aStatus, 0); // 21.09.2021 AH mit AutoRekursion
end;


//========================================================================
//  Etikettendruck
//
//========================================================================
sub Etikettendruck()
local begin
  Erx   : int;
  vEtk  :   int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('BAG.FM.Etikettendruck','')<0) then RETURN;

  // keine Etiketten bei externen BAs
  if (BAG.P.ExternYN) then RETURN;

//debugx('KEY702 KEY707 KEY703');
//debugx(anum(BAG.F.Fertig.Menge,0)+BAG.F.MEH);

  // Etikettentyp lesen
  Erx # RecLink(703,707,3,_RecFirst);         // Fertigung lesen
  if (Erx <= _rLocked) then begin
/*
    Erx # RecLink(704,703,6,_RecFirst);       // Verpackung lesen
    if (Erx <= _rLocked) then begin
      if (BAG.Vpg.Etikettentyp > 0) then begin
        Erx # RecLink(840,704,2,_RecFirst);       // Etikett lesen
        if (Erx > _rLocked) then  begin
          Error(707009,AInt(BAG.Vpg.Etikettentyp));
          return;
        end;
        vEtk # Eti.Nummer;
      end;

    end;
*/
    vEtk  # Mat.Etikettentyp;

    // Standardetikett lesen
//    if (vEtk = 0) then
//      vEtk # 100;         // Standardetikett

    Mat_Etikett:Init(vEtk);

  end
  else begin
    Error(707007,'');
  end;

end;


//========================================================================
//  VerbuchenSpulen +ERR
//
//========================================================================
sub VerbuchenSpulen(
  aEtkTxt     : int;
  aInputList  : handle;
  aMitEtk     : logic;
) : logic;
local begin
  Erx           : int;
  vMarkList     : handle;
  vItem         : handle;
  vItem2        : handle;
  vLastID       : int;

  vMenge        : float;
  vGesGewN      : float;
  vGesGewB      : float;
  vFaktorN      : float;
  vFaktorB      : float;
  vI,vJ         : int;
  vB            : alpha;
  vStk          : int;
  vGewN,vGewB   : float;
  vM            : float;
  vNeueNr       : int;
  vA            : alpha(1000);

  vAbschlussYN  : logic;
  vBuf252       : int;
  vOK           : logic;
  vEKSum        : float;
  vMatWert      : float;
  vBuf707       : int;
  v200          : int;
end;
begin

  // Ablauf:
  //    - theor. Gesamtgewicht der Einsätze errechen
  //    - dann Abweichungsfaktor pro Einsatz zum Spulenendgewicht
  //    - EINE Verwiegung 707 anlegen mit Spulenenddaten
  //    - pro Einsatz:
  //      - BAG.FM-Felder so belegen, als ob einzeln verwogen wurde (anhand Faktor)
  //        AUUSER bei dem letzten Einsatzmaterial: das wird "Rest" (wegen Faktorrundungesfehler)
  //      - Einsatzmaterial mindern (per Unterfunktionen)
  //      - Fertigmaterial anlegen (per Unterfunktionen) und in Liste merken
  //    - Finale Spule anlegen per Material-Kombi über diese Liste
  //    - Stückzahl der Spulenkarte setzen (wäre sonst Summe der Einzelkarten)
  //    - Verwiegung auf die Materialnr. der Spule setzen
  //    - im theoretischen Output die Ist-In-Stückzahl um Spulenstück erhöhen

  vAbschlussYN # n;

  if (BAG.P.Aktion=c_BAG_SpaltSpulen) or (BAG.P.Aktion=c_BAG_WalzSpulen) then begin
    FOR Erx # RecLink(701,702,2,_RecFirst)    // Input loopen
    LOOP Erx # RecLink(701,702,2,_RecNext)
    WHILE (erx<=_rLocked) do begin
      vGesGewN # vGesGewN + BAG.IO.Plan.Out.GewN;
      vGesGewB # vGesGewB + BAG.IO.Plan.Out.GewB;
    END;
    if (vGesGewN<>0.0) then
      vFaktorN # BAG.FM.Gewicht.Netto / vGesGewN;
    if (vGesGewB<>0.0) then
      vFaktorB # BAG.FM.Gewicht.Brutt / vGesGewB;
    FOR vItem # aInputList->CteRead(_CteFirst)
    LOOP vItem # aInputList->CteRead(_CteNext, vItem)
    WHILE (vItem > 0) do begin
      BAG.IO.Nummer # BAG.F.Nummer;
      BAG.IO.ID     # cnvia(vItem->spName);
      vLastID       # BAG.IO.ID;
      Erx # RecRead(701,1,0);   // Einsatz holen
      if (erx<>_rOK) then RETURN false;

      vItem->spcustom # AInt(0)+'|'+ANum(BAG.IO.Plan.Out.GewN * vFaktorN, Set.Stellen.Gewicht)+'|'+ANum(BAG.IO.Plan.Out.GewB * vFaktorB, Set.Stellen.Gewicht);
    END;
    vGesGewN # 0.0;
    vGesGewB # 0.0;
  end;


  begin
  // Einsatzliste loopen und theoretisches GesamtGewicht addieren + AbweichungsFaktoren errechnen...
    FOR vItem # aInputList->CteRead(_CteFirst)
    LOOP vItem # aInputList->CteRead(_CteNext, vItem)
    WHILE (vItem > 0) do begin
      BAG.IO.Nummer # BAG.F.Nummer;
      BAG.IO.ID     # cnvia(vItem->spName);
      vLastID       # BAG.IO.ID;
      Erx # RecRead(701,1,0);   // Einsatz holen
      if (erx<>_rOK) then RETURN false;

      vA        # vItem->spcustom;
      vB        # Str_Token(vA, '|', 1);
      vStk      # cnvia(vB);
      vB        # Str_Token(vA, '|', 2);
      vGewN     # cnvfa(vB);
      vB        # Str_Token(vA, '|', 3);
      vGewB     # cnvfa(vB);

      vGesGewN # vGesGewN + vGewN;
      vGesGewB # vGesGewB + vGewB;
    END;

    if (vGesGewN<>0.0) then
      vFaktorN # BAG.FM.Gewicht.Netto / vGesGewN;
    if (vGesGewB<>0.0) then
      vFaktorB # BAG.FM.Gewicht.Brutt / vGesGewB;
  end;  // ...theoretischen Einsatz errechnen

  if (BAG.FM.Datum=today) then BAG.FM.Zeit # now;

  vGesGewN  # BAG.FM.Gewicht.Netto;
  vGesGewB  # BAG.FM.Gewicht.Brutt;

  vBuf707 # RekSave(707);

  TRANSON;

  BAG.FM.Nummer         # BAG.F.Nummer;

  // Verwiegung erstmal so anlegen
  BAG.FM.Anlage.Datum   # today;
  BAG.FM.Anlage.Zeit    # now;
  BAG.FM.Anlage.User    # gUsername;
  BAG.FM.Fertigmeldung  # 1;
  REPEAT
    Erx # RekInsert(707,_recUnlock,'MAN');
    if (Erx=_rDeadLock) then begin
      TRANSBRK;
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
    if (Erx<>_rOK) then BAG.FM.Fertigmeldung # BAG.FM.Fertigmeldung + 1;
  UNTIL (erx=_rOK);

  // angehängte Daten umnummerieren..................................
  FOR Erx # RecLink(710,vBuf707,10,_recFirst)   // Fehler loopen
  LOOP Erx # RecLink(710,vBuf707,10,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecRead(710,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.FM.Fh.Nummer      # BAG.FM.Nummer;
      BAG.FM.Fh.Fertigmeld  # BAG.FM.Fertigmeldung;
      Erx # RekReplace(710,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
  END;

  FOR Erx # RecLink(708,vBuf707,12,_recFirst) // Bewegungen loopen
  LOOP Erx # RecLink(708,vBuf707,12,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecRead(708,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.FM.B.Nummer       # BAG.FM.Nummer;
      BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
      Erx # RekReplace(708,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
  END;

  FOR Erx # RecLink(705, vBuf707, 13, _recFirst)  // Ausfuehrung loopen
  LOOP Erx # RecLink(705,vBuf707,13,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecRead(705,1,_recSingleLock);
    if (Erx=_rOK) then begin
      BAG.AF.Nummer        # BAG.FM.Nummer;
      BAG.AF.Fertigmeldung # BAG.FM.Fertigmeldung;
      Erx # RekReplace(705,_recUnlock,'MAN');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RecBufDestroy(vBuf707);
      RETURN false;
    end;
  END;
  RecBufDestroy(vBuf707);


  // Markierungsbaum aufbauen
  vMarkList # CteOpen(_CteTree);

  // --------------------
  FOR vItem # aInputList->CteRead(_CteFirst)
  LOOP vItem # aInputList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin
    BAG.IO.Nummer # BAG.FM.Nummer;
    BAG.IO.ID     # cnvia(vItem->spName);
    Erx # RecRead(701,1,0);   // Einsatz holen
    if (erx<>_rOK) then begin
      vMarkList->CteClear(true);
      Cteclose(vMarkList);
      TRANSBRK;
      RETURN false;
    end;

    vA    # vItem->spcustom;
    vB    # Str_Token(vA, '|', 1);
    vStk  # cnvia(vB);
    vB    # Str_Token(vA, '|', 2);
    vGewN # cnvfa(vB);
    vB    # Str_Token(vA, '|', 3);
    vGewB # cnvfa(vB);
    vB    # Str_Token(vA, '|', 4);
    vM    # cnvfa(vB);

    "BAG.FM.Stück"        # vStk;
    BAG.FM.Gewicht.Netto  # Rnd(vGewN * vFaktorN, Set.Stellen.Gewicht);
    BAG.FM.Gewicht.Brutt  # Rnd(vGewB * vFaktorB, Set.Stellen.Gewicht);
    if (vLastID=BAG.IO.ID) then begin
      BAG.FM.Gewicht.Netto # vGesGewN;
      BAG.FM.Gewicht.Brutt # vGesGewB;
    end
    else begin
      vGesGewN # vGesGewN - BAG.FM.Gewicht.Netto;
      vGesGewB # vGesGewB - BAG.FM.Gewicht.Brutt;
    end;

    RecLink(819,701,7,_recFirst);   // Warengruppe holen

    BAG.FM.MEH # BAG.F.MEH;
    if (BAG.P.Aktion=c_BAG_MatPrd) then
      BAG.FM.Menge # vM
    else if (BAG.P.Aktion=c_BAG_SPulen) or (BAG.P.Aktion=c_BAG_Paket) then
      BAG.FM.Menge # Lib_Berechnungen:L_aus_KgStkDBDichte2(BAG.FM.Gewicht.Netto, 1, BAG.IO.Dicke, BAG.IO.Breite, Wgr_Data:GetDichte(Wgr.Nummer, 701), "Wgr.TränenKGproQM") / 1000.0;
    else
      BAG.FM.Menge # Lib_einheiten:WandleMEH(707, 1, BAG.FM.Gewicht.Netto, 0.0, '', BAG.FM.MEH);
//debugx('verwiege : '+anum(bag.fm.gewicht.netto,0)+'kg, '+anum(bag.fm.menge,0)+bag.FM.MEH);
    BAG.FM.InputID # BAG.IO.ID;
//debugx('mindere:'+AInt(BAG.FM.InputID)+' ' +AInt(BAG.FM.BruderID)+'  um '+anum(BAG.FM.Gewicht.Netto,0)+'   xxx'+aint(BAG.IO.Ist.In.Stk));
    // Einsatzmaterial "verbrauchen"
    if (EinsatzMatMindern(aEtkTxt, vAbschlussYN, var vEKSum, var vMatWert)=false) then begin
      vMarkList->CteClear(true);
      Cteclose(vMarkList);
      TRANSBRK;
      Error(010035,AInt(BAG.IO.Nummer)+'|'+AInt(BAG.IO.MaterialNr));
      RETURN false;
    end;

//debug('Fertigmat:'+AInt(BAG.FM.InputID)+' ' +AInt(BAG.FM.BruderID));
    // Fertigmaterial anlegen
    if (FertigMatAnlegen(vEKSum, vMatWert)=false) then begin
      vMarkList->CteClear(true);
      Cteclose(vMarkList);
      TRANSBRK;
      RETURN false;
    end;

    // 1. Fertigmaterial ist Vorlage bei MatProd:
    if (v200=0) and (BAG.P.Aktion=c_BAG_MatPrd) then begin
      v200 # RecBufCreate(200);
      RecbufCopy(200,v200);
    end;

    vItem2 # CteOpen(_CteItem);
    vItem2->spname # '200/'+cnvai(RecInfo(200,_RecId));
    vMarkList->CteInsert(vItem2);
//debug('neuesmat:'+aint(Mat.Nummer));
  END;


  // Finales Material vorbelegen bei MatProd...
  if (BAG.P.Aktion=c_BAG_MatPrd) and (v200<>0) then begin
    Erx # RecLink(250,703,13,_recFirsT);    // Artikel holen
    if (Erx>_rLocked) then begin
      RecBufClear(v200);
      vMarkList->CteClear(true);
      Cteclose(vMarkList);
      TRANSBRK;
      Error(999999,'Artikel nicht gefunden!');
      RETURN false;
    end;

    v200->Mat.Strukturnr  # Art.Nummer;
    v200->Mat.MEH         # Art.MEH;
    v200->Mat.Warengruppe # Art.Warengruppe;
    v200->"Mat.Güte"      # "Art.Güte";
    v200->Mat.Dicke       # Art.Dicke;
    v200->Mat.Breite      # Art.Breite;
    v200->"Mat.Länge"     # "Art.Länge";
    v200->Mat.Dickentol   # Art.DickenTol;
    v200->Mat.Breitentol  # Art.BreitenTol;
    v200->"Mat.Längentol" # "Art.LängenTol";
    v200->Mat.RID         # Art.Innendmesser;
    v200->Mat.RAD         # Art.Aussendmesser;
  end;


  // KOMBINIEREN:
  vNeueNr # Mat_Subs:Kombi(BAG.FM.Datum, BAG.FM.Zeit, vMarkList, "BAG.FM.Stück", v200);

  if (v200<>0) then begin
    RecBufClear(v200);
    v200 # 0;
  end;
  if (vNeueNr=0) then begin
    TRANSBRK;
    vMarkList->CteClear(true);
    Cteclose(vMarkList);
    RETURN false;
  end;

  Erx # RecRead(707,1,_recLock);
  if (Erx=_rOK) then begin
    BAG.FM.Materialnr # vNeueNr;
    Erx # RekReplace(707,_recUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
    TRANSBRK;
    vMarkList->CteClear(true);
    Cteclose(vMarkList);
    RETURN false;
  end;
  

  BAG.IO.Nummer         # BAG.FM.Nummer;
  BAG.IO.ID             # BAG.FM.BruderID;
  Erx # RecRead(701,1,_recSingleLock);
  if (erx<=_rLockeD) then begin
    Erx # RecRead(701,1,_recLock);
    if (erx=_rOK) then begin
      BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + "BAG.FM.Stück";
//    if (BAG.P.Aktion=c_BAG_MatPrd) then begin
      BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + BAG.FM.Gewicht.Netto;
      BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + BAG.FM.Gewicht.Brutt;
      if (BAG.FM.Meh=BAG.IO.MEH.In) then
        BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + BAG.FM.Menge;
//    end;
      RekReplace(701,_RecUnlock,'AUTO');
    end;
    if (Erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
      TRANSBRK;
      vMarkList->CteClear(true);
      Cteclose(vMarkList);
      RETURN false;
    end;
  end;

  vMarkList->CteClear(true);
  Cteclose(vMarkList);

  TRANSOFF;

  // ggf. Etikett drucken...
  if (aMitEtk) AND (BAG.FM.MaterialTyp=c_IO_Mat) then
      Etikettendruck();

  RETURN true;
end;


//========================================================================
//  VerbuchenPaket +ERR
//
//========================================================================
sub VerbuchenPaket(
  aEtkTxt     : int;
  aInputList  : handle;
  aMitEtk     : logic;
) : logic;
local begin
  Erx           : int;
  vItem         : handle;
  vItem2        : handle;
  vLastID       : int;

  vGesGewN      : float;
  vGesGewB      : float;
  vFaktorN      : float;
  vFaktorB      : float;
  vB            : alpha;
  vStk          : int;
  vGewN,vGewB   : float;
  vA            : alpha(1000);

  vAbschlussYN  : logic;
  vOK           : logic;
  v200          : int;
  
  vAnz          : int;
  vGesStk       : int;
  vGesB         : float;
  vGesN         : float;
  vTxt          : int;
  v700          : int;
  v701          : int;
  v702          : int;
  v703          : int;
  vPak          : int;
  vPakPos       : int;
  vInhaltStk    : int;
  vFirstMat     : int;
end;
begin

  // Ablauf:
  //    - theor. Gesamtgewicht der Einsätze errechen
  //    - dann Abweichungsfaktor pro Einsatz zum Spulenendgewicht
  //    - EINE Verwiegung 707 anlegen mit Spulenenddaten
  //    - pro Einsatz:
  //      - BAG.FM-Felder so belegen, als ob einzeln verwogen wurde (anhand Faktor)
  //        AUUSER bei dem letzten Einsatzmaterial: das wird "Rest" (wegen Faktorrundungesfehler)
  //      - Einsatzmaterial mindern (per Unterfunktionen)
  //      - Fertigmaterial anlegen (per Unterfunktionen) und in Liste merken
  //    - Finale Spule anlegen per Material-Kombi über diese Liste
  //    - Stückzahl der Spulenkarte setzen (wäre sonst Summe der Einzelkarten)
  //    - Verwiegung auf die Materialnr. der Spule setzen
  //    - im theoretischen Output die Ist-In-Stückzahl um Spulenstück erhöhen

  APPOFF();

  vAbschlussYN # n;

  // Einsatzliste loopen und theoretisches GesamtGewicht addieren + AbweichungsFaktoren errechnen...
  FOR vItem # aInputList->CteRead(_CteFirst)
  LOOP vItem # aInputList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin
    BAG.IO.Nummer # BAG.F.Nummer;
    BAG.IO.ID     # cnvia(vItem->spName);
    vLastID       # BAG.IO.ID;
    Erx # RecRead(701,1,0);   // Einsatz holen
    if (erx<>_rOK) then begin
      APPON();
      RETURN false;
    end;

    vA        # vItem->spcustom;
    vB        # Str_Token(vA, '|', 1);
    vStk      # cnvia(vB);
    vB        # Str_Token(vA, '|', 2);
    vGewN     # cnvfa(vB);
    vB        # Str_Token(vA, '|', 3);
    vGewB     # cnvfa(vB);

    vGesGewN # vGesGewN + vGewN;
    vGesGewB # vGesGewB + vGewB;
  END;

  if (vGesGewN<>0.0) then
    vFaktorN # BAG.FM.Gewicht.Netto / vGesGewN;
  if (vGesGewB<>0.0) then
    vFaktorB # BAG.FM.Gewicht.Brutt / vGesGewB;
  // ...theoretischen Einsatz errechnen

  if (BAG.FM.Datum=today) then BAG.FM.Zeit # now;

  vGesGewN  # BAG.FM.Gewicht.Netto;
  vGesGewB  # BAG.FM.Gewicht.Brutt;

  vGesStk # "BAG.FM.Stück";
  vGesB   # BAG.FM.Gewicht.Brutt;
  vGesN   # BAG.FM.Gewicht.Netto;
//debugx('KEY707 '+aint(vGesStk)+' '+anum(vGesB,2)+' '+aint(CteInfo(aInputList,_CteCount)));
  TRANSON;

  // Neues Paket erzeugen ---------------------------------------------
  vPak # Lib_Nummern:ReadNummer('Paket');    // Nummer lesen
  if (vPak=0) then begin
    Lib_Nummern:FreeNummer();
    TRANSBRK;
    APPON();
    RETURN false;
  end;
  Lib_Nummern:SaveNummer();

  RecBufClear(280);
  Pak.Nummer          # vPak;
  Pak.Typ             # 'MAT';
  Pak.Lageradresse    # Set.eigeneAdressnr;
  Pak.Lageranschrift  # 1;
  Pak.Gewicht         # vGesGewB;
  Pak.Inhalt.Stk      # 0;//  vGesStk;  2022-07-14  AH
  Pak.Inhalt.Netto    # vGesN;
  Pak.Inhalt.Brutto   # vGesB;
  Pak.Anlage.Datum    # Today;
  Pak.Anlage.Zeit     # Now;
  Pak.Anlage.User     # gUserName;
  Pak.Bemerkung       # BAG.FM.Bemerkung;
  Pak.Lagerplatz      # BAG.FM.Lagerplatz;
  Pak.Dicke           # BAG.FM.Dicke;
  Pak.Breite          # BAG.FM.Breite;
  "Pak.Länge"         # "BAG.FM.Länge";
  Erx # RekInsert(280,0,'MAN');
  if (Erx<>_rOk) then begin
    TRANSBRK;
    APPON();
    RETURN false;
  end;

  if (1=1) then begin   // EINZELRINGE
    "BAG.FM.Stück"        # 1;
    BAG.FM.Gewicht.Brutt  # Rnd(vGesB / cnvfi(vGesStk), Set.Stellen.Gewicht);
    BAG.FM.Gewicht.Netto  # Rnd(vGesN / cnvfi(vGesStk), Set.Stellen.Gewicht);
    vTxt # TextOpen(16);  // Für Etiketten die 707 merken
    vAnz # CteInfo(aInputList,_CteCount);
    vGesStk # vAnz;
  end;
//debugx('faktor:'+anum(vFaktorN,4)+' '+anum(vFaktorB,4)+'  anz:'+aint(vAnz));

  // --------------------
  FOR vItem # aInputList->CteRead(_CteFirst)
  LOOP vItem # aInputList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin
    BAG.IO.Nummer # BAG.F.Nummer;
    BAG.IO.ID     # cnvia(vItem->spName);
    Erx # RecRead(701,1,0);   // Einsatz holen
    if (erx<>_rOK) then begin
      TRANSBRK;
      APPON();
      RETURN false;
    end;
    Erx # RecLink(200,701,11,_recFirst);    // Restkarte holen
    if (erx>_rLocked) then RecBufClear(200);
//debugx(aint(vAnz));
//debugx('KEY701 KEY200');
//debugx('inputID:'+aint(BAG.FM.InputID)+' wird '+aint(BAG.IO.ID));
    // FM-Einsatzdaten setzen...
    BAG.FM.InputID  # BAG.IO.ID;
    BAG.FM.InputBAG # BAG.IO.Nummer;
    BAG.FM.BruderID # BAG.IO.NachID;
    BAG.FM.MEH      # BAG.IO.MEH.Out;
    
    vA    # vItem->spcustom;
    vB    # Str_Token(vA, '|', 1);
    vStk  # cnvia(vB);
    vB    # Str_Token(vA, '|', 2);
    vGewN # cnvfa(vB);
    vB    # Str_Token(vA, '|', 3);
    vGewB # cnvfa(vB);
    vB    # Str_Token(vA, '|', 4);

// 2022-12-20 AH    BAG.FM.MEH # BAG.F.MEH;
    "BAG.FM.Stück"        # vStk;
    BAG.FM.Gewicht.Netto  # Rnd(vGewN * vFaktorN, Set.Stellen.Gewicht);
    BAG.FM.Gewicht.Brutt  # Rnd(vGewB * vFaktorB, Set.Stellen.Gewicht);
    // 27.05.2021 AH:
    BAG.FM.RAD            # Lib_Berechnungen:RAD_aus_KgStkBDichteRID(BAG.FM.Gewicht.Netto, "BAG.FM.Stück", BAG.FM.Breite, Mat.Dichte, Mat.RID);

    RecLink(819,701,7,_recFirst);   // Warengruppe holen

    v200 # Reksave(200);
    v700 # RekSave(700);
    v701 # RekSave(701);
    v702 # RekSave(702);
    v703 # RekSave(703);

    RecBufCopy(v200, 200);
    RecBufCopy(v700, 700);
    RecBufCopy(v701, 701);
    RecBufCopy(v702, 702);
    RecBufCopy(v703, 703);
    RecRead(701,1,0);
    if (Set.Installname='HWN') and (BAG.IO.MEH.In=BAG.FM.MEH) and (BAG.FM.MEH='m') then begin // 2023-05-04 AH
      BAG.FM.Menge # Rnd(Lib_Berechnungen:Dreisatz(BAG.IO.Plan.In.Menge, BAG.IO.PLan.IN.GewN, BAG.FM.Gewicht.Netto) ,Set.Stellen.Menge);
    end
    else if (BAG.FM.MEH='kg') or (BAG.FM.MEH='t') then begin
      Erx # RekLink(818,707,6,_recfirst);     // Verwiegungsart holen
      if (Erx>_rLocked) then VwA.NettoYN # y;
      if (VWa.NettoYN) then
        BAG.FM.Menge  # BAG.FM.Gewicht.Netto
      else
        BAG.FM.Menge  # BAG.FM.Gewicht.Brutt;
      if (BAG.FM.MEH='t') then
        BAG.FM.Menge # Bag.FM.Menge / 1000.0;
    end
    else if (BAG.FM.MEH='qm') then
      BAG.FM.Menge # BAG.IO.Breite * Cnvfi("BAG.FM.Stück") * "BAG.IO.Länge" / 1000000.0;
    else if (BAG.FM.MEH='Stk') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück");
    else  if (BAG.FM.MEH='m') or (BAG.FM.MEH='lfdm') then
      BAG.FM.Menge # cnvfi("BAG.FM.Stück") * "BAG.IO.Länge" / 1000.0;
       
    // Datensatz + Anhänge speichern
    if (SaveFM(false, vAnz>0)=false) then begin
      // wieder auf Temporär setzen
      BAG.FM.Nummer           # myTmpNummer;
      BAG.FM.Fertigmeldung    # 999;
      TRANSBRK;
      APPON();
      if (vTxt<>0) then TextClose(vTxt);
      RekRestore(v200);
      RekRestore(v700);
      RekRestore(v701);
      RekRestore(v702);
      RekRestore(v703);
      RETURN false;
    end;

    // FM verbuchen MIT Paketnr
    vOK # VerBuche707(aEtkTxt, vPak);
    if (vOK=false) then begin
      Erx # _rDeadLock;
      BREAK;
    end;

    // in neues Paket eintragen...
    inc(vPakPos);
    RecBufClear(281);
    Pak.P.Nummer      # Pak.Nummer;
    Pak.P.Position    # vPakPos;
    Pak.P.MaterialNr  # Mat.Nummer;
    Erx # RekInsert(281,0,'MAN');
    vOK # (Erx=_rOk);
    vInhaltStk # vInhaltStk + Mat.Bestand.Stk;
    if (vFirstMat=0) then vFirstmat # Mat.Nummer;

    if (vTxt<>0) then
      TextAddLine(vTxt, '707|'+aint(RecInfo(707,_recID)));
  
    RekRestore(v200);
    RekRestore(v700);
    RekRestore(v701);
    RekRestore(v702);
    RekRestore(v703);
    dec(vAnz);

    Erx # _rOK;
  END;  // INPUTLIST

  // 2022-07-14 AH
  if (Erx=_rOK) and (Pak.Inhalt.Stk<>vInhaltStk) then begin
    Erx # RecRead(280,1,_RecLock);
    if (Erx=_rOK) then begin
      Pak.Inhalt.Stk # vInhaltStk;
      Erx # RekReplace(280);
    end;
  end;

  if (Erx<>_rOK) then begin
    // Datensatz + Anhänge wieder zu TEMP machen (04.03.2015)
    // wieder auf Temporär setzen
    BAG.FM.Nummer           # myTmpNummer;
    BAG.FM.Fertigmeldung    # 999;
    TRANSBRK;
    APPON();
    if (vTxt<>0) then TextClose(vTxt);
    RekRestore(v700);
    RekRestore(v701);
    RekRestore(v702);
    RekRestore(v703);
    RETURN false;
  end;

  TRANSOFF;

  //if (aKeepAppOff=false) then APPON();
  APPON();
/*** 2022-11-30 AH
  // ggf. Etikett drucken...
  if (aMitEtk) AND (BAG.FM.MaterialTyp=c_IO_Mat) and
      (BAG.P.Aktion<>c_BAG_Fahr) then begin
    if (Set.SQL.SoaYN) then
      Winsleep(500);    // wegen SQL
    if (vTxt<>0) then begin
      FOR vA # TextLineRead(vTxt, 1, _TextLineDelete)
      LOOP vA # TextLineRead(vTxt, 1, _TextLineDelete)
      WHILE (vA<>'') do begin
        if (StrCut(vA,1,3)='707') then begin
          RecRead(707,0,_recId, cnvia(Str_token(vA,'|',2)));
          if (BAG.FM.Materialnr<>0) then Mat_Data:Read(BAG.FM.Materialnr);    // 08.10.2018 AH
          Etikettendruck();
        end;
      END;
      TextClose(vTxt);
    end
    else begin
      Etikettendruck();
    end;
  end;
***/
  // ggf. Reservierungen vom Vormaterial übernehmen
  if (BAG.P.Aktion=c_BAG_Fahr) then
    VererbeReservierung(Set.LFS.ResTransfer)    // 05.04.2022 AH
  else
    VererbeReservierung();

  RunAFX('BAG.FM.Verbuchen.Inner.Post','');   // 12.04.2021 AH: BFS

  if (aMitEtk) then begin
    Mat.Nummer # vFirstMat;
    Erx # RecRead(200,1,0);
    Winsleep(500);
    Lib_Dokumente:Printform(200,'PaketEtikett',false);
  end;
  
  RETURN true;
end;


//========================================================================
//========================================================================
sub TunnelFMdurchLFA();
local begin
  Erx   : int;
  v701  : int;
  v702  : int;
end;
begin

@ifdef defBessererLFA
@else
  RETURN;
@endif

  v702 # RekSave(702);
  Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
  if (Erx>_rLocked) or (BAG.P.Aktion<>c_BAG_Fahr) then begin
    RekRestore(v702);
    RETURN;
  end;
  v701 # RekSave(701);
  // weitere VSB dahinter?

  // Outputs loopen...
  FOR Erx # RecLink(701,702,3,_recFirst)
  LOOP Erx # RecLink(701,702,3,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (BAG.IO.NachPosition=0) or (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
    Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
    if (Erx<=_rLocked) and (BAG.P.Typ.VSBYN) then begin
      BA1_F_Data:UpdateVSB(false);
    end;
    RecbufCopy(v702,702);
  END;
  
  
  RekRestore(v701);
  RekRestore(v702);
end;


//========================================================================