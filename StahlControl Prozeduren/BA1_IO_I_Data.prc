@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_IO_I_Data
//                        OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  18.03.2010  MS  BereitsVerwogen + DeleteInput
//  15.06.2011  ST  Löschen des Zusatztextes hinzugefügt
//  28.02.2012  AI  NEU: KlonenVon
//  22.02.2013  AI  "DeleteInput" entfernt die Texte nicht, das macht das Replacen der BAG.IO mit LöschenYN
//  22.05.2014  AH  Neu: "EchtWirdTheorie" und "TheorieWirdEcht"
//  09.07.2014  AH  BugFix: "EchtWirdTheorie" und "TheorieWirdEcht"
//  25.09.2015  AH  BugFix: "DeleteInput" löscht Vorgänger von vorhandenen Verwiegungen/Outputs (die alle dann ja Ausfall sind!)
//  03.11.2015  AH  "PruefeMoeglichesEinsatzMat"
//  15.03.2016  AH  AFX "BAG.IO.InRecSavePost"
//  17.10.2016  AH  "PruefeMoeglichesEinsatzMat" testet bem Fahren auf Mehrfacheinsatz wenn VSB-EK
//  17.01.2018  ST  "PruefeMoeglichesEinsatzMat" testet bei Umlagern auf VSB, oder Frei, Gesperrt
//  26.02.2018  AH  "PruefeMoeglichesEinsatzMat" erlaubt Status "VSB-Konsi" für Fahren
//  04.05.2018  AH  Fix: "DeleteInput" rechnet Output nicht neu aus, beim Löschen von Beistellugen (hatte bei Walzen dann Output gekillt)
//  23.05.2018  ST  AFX "BAG.IO.TheorieWirdEcht" hinzugefügt Projekt 1814/11
//  24.05.2018  AH  "PruefeMoeglichesEinsatzMat" bring bei Mehrfacheinsatz von VSB-Material eine Warnung (Prj.1783/13)
//  29.06.2018  AH  Neu: bei Lohn: Filter auf Lieferant/Kunde bei Materialauswahl
//  18.10.2018  AH  Edit: "TheorieWirdEcht" beim FAHREN übernimmt Kommission aus Einsatz in Fertigung + LFS
//  24.10.2018  AH  Neu: "InsertMarkedMat"
//  13.11.2018  AH  "InsertMarkedMat" nimmt nur ganze Pakete
//  18.12.2018  AH  "InsertMarkMat" rechnet Autoteilung ab Nr.2
//  06.03.2019  AH  "DeleteInput" kann BA-Pos löschen mit Argument
//  08.05.2019  AH  Neuer AFX "BAG.IO.PruefeMoeglichesEinsatzMat"
//  28.11.2019  AH  Fix: "KlonenVon" nutzt Autoteilung
//  29.07.2021  AH  ERX, "AlleTheosSkalieren"
//  03.11.2021  AH  "MatFelderInsInput"
//  17.11.2021  AH  "FindeKommission"
//  02.02.2022  AH  "MatFelderInsInput" beachtet Reservierungen auf Mat NICHT mehr (Proj. 2166/185)
//  03.02.2022  AH  "HatEinsatzReservierungen"
//  2022-07-05  AH  DEADLOCK
//  2022-12-19  AH  neue BA-MEH-Logik
//
//
//  Subprozeduren
//    SUB MatFelderInsInput();
//    SUB BereitsVerwogen() : logic;
//    SUB PruefeMoeglichesEinsatzMat() : int;
//    SUB DeleteInput(aDel702 : logic) : logic;
//    SUB LoopCheck(aT : int; aA : alpha(4000)) : logic;
//    SUB KlonenVon(aID : int; opt aNichtMindern : logic) : logic;
//    SUB EchtWirdTheorie(aID : int) : logic;
//    SUB TheorieWirdEcht(aInOutID : int; opt aMatMr : int) : logic;
//    SUB TheorieWirdID(aInOutID : int; aEinsatz : int) : logic;
//    SUB AusTheorieWirdEchtMat()
//    SUB InsertMarkedMat() : logic;
//    SUB AlleTheosSkalieren(aBA : int; aPos : int; aMengenFakt : float) : logic;
//    SUB FindeKommission(var aAufNr  : int; var aAufPos : int;) : logic
//    SUB HatEinsatzReservierungen() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

define begin
  cZList1 :   $RL.BA1.Pos
  cZList2 :   $RL.BA1.Input
  cZList3 :   $RL.BA1.Fertigung
  cZList4 :   $RL.BA1.Output
end;

//========================================================================
// IstMatBeistellung() : logic    15.11.2021
//========================================================================
sub IstMatBeistellung() : logic
begin
  RETURN (gusername='AH') and BAG.IO.Materialnr=5337;
end;

//========================================================================
// MatFelderInsInput
//========================================================================
sub MatFelderInsInput()
local begin
  vX  : float;
end;
begin
  if (BAG.P.Aktion=c_BAG_Fahr) OR (BAG.P.Aktion = c_BAG_Umlager) then begin
    BAG.IO.MEH.Out    # Mat.MEH;
  end
  else begin
    BAG.IO.MEH.Out     # Mat.MEH;   //  2022-12-19  AH  BA1_P_Data:ErmittleMEH();
  end;
  BAG.IO.MEH.IN         # BAG.IO.MEH.Out;

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
  "BAG.IO.GütenStufe"   # "Mat.GütenStufe";

  BAG.IO.Materialnr     # Mat.Nummer;
  BAG.IO.Artikelnr      # Mat.Strukturnr;
  BAG.IO.Auftragsnr     # Mat.Auftragsnr;
  BAG.IO.AuftragsPos    # Mat.AuftragsPos;
  BAG.IO.AuftragsFert   # 0;
  
  vX # 1.0;
// 02.02.2022 AH: immer ALLES anzeigen
// 02.02.2022 AH  if (Mat.Bestand.Gew<>0.0) and (Mat.Reserviert.Gew<>0.0) then vX # 1.0 - (Mat.Reserviert.Gew / Mat.Bestand.Gew);
// ist 100, res 20, verf 80
// verfügbar errechnen : 20 / 100 =  0,2; 1 - 0,2 =0,8 *bestand
// 02.02.2022  BAG.IO.Plan.In.Stk    # Max("Mat.Verfügbar.Stk",1);// Mat.Bestand.Stk;//"Mat.Verfügbar.Stk"; 03.11.2021 HWN
  BAG.IO.Plan.In.Stk    # Max("Mat.Bestand.Stk",1);
  
  BAG.IO.Plan.In.GewN   # Rnd(Mat.Gewicht.Netto * vX,Set.Stellen.Gewicht);
  BAG.IO.Plan.In.GewB   # Rnd(Mat.Gewicht.Brutto * vX,Set.Stellen.Gewicht);
  if (BAG.IO.Plan.In.GewN=0.0) then BAG.IO.Plan.In.GewN # Rnd(Mat.Bestand.Gew * vX,Set.Stellen.Gewicht);
  if (BAG.IO.Plan.In.GewB=0.0) then BAG.IO.Plan.In.GewB # Rnd(Mat.Bestand.Gew * vX,Set.Stellen.Gewicht);
  if (BAG.IO.MEH.IN=Mat.MEH) then begin
    BAG.IO.Plan.In.Menge # Mat.Bestand.Menge * vX;
  end
  else if (BAG.IO.MEH.In='qm') then begin
    "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
    BAG.IO.Plan.In.Menge  # Rnd( cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0 , Set.Stellen.Menge);
    "BAG.IO.Länge"        # "Mat.Länge";
  end
  else if (BAG.IO.MEH.In='m') then begin
    BAG.IO.Plan.In.Menge # Lib_Einheiten:WandleMEH(200, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, 0.0, '', BAG.IO.MEH.Out);
  end
  else if (BAG.IO.MEH.In='kg') then begin
    BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.GewN;
  end;

  BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
  BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
  BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
  BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

  BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
  BAG.IO.Warengruppe    # Mat.Warengruppe;
  BAG.IO.Lageradresse   # Mat.Lageradresse;
  BAG.IO.Lageranschr    # Mat.Lageranschrift;
end;


//========================================================================
//  BereitsVerwogen
//
//========================================================================
sub BereitsVerwogen() : logic;
local begin
  vBuf702 : int;
  vOk     : logic;
end;
begin
  // bereits Verwogen?
  vBuf702 # RekSave(702);
  vOK # false;
  if (BAG.IO.Ist.Out.Stk<>0) or (BAG.IO.Ist.Out.Menge<>0.0) or (BAg.IO.ISt.Out.GewN<>0.0) or (BAg.IO.ISt.Out.GewB<>0.0) then
    vOK # true;
  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);
  //if (RecLinkInfo(707,702,5,_RecCount)<>0) then vOK # n;
  RekRestore(vBuf702);

  return vOK;
end;


//========================================================================
// PruefeMoeglichesEinsatzMat
//
//========================================================================
sub PruefeMoeglichesEinsatzMat(opt aTyp : int) : int;
local begin
  Erx   : int;
  v701  : int;
  v200  : int;
end;
begin

  if (aTyp=0) then aTyp # BAG.IO.Materialtyp;

  // 08.05.2019
  if (RunAFX('BAG.IO.PruefeMoeglichesEinsatzMat',aint(aTyp))<0) then begin
    RETURN AfxRes;
  end;

  if ("Mat.Löschmarker"<>'') then RETURN 441002;
  if (aTyp=c_IO_Mat) then begin
    if (Bag.P.Aktion = c_BAG_Umlager) then begin
      // Umfuhr nur Material welches frei um Lager, VSB Auftrag oder Schrott
      if (Mat.Status>c_Status_VSBKonsiRahmen) AND (Mat.Status < c_Status_BAGSchrott) then
        RETURN 441002;
    end
    else begin
      if (BAG.P.Aktion=c_BAG_Fahr09) then begin
        // 26.02.2018...
        if (BAG.P.ZielVerkaufYN=false) then begin
          if (Mat.Status<=c_Status_bisFrei) or ((Mat.Status>=c_Status_Sonder) and (Mat.Status<=c_Status_bisSonder))  then RETURN 0;
        end;

        if ((Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_Status_VSB) and (Mat.Status<>c_Status_VSBKonsi) and
           ((Mat.Status<c_Status_Sonder) or (Mat.Status>c_Status_bisSonder))) then begin
          RETURN 441002;
        end;
      end
      else begin
        // 16.08.2021 AH: auch für EKVSB
        if ((Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_Status_EKVSB) and
           (Mat.Status<c_Status_Sonder)) or (Mat.Status>c_Status_bisSonder) then begin
          RETURN 441002;
        end;
      end;
    end;

  end;
  if (aTyp=c_IO_VSB) and (Mat.Status<>c_Status_EKVSB) and (Mat.Status<>c_Status_EK_Konsi) then
    RETURN 441002;

  //  17.10.2016 AH:
  if (BAG.P.Aktion=c_BAG_Fahr09) and (aTyp=c_IO_VSB) then begin
    v701 # RecBufCreate(701);
    v701->BAG.IO.Materialnr # Mat.Nummer;
    if (RecRead(v701,9,_recTest | _recNoLoad)<=_rMultikey) then begin
      RecBufDestroy(v701);
      RETURN 441010;
    end;
    RecBufDestroy(v701);
  end;


  // 24.05.2018 AH;
  if (aTyp=c_IO_VSB) then begin
    v701 # RecBufCreate(701);
    v701->BAG.IO.Materialnr # Mat.Nummer;
    Erx # RecRead(v701,9,_recTest);
    if (Erx<=_rMultikey) then begin
      v200 # RekSave(200);
      if (Msg(701042,'',0,0,0)<>_Winidyes) then begin
        RekRestore(v200);
        RETURN 441002;
      end;
      RekRestore(v200);
    end;
  end;

  RETURN 0;
end;


//========================================================================
//  DeleteInput
//
//========================================================================
sub DeleteInput(aDel702 : logic) : logic;
local begin
  Erx   : int;
  vA    : alpha;
  vTxt  : handle;
  v701  : int;
end;
begin

  TRANSON;

  // Eintrag zum Löschen markieren
  Erx # RecRead(701,1,_recLock);
  if (erx=_rOK) then begin
    "BAG.IO.LöschenYN" # y;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
    TRANSBRK;
    Msg(701006,'',0,0,0);
    RETURN false;
  end;
  
  // Output aktualisieren
  if (BAG.IO.Materialtyp!=c_IO_Beistell) then begin // 04.05.2018 AH
    if (BA1_F_Data:UpdateOutput(701,y, aDel702)=false) then begin
      TRANSBRK;
      ERROROUTPUT;  // 01.07.2019
      RETURN false;
    end;
  end;

  // Fahren? -> Fertigung mit löschen
  if (BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielverkaufYN) then begin
    Erx # RecLink(703,701,10,_recFirst);    // nach Fertigung holen
    if (Erx<=_rLocked) then begin
      if (RecLinkInfo(701,703,3,_reccount)=1) then begin
        if (BA1_F_data:Delete()=false) then begin
          TRANSBRK;
          Msg(701006,'',0,0,0);
          RETURN false;
        end;
      end;
    end;
  end;


  // 25.09.2015: Verwiegungen loopen...
  v701 # RekSave(701);
  FOR Erx # RekLink(707,701,12,_recFirst)
  LOOP Erx # RekLink(707,701,12,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.FM.Status<>c_Status_BAGAusfall) then begin
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;

    // Verwiegungsvorgänger entfernen...
    Erx # RecRead(707,1,_recLock);
    if (erx=_rOK) then begin
      BAG.FM.InputID # 0;
      Erx # RekReplace(707);
    end;
    if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;

    // Outputvorgänger entfernen...
    Erx # RecLink(701,707,8,_recFirst|_recLock);   // Output holen
    if (Erx<=_rLocked) then begin
      BAG.IO.VonID        # 0;
      Erx # RekReplace(701);
    end;
    if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
      TRANSBRK;
      Msg(701006,'',0,0,0);
      RETURN false;
    end;
    RecBufCopy(v701, 701);

  END;
  RekRestore(v701);


  // Input löschen/anpassen
  case (BAG.IO.MaterialTyp) of

    c_IO_VSB : begin   // VSB-Material
      // Einsatzmaterial reaktivieren?
      if (BA1_Mat_Data:VSBFreigeben()=false) then begin
        TRANSBRK;
        Msg(701006,'',0,0,0);
        RETURN false;
      end;
      Erx # BA1_IO_Data:Delete(0,'MAN');
      if (Erx <> _rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;


    c_IO_BAG : begin
      Erx # RecRead(701,1,_recLock);
      if (erx=_rOK) then begin
        BAG.IO.NachBAG        # 0;
        BAG.IO.NachPosition   # 0;
        BAG.IO.NachFertigung  # 0;
        BAG.IO.NachID         # 0;
        "BAG.IO.LöschenYN"    # n;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
      end;
      if (erx<>_rOK) then begin   // 2022-07-05 AH DEADLOCK
        TRANSBRK;
        Msg(701006,'',0,0,0);
        RETURN false;
      end;
    end;


    c_IO_Mat : begin
      // Einsatzmaterial reaktivieren?
      if (BA1_Mat_Data:MatFreigeben()=false) then begin
        TRANSBRK;
        Msg(701006,'',0,0,0);
        RETURN false;
      end;
      Erx # BA1_IO_Data:Delete(0,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;


    c_IO_Theo : begin
      Erx # BA1_IO_Data:Delete(0,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
      // 10.04.2019 AH: ggf. Mat.Reservierung löschen
      RecBufClear(203);
      "Mat.R.Trägertyp"     # c_Akt_BAInput;
      "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
      "Mat.R.TrägerNummer2" # BAG.IO.ID;
      Erx # RecRead(203,7,0); // Reservierung holen
      if (Erx<=_rMultikey) then begin
        if (Mat_Rsv_Data:Entfernen()=false) then begin
          TRANSBRK;
          RETURN false;
        end;
      end;
    end;


    c_IO_Art, c_IO_Beistell : begin
      // Einsatzartikel freigeben
      if (BA1_Art_Data:ArtFreigeben()=false) then begin
        TRANSBRK;
        Msg(701006,'',0,0,0);
        RETURN false;
      end;
      Erx # BA1_IO_Data:Delete(0,'MAN');
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;

  end;

  TRANSOFF;


  // nächste Pos. holen
  RecLink(702,701,4,_recFirst);
  // alle Fertigungen neu errechnen
  BA1_P_Data:ErrechnePlanmengen();

  // 05.03.2019 AH: Soll 702 gelöscht werden, wenn kein weiterer Input?
  if (aDel702) then begin
//debugx('KILL KEY702');
    if (RecLinkInfo(701,702,2,_recCount)=0) then begin  // Inputs zählen
      if (BA1_P_Data:Delete(true)=false) then begin
        TRANSBRK;
//        Error(701006,'',0,0,0);
        RETURN false;
      end;
    end;
  end;

  RETURN true;
end;


//========================================================================
//  LoopCheck
//
//========================================================================
sub LoopCheck(aT : int; aA : alpha(4000)) : logic;
local begin
  vErx    : int;
  vA      : alpha;
  vBuf701 : int;
  vBuf702 : int;
  vOk     : logic;
  vFirst  : logic;
  vNr     : int;
  vPos    : int;
  vID     : int;
end;
begin
  vBuf701 # RecBufCreate(701);
  RecBufCopy(701,vBuf701);
  vBuf702 # RecBufCreate(702);
  RecBufCopy(702,vBuf702);

  if (aT=0) then begin            // 1. Aufruf?
    aT # Textopen(3);
    vFirst # y;
  end;

  vOk # y;


  // aktuelle Position aufnehmen
  vA # 'P'+Cnvai(BAG.P.Nummer)+'/'+cnvai(BAG.P.Position)+',';
//debug('checke: '+va);
  if (StrFind(aA,vA,1)<>0) then begin
//debug('LOOP!');
    RecBufCopy(vBuf701,701);
    RecBufDestroy(vBuf701);
    RecBufCopy(vBuf702,702);
    RecBufDestroy(vBuf702);
    RETURN false;
  end;

  if (TextSearch(aT,1,1,0,vA)<>0) then begin  // schon geprüft?
//debug('bereits geprüft');
    RecBufCopy(vBuf701,701);
    RecBufDestroy(vBuf701);
    RecBufCopy(vBuf702,702);
    RecBufDestroy(vBuf702);
    RETURN true;
    end
  else begin
    TextLineWrite(aT,1,vA,_TextLineInsert);
  end;

  if (vFirst) then begin
    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      RecLink(702,701,2,_recFirst);   // Vorgänger Arbeitsgang holen
//debug('FIRST');
      vOk # LoopCheck(aT,vA);
    end;
    end

  else begin

    vErx # RecLink(701,702,2,_RecFirst);    // Input loopen
    WHILE (vErx<=_rLocked) and (vOK) do begin
      if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
        vNr   # BAG.P.Nummer;
        vPos  # BAG.P.Position;
        vID   # BAG.IO.ID;
        RecLink(702,701,2,_recFirst);       // Vorgänger Arbeitsgang holen

//debug('rekursion...');
        vOk # LoopCheck(aT,aA+vA);

        BAG.P.Nummer    # vNr;
        BAG.P.Position  # vPos;
        BAG.IO.ID       # vID;
        RecRead(701,1,0);
        RecRead(702,1,0);
      end;
      vErx # RecLink(701,702,2,_RecNext);
    END;
  end;

  RecBufCopy(vBuf701,701);
  RecBufDestroy(vBuf701);
  RecBufCopy(vBuf702,702);
  RecBufDestroy(vBuf702);

  if (vFirst) then begin
//    Txtwrite(aT,'c:\test.txt',_textExtern);
    TextClose(aT);
  end;
/*
if (vOK) then
debug('             ok')
else
debug('             LOOP');
*/
  RETURN vOK;
end;


//========================================================================
//  BiegeKinderUm
//
//========================================================================
sub BiegeKinderUm(
  aParent       : int;
  aVorlagePar   : int) : alpha;
local begin
  vKindNeu  : int;
  vFert     : int;
  vNachBAG  : int;
  vNachPos  : int;
  vNachFert : int;
  vBuf702   : int;
  vTmp      : int;
  vErr      : alpha;
  vBuf701   : int;
  vAuf      : int;
  vAufPos   : int;
  vAufFert  : int;
  vKGMM_Kaputt  : logic;
  Erx       : int;
end;
begin
//debugx('BIEGE '+aint(aParent)+' '+aint(aVorlagePar));

  // "neuen" Output loopen
  FOR Erx # RecLink(701,702,3,_RecFirst)
  LOOP Erx # RecLink(701,702,3,_RecNext)
  WHILE (Erx<=_rLocked) and (vErr='') do begin
    if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
    if (BAG.IO.VonID<>aParent) then CYCLE;

    vFert     # BAG.IO.VonFertigung;
    vAuf      # BAG.IO.Auftragsnr;
    vAufPos   # BAG.IO.AuftragsPos;
    vAufFert  # BAG.IO.AuftragsFert;


    vKindNeu # RekSave(701);

    // "vorlage" Output loopen
    FOR Erx # RecLink(701,702,3,_RecFirst)
    LOOP Erx # RecLink(701,702,3,_RecNext)
    WHILE (Erx<=_rLocked) and (vErr='') do begin
      if (BAG.IO.Materialtyp<>c_IO_BAG) then CYCLE;
      if (BAG.IO.VonID<>aVorlagePar) then CYCLE;
      // bei VK-Fahren sind die "aus"-Fertigungen egal, da zählt nur die Kommission
      if ((BAG.P.Aktion=c_BAG_Fahr09) and (BAG.P.ZielverkaufYN)) then begin
        if (vAuf<>BAG.IO.Auftragsnr) or (vAufPos<>BAG.IO.AuftragsPos) or (vAufFert<>BAG.IO.AuftragsFert) then CYCLE;
        end
      else begin
        if (BAG.IO.VonFertigung<>vFert) then CYCLE;
      end;

      vNachBAG  # BAG.IO.NachBAG;
      vNachPos  # BAG.IO.NachPosition;
      vNachFert # BAG.IO.NachFertigung;
      
      vBuf701 # RekSave(701);
      vBuf702 # RekSave(702);

      RecbufCopy(vKindNeu,701);
//debug('ändere Kind '+aint(bag.io.id)+' auf '+aint(vNachBAG)+'/'+aint(vNachPos));
      BAG.P.Nummer   # vNachBAG;
      BAG.P.Position # vNachPos;
      Erx # RecRead(702,1,0); // nach-Position holen
      Erx # RecRead(701,1,_recLock);
      if (erx=_rOK) then begin
        BAG.IO.NachBAG      # vNachBAG;
        BAG.IO.NachPosition # vNachPos;
        BAG.IO.NachFertigung # vNachFert;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
      end;
      if (Erx<>_rOk) then vErr # 'Rückspeichern fehlgeschlagen!';
      if (vErr='') then begin
        // Output aktualisieren
        if (BA1_F_Data:UpdateOutput(701,n)=false) then vErr # 'Output nicht updatebar';
      end;

      // 28.11.2019 AH: Teilungen errechnen
      if (vErr='') then begin
        if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then vErr # 'Teilungen passen nicht';
        if (vKGMM_Kaputt) then begin
  //          Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
          vErr # 'Teilungen passen nicht';
        end;
      end;

      if (vErr='') then begin
/**
        vTmp # RecBufCreate(701);
        vTmp->BAG.IO.Nummer # BAG.IO.Nummer;
        vTmp->BAG.IO.ID     # aVorlagePar;
        Erx # RecRead(vTmp, 1,0);
        if (Erx>_rLocked) then vErr # 'VorlageParent nicht gefunden!';
        if (vErr='') then begin
//debug('tiefe : '+aint(bag.io.id)+'   temp:'+aint(vTmp->bag.io.id)+' nach '+aint(vTmp->BAG.IO.NachID)+'  '+aint(vBuf701->BAG.Io.ID));
          Ding(bag.io.id, vTmp->BAG.IO.NachID);
        end;
**/
//debug('tiefe : '+aint(bag.io.id)+'   buf:'+aint(vBuf701->bag.io.id));
          BiegeKinderUm(bag.io.id, vBuf701->BAG.IO.ID);
//        RecBufDestroy(vTmp);
      end;

      RekRestore(vBuf702);
      RekRestore(vBuf701);
    END;

    RekRestore(vKindNeu);
  END;

  RETURN vErr;
end;


//========================================================================
//  KlonenVon
//
//========================================================================
SUB KlonenVon(
aID               : int;
opt aNichtMindern : logic) : logic;
local begin
  Erx         : int;
  vVorlage    : int;
  vKlon       : int;
  vErr        : alpha;
  vTmp        : int;
  vID         : int;
end;
begin

  vKlon     # RekSave(701);
  vVorlage  # RecBufCreate(701);

  // Vorlage Input holen...
  vVorlage->BAG.IO.Nummer # BAG.IO.Nummer
  vVorlage->BAG.IO.ID     # aID;
  Erx # RecRead(vVorlage,1,0);
  if (Erx>_rlocked) then vErr # 'Vorlage nicht gefunden!';

  if (vErr='') then begin
    // Theorie mindern
    if (vVorlage->BAG.IO.Materialtyp=c_IO_Theo) and (aNichtMindern=false) then begin
      RecBufCopy(vVorlage,701);
      Erx # RecRead(701, 1, _recLock);
      if (Erx<>_rOk) then vErr # 'Vorlage nicht änderbar!';
      if (vErr='') then begin
//        BAG.IO.Plan.In.Stk    # BAG.IO.Plan.In.Stk - vKlon->BAG.IO.Plan.In.Stk;
        BAG.IO.Plan.In.GewN   # BAG.IO.Plan.In.GewN - vKlon->BAG.IO.Plan.In.GewN;
        BAG.IO.Plan.In.GewB   # BAG.IO.Plan.In.GewB - vKlon->BAG.IO.Plan.In.GewB;
        BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.Menge - vKlon->BAG.IO.Plan.In.Menge;
//        BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.Out.Stk - vKlon->BAG.IO.Plan.Out.Stk;
        BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.Out.GewN - vKlon->BAG.IO.Plan.Out.GewN;
        BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.Out.GewB - vKlon->BAG.IO.Plan.Out.GewB;
        BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.Out.Meng - vKlon->BAG.IO.Plan.Out.Meng;
        Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOk) then vErr # 'Rückspeichern fehlgeschlagen!';
        if (vErr='') then begin
          // Output aktualisieren
          if (BA1_F_Data:UpdateOutput(701,n)=false) then vErr # 'Output nicht updatebar';
        end;
      end;
    end;

    // neuen Pfad bauen...
    vErr # BiegeKinderUm(vKlon->BAG.IO.ID, vVorlage->BAG.IO.ID);
  end;


  RekRestore(vKlon);
  if (vErr<>'') then begin
todo(verr);
    RecBufDestroy(vVorlage);
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  EchtWirdTheorie +Error
//
//========================================================================
SUB EchtWirdTheorie(aID : int) : logic;
local begin
  Erx : int;
end;
begin

  BAG.IO.Nummer # BAG.Nummer;
  BAG.IO.ID     # aID;
  Erx # RecRead(701,1,0);
  if (Erx>_rLocked) then RETURN false;
  if (BAG.IO.Materialnr=0) then RETURN false;
  if (BAG.IO.MaterialTyp<>c_IO_Mat) and (BAG.IO.MaterialTyp<>c_IO_VSB) then RETURN false;

  // bereits Fertiggemeldet???
  if (RecLinkInfo(707,701,12,_recCount)>0) then begin
    Error(701007,'');
    RETURN false;
  end;
// oder
//  if (BA1_IO_I_Data:BereitsVerwogen() = true) then
//    Msg(701007,'',0,0,0);

  TRANSON;

  if (BAG.IO.MaterialTyp=c_IO_Mat) and (BA1_Mat_Data:MatFreigeben()=false) then begin
    TRANSBRK;
    RETURN false;
  end
  else if (BAG.IO.MaterialTyp=c_IO_VSB) and (BA1_Mat_Data:VSBFreigeben()=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  Erx # RecRead(701,1,_recLock);
  if (Erx=_rOK) then begin
    BAG.IO.Materialtyp    # c_IO_Theo;
    BAG.IO.Materialnr     # 0;
    BAG.IO.MaterialRstnr  # 0;
    Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
  end;
  if (erx<>_rOK) then begin
    TRANSBRK;
    RETURN false;
  end;

  TRANSOFF;

  Msg(999998,'',0,0,0);

  RETURN true;
end;


//========================================================================
//  TheorieWirdEcht
//
//========================================================================
SUB TheorieWirdEcht(
  aInOutID    : int;
  opt aMatNr  : int;
  opt aStk    : int;
  opt aGewN   : float;
  opt aGewB   : float;
  opt aMenge  : float;
  ) : logic;
local begin
  Erx           : int;
  vTmp          : int;
  vKGMM_Kaputt  : logic;
  vTlgErr       : int;
  vErr          : int;
  vQ            : alpha(4000);
  v400,v100     : int;
end;
begin
  
  // ST 2018-05-23 Projekt 1814/11
  if (RunAFX('BAG.IO.TheorieWirdEcht',aint(aInOutID) + '|' + Aint(aMatNr)) <> 0) then
    RETURN (AfxRes=_rOk);

  if (aInOutID<>0) and (aMatNr<>0) then begin
    BAG.IO.Nummer # BAG.Nummer;
    BAG.IO.Id     # aInOutID;
    RecRead(701,1,0);
    Mat.Nummer    # Mat.Nummer;
    RecRead(200,1,0);

    vErr # PruefeMoeglichesEinsatzMat(c_IO_Mat);
    if (vErr<>0) then begin
      if (vErr<>-1) then Msg(vErr,'',0,0,0);
      RETURN false;
    end;

    // 19.11.2019 kann auch Teil:
    if (aStk=0) then      aStk # Mat.Bestand.Stk;
    if (aGewN=0.0) then   aGewN # Mat.Gewicht.Netto;
    if (aGewB=0.0) then   aGewB # Mat.Gewicht.Netto;
    if (aMenge=0.0) then  aMenge # Mat.Bestand.Menge;


    TRANSON;

    Erx # RecRead(701,1,_recLock);
    if (erx=_rOK) then begin
      // Feldübernahme
      // 2023-08-17 AH    Proj. 2430/109
      if (Mat.Status=502) then
        BAG.IO.Materialtyp    # c_IO_VSB
      else
        BAG.IO.Materialtyp    # c_IO_Mat;

      MatFelderInsInput();    // 03.11.2021 AH

      BAG.IO.Plan.In.Stk    # aStk;
      BAG.IO.Plan.In.GewB   # aGewB;
      BAG.IO.Plan.In.GewN   # aGewN;
      if (BAG.IO.Plan.In.GewN=0.0) then BAG.IO.Plan.In.GewN # aGewB;
      if (BAG.IO.Plan.In.GewB=0.0) then BAG.IO.Plan.In.GewB # aGewN;
      if (BAG.IO.MEH.IN=Mat.MEH) then begin
        BAG.IO.Plan.In.Menge # aMenge;
      end;

      BAG.IO.Ist.Out.Menge   # 0.0;
      BAG.IO.Ist.Out.Stk     # 0;
      BAG.IO.Ist.Out.GewN    # 0.0;
      BAG.IO.Ist.Out.GewB    # 0.0;

      // Ankerfunktion?
      RunAFX('BAG.IO.Auswahl.Mat','');

      // VSB-Material auf diesen neuen Einsatz hin anpassen
      if (BAG.IO.MaterialTyp=c_IO_VSB) then begin
        if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
          TRANSBRK;
          Msg(701005,'',0,0,0);
          RETURN false;
        end;
      end;

      // Material auf diesen neuen Einsatz hin anpassen
      if (BAG.IO.MaterialTyp=c_IO_Mat) then begin
        if (BA1_Mat_Data:MatEinsetzen()=false) then begin
          TRANSBRK;
          Msg(701005,'',0,0,0);
          RETURN false;
        end;
      end;
      Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

/**** 18.10.2018 AH
    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      Error(701010,'');
      ErrorOutput;
      RETURN false;
    end;
****/

    // 18.10.2018 AH: von weiter unten
    if ("BAG.P.Typ.1In-1OutYN") then begin
      if (BAG.P.Aktion=c_BAG_Fahr) then begin
        BA1_P_Data:ErrechnePlanmengen(true);
      end
      else begin
        BA1_P_Data:ErrechnePlanmengen();
      end;
    end;


    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
// 25.03.2019     TRANSBRK;
//      Error(701010,'');
//      ErrorOutput;
//      RETURN false;
    end;


    // Input: Weiterbearbeitung oder Material...
    if (vTlgErr=0) then begin
      if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          ErrorOutPut;
          RETURN false;
        end
        else begin
          vTlgErr # 1;
        end;
      end;
    end;
/*** 18.10.2018 AH: weiter oben
    if ("BAG.P.Typ.1In-1OutYN") then begin
      BA1_P_Data:ErrechnePlanmengen();
    end;
***/

    TRANSOFF;

    // AFX 15.03.2016 AH laut HB
    RunAFX('BAG.IO.InRecSavePost','');


    if (vKGMM_Kaputt) then begin
      Msg(703006,aint(BAG.P.Position),_WinIcoWarning, _WinDialogOk, 0);
    end;

// 25.03.2019    if (vTLGErr<>0) then begin
      ErrorOutput;
//    end;

    Lib_guicom2:Refresh_List(cZList2, _WinLstRecFromRecID | _WinLstRecDoSelect);
    Lib_guicom2:Refresh_List(cZList3, _WinLstFromFirst | _WinLstRecDoSelect);
    Lib_guicom2:Refresh_List(cZList4, _WinLstFromFirst | _WinLstRecDoSelect);
    Lib_guicom2:Refresh_List(gZLlist, _WinLstRecFromRecID | _WinLstRecDoSelect);

    RETURN true;
  end;

  // sonst Auswahl Material:
  RecBufClear(200);         // ZIELBUFFER LEEREN
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mat.Verwaltung',here+':AusTheorieWirdEchtMat');

  // LOHN? Dann Filtern   29.06.2018 AH
  if (BAG.P.Auftragsnr<>0) then begin
    v400 # RecBufCreate(400);
    v400->Auf.Nummer # BAG.P.Auftragsnr;
    Erx # RecRead(v400,1,0);                  // Auftrag holen
    if (Erx<=_rLocked) then begin
      v100 # RecBufCreate(100);
      Erx # RecLink(v100,v400,1,_recFirst);   // Kunde holen
      if (Erx<=_rLocked) then begin
        VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
        vQ # '';
        Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');
        Lib_Sel:QInt(var vQ, 'Mat.Lieferant', '=', v100->Adr.LieferantenNr);
        Lib_Sel:QVonBisI(var vQ, 'Mat.Status', c_Status_Frei, c_Status_BisFrei);
        Lib_Sel:QRecList(0,vQ);
      end;
      RecBufDestroy(v100);
    end;
    RecBufDestroy(v400);
  end;
  
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  TheorieWirdID +ERR
//          Ersetzt einen Theo-Einsatz durch eine Weiterbearbeitungs ID
//========================================================================
SUB TheorieWirdID(
  aZielID     : int;
  aEinsatzID  : int) : logic;
local begin
  Erx       : int;
  v701      : int;
  vLock     : logic;
  vAltUrID  : int;
  vNeuUrID  : int;
  v701Alt   : int;
end;
begin

  // zu Ersetzender muss Theorie sein...
  BAG.IO.Nummer # BAG.Nummer;
  BAG.IO.Id     # aZielID;
  Erx # RecRead(701,1,0);
  if (Erx>_rLocked) or (BAG.IO.Materialtyp<>c_IO_Theo) then begin
    Error(999999,ThisLine);
    RETURN false;
  end;
  vAltUrID #  BAG.IO.VonID;
  if (BAG.IO.UrsprungsID<>0) then vAltUrID # BAG.IO.UrsprungsID;

  TRANSON;

  v701 # RekSave(701);
  // zu ersetzenden löschen...
  if (RekDelete(701)<>_rOK) then begin
    TRANSBRK;
    RekRestore(v701);
    Error(999999,ThisLine);
    RETURN false;
  end;

  // Eingefügter muss Weiterbearbeitung und ohne Nachfolger sein...
  BAG.IO.Nummer # BAG.Nummer;
  BAG.IO.ID     # aEinsatzID;
  Erx # RecRead(701,1,_recLock);
  if (Erx<>_rOK) or (BAG.IO.Materialtyp<>c_IO_BAG) then begin
    TRANSBRK;
    RekRestore(v701);
    Error(999999,ThisLine);
    RETURN false;
  end;
  if (BAG.IO.NachBAG<>0) then begin
    TRANSBRK;
    RekRestore(v701);
    Error(999999,ThisLine);
    RETURN false;
  end;

  // Umbiegen...
  BAG.IO.NachBAG        # v701->BAG.IO.NachBAG;
  BAG.IO.NachPosition   # v701->BAG.IO.NachPosition;
  BAG.IO.NachFertigung  # v701->BAG.IO.NAchFertigung;
  BAG.IO.NachID         # v701->BAG.IO.NachID;

  v701Alt # RecBufCreate(701);
  RecRead(v701Alt, 0, _recId, RecInfo(701,_recID));
  Erx # RekReplace(701);
  if (Erx=_rDeadLock) then begin
    TRANSBRK;
    RekRestore(v701);
    Error(1010,ThisLine);
    RETURN false;
  end;
  if (erx=_rOK) then begin
    Rso_Rsv_Data:Update701(v701Alt);
    Erx # _rOK;
  end;
  RecBufDestroy(v701Alt);


  vNeuUrID #  BAG.IO.VonID;
  if (BAG.IO.UrsprungsID<>0) then vNeuUrID # BAG.IO.UrsprungsID;

  RecBufDestroy(v701);

  // Alle folgenden InOuts transferieren...
  FOR Erx # RecLink(701, 700, 3, _recFirst)
  LOOP Erx # RecLink(701, 700, 3, _recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.VonID=aZielID) then begin
      erx # RecRead(701,1,_recLock);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RekRestore(v701);
        Error(999999,ThisLine);
        RETURN false;
      end;
      vLock # y;
      BAG.IO.VonID # aEinsatzID;
    end;

    if (BAG.IO.UrsprungsID=vAltUrID) then begin
      if (vLock=false) then begin
        Erx # RecRead(701,1,_recLock);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RekRestore(v701);
          Error(999999,ThisLine);
          RETURN false;
        end;
        vLock # y;
      end;
      BAG.IO.UrSprungsID # vNeuUrID;
    end;

    if (BAG.IO.BruderID=aZielID) then begin
      if (vLock=false) then begin
        Erx # RecRead(701,1,_recLock);
        if (Erx<>_rOK) then begin
          TRANSBRK;
          RekRestore(v701);
          Error(999999,ThisLine);
          RETURN false;
        end;
        vLock # y;
      end;
      BAG.IO.BruderID # aEinsatzID;
    end;

    if (vLock) then begin
      vLock # false;

      v701Alt # RecBufCreate(701);
      RecRead(v701Alt, 0, _recId, RecInfo(701,_recID));
      Erx # RekReplace(701);
      if (Erx=_rDeadLock) then begin
        TRANSBRK;
        RecBufDestroy(v701Alt);
        RekRestore(v701);
        Error(1010,ThisLine);
        RETURN false;
      end;
      if (Erx=_rOK) then begin
        Rso_Rsv_Data:Update701(v701Alt);
        Erx # _rOK;
      end;
      RecBufDestroy(v701Alt);
      if (Erx<>_rOK) then begin
        TRANSBRK;
        RekRestore(v701);
        Error(999999,ThisLine);
        RETURN false;
      end;
    end;

  END;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  AusTheorieWirdEchtMat()
//
//========================================================================
sub AusTheorieWirdEchtMat()
local begin
  Erx         : int;
  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vAnz        : int;
  v701        : int;
  vKGMM_Kaputt  : logic;
  vErr        : int;
end;
begin
  if (gSelected=0) then RETURN;

  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile=200) then inc(vAnz);
    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;

  // KEINE Markierung?
  if (vAnz=0) then begin
    Erx # RecRead(200,0,_RecId, gSelected);
    gSelected # 0;
    if (Erx<=_rLocked) then begin
      if (TheorieWirdEcht(BAG.IO.ID, Mat.Nummer)) then Msg(999998,'',0,0,0);
    end;
    RETURN;
  end;

  // per Markierungen ----------------------
  TRANSON;
  v701 # RekSave(701);
  gSelected # 0;
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then CYCLE;
    RecRead(200,0,_RecId,vMID);
    dec(vAnz);
    if (vAnz=0) then begin
      if (TheorieWirdEcht(BAG.IO.ID, Mat.Nummer)=false) then begin
        TRANSBRK;
        RekRestore(v701)
        Msg(999999,'',0,0,0);
        RETURN;
      end;
    end
    else begin

      // 09.04.2020 AH: auch KLONINPUT prüfen...
      vErr # PruefeMoeglichesEinsatzMat(c_IO_Mat);
      if (vErr<>0) then begin
        TRANSBRK;
        RekRestore(v701)
        Msg(999999,'',0,0,0);
        RETURN;
      end;

      // als Einsatz aufnehmen
      if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer)=false) then begin // MIT AUTOTEILUNG !!!
        TRANSBRK;
        RekRestore(v701)
        Msg(999999,'',0,0,0);
        RETURN;
      end;

      // 18.12.2018 Autoteilung...
      if (BA1_IO_data:Autoteilung(var vKGMM_Kaputt)=false) then begin
        if (Set.BA.AutoT.NurWarn=false) then begin
          TRANSBRK;
          RekRestore(v701)
          ErrorOutput;
          RETURN;
        end
        else begin
          //vTlgErr # 1;
        end;
      end;

      // Output aktualisieren
      if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
        TRANSBRK;
        RekRestore(v701)
        Error(701010,'');
        ErrorOutput;
        RETURN;
      end;
      
      // dann gleichen Weg nehmen
      if (KlonenVon(v701->BAG.IO.ID)=false) then begin
        TRANSBRK;
        RekRestore(v701)
        Msg(999999,'',0,0,0);
        RETURN;
      end;
      RecBufCopy(v701,701);
    end;

  END;
  TRANSOFF;

  // Markierungen löschen...
  Lib_Mark:Reset(200);

  Msg(999998,'',0,0,0);

end;


//========================================================================
//  InsertMarkedMat
//========================================================================
sub InsertMarkedMat() : logic;
local begin
  Erx         : int;
  vItem       : int;
  vMFile      : int;
  vMID        : int;
  vAnz        : int;
  v701        : int;
  vFirst      : logic;
  vPak        : int;
end;
begin
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then CYCLE;

    Erx # RecRead(200,0,_RecId,vMID);
    if (Erx>_rLocked) then CYCLE;

    inc(vAnz);
    
    // Gesamtheit eines Paketes prüfen...
    if (Mat.PaketNr=0) then CYCLE;
    
    vPak # Mat.PaketNr;
    RecBufClear(200);
    Mat.PaketNr # vPak;
    FOR Erx # RecRead(200,36,0)
    LOOP Erx # RecRead(200,36,_RecNext)
    WHILE (Erx<=_rMultiKey) and (Mat.PaketNr=vPak) do begin
      // schon markiert, dann weiter!
      if (Lib_Mark:istmarkiert(200, RecInfo(200, _recId))) then CYCLE;
      if (vFirst=false) then begin
        vFirst # true;
        if (Msg(441017,'',_WinIcoWarning,_WinDialogOkCancel,1)<>_Winidok) then RETURN false;
      end;
      Lib_Mark:MarkAdd(200,y,y);
    END;
   
/***
      Pak.Nummer  # Mat.Paketnr;
      // Alle Paketpositionen lesen
      FOR Erx # RecLink(281,280,1,_RecFirst)
      LOOP Erx # RecLink(281,280,1,_RecNext)
      WHILE Erx = _rOK DO BEGIN
        if (Pak.P.MaterialNr=0) then CYCLE;
        Mat.Nummer # Pak.P.MaterialNr;
        Erx # RecRead(200,1,0);
        if (Erx>_rLocked) then CYCLE;
        
        // schon markiert, dann weiter!
        if (Lib_Mark:istmarkiert(200, RecInfo(200, _recId))) then CYCLE;
        if (vFirst=false) then begin
          vFirst # true;
          if (Msg(441017,'',_WinIcoWarning,_WinDialogOkCancel,1)<>_Winidok) then RETURN false;
        end;
        Lib_Mark:MarkAdd(200,y,y);
      END;
    end;
***/
  END;

  // KEINE Markierung?
  if (vAnz=0) then RETURN false;

  // per Markierungen ----------------------


  v701 # RekSave(701);
  gSelected # 0;
  FOR vItem # gMarkList->CteRead(_CteFirst)
  LOOP vItem # gMarkList->CteRead(_CteNext,vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then CYCLE;
    RecRead(200,0,_RecId,vMID);

    // als Einsatz aufnehmen
    if (BA1_IO_Data:EinsatzRein(BAG.P.Nummer, BAG.P.Position, Mat.Nummer)=false) then begin
      RekRestore(v701)
      Msg(999999,'',0,0,0);
      RETURN false;
    end;

  END;

  // Markierungen löschen...
  Lib_Mark:Reset(200);

  Lib_guicom2:Refresh_List(cZList2, _WinLstRecFromRecID | _WinLstRecDoSelect);
  Lib_guicom2:Refresh_List(cZList3, _WinLstFromFirst | _WinLstRecDoSelect);
  Lib_guicom2:Refresh_List(cZList4, _WinLstFromFirst | _WinLstRecDoSelect);
  Lib_guicom2:Refresh_List(gZLlist, _WinLstRecFromRecID | _WinLstRecDoSelect);

  RETURN true;
end;


//========================================================================
//  AlleTheosSkalieren
//========================================================================
SUB AlleTheosSkalieren(
  aBA         : int;
  aPos        : int;
  aMengenFakt : float) : logic;
local begin
  Erx           : int;
  vFirst        : logic;
  vKGMM_Kaputt  : logic;
end;
begin
  BAG.P.Nummer    # aBA;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);
  if (erx>_rLocked) then RETURN false;

  TRANSON;

  // Inputs loopen...
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.Materialtyp<>c_IO_Theo) and (BAG.IO.Materialtyp<>c_IO_Beistell) then CYCLE;
    
    Erx # RecRead(701,1,_RecLock);
    if (Erx=_rOK) then begin
  //        BAG.IO.Breite         # (aAnzVS * aBVS) + (aRestAnzVS * aRestBVS);
      BAG.IO.Plan.In.GewB   # Rnd(BAG.IO.Plan.In.GewB * aMengenFakt, Set.Stellen.Gewicht);
      BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.GewN * aMengenFakt, Set.Stellen.Gewicht);
      BAG.IO.Plan.In.Menge  # Rnd(BAG.IO.Plan.In.Menge * aMengenFakt, Set.Stellen.Menge);
      BAG.IO.Plan.Out.GewB  # Rnd(BAG.IO.Plan.Out.GewB * aMengenFakt, Set.Stellen.Gewicht);
      BAG.IO.Plan.Out.GewN  # Rnd(BAG.IO.Plan.Out.GewN * aMengenFakt, Set.Stellen.Gewicht);
      BAG.IO.Plan.Out.Meng  # Rnd(BAG.IO.Plan.Out.Meng * aMengenFakt, Set.Stellen.Menge);
      if (BAG.IO.Materialtyp=c_IO_Beistell) then begin
        BAG.IO.Plan.In.Stk  # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.In.Stk) * aMengenFakt));
        BAG.IO.Plan.Out.Stk # cnvif(Lib_Berechnungen:RndUp(cnvfi(BAG.IO.Plan.Out.Stk) * aMengenFakt));
      end;
      if (BAG.IO.MEH.In='Stk') then
        BAG.IO.Plan.In.Menge  # cnvfi(BAG.IO.Plan.In.Stk);
      if (BAG.IO.MEH.Out='Stk') then
        BAG.IO.Plan.Out.Meng  # cnvfi(BAG.IO.Plan.Out.Stk);
      Erx # BA1_IO_Data:Replace(0,'AUTO');
    end;
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;
    if (vFirst=false) then begin
      if (BA1_IO_Data:Autoteilung(var vKGMM_Kaputt)=false) then begin
//debugx('aua');
      end;
      vFirst # true;
    end;
    // Output aktualisieren
    if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
      TRANSBRK;
      RETURN false;
    end;

  END;

  TRANSOFF;
    
  RETURN true;
end;


//========================================================================
// FindeKommission
//========================================================================
sub FindeKommission(
  var aAufNr  : int;
  var aAufPos : int;
) : logic
local begin
  Erx   : int;
  v701  : int;
  vOK   : logic;
end;
begin
  if (BAG.IO.Auftragsnr<>0) then begin
    aAufNr  # BAG.IO.Auftragsnr;
    aAufPos # BAG.IO.AuftragsPos;
    RETURN true;
  end;
  
  // Rekursion?
  if (BAG.IO.VonID<>0) then begin
    v701 # RekSave(701);
    BAG.IO.VonBAG # BAG.IO.VonBAG;
    BAG.IO.ID     # BAG.IO.VonID;
    Erx # RecRead(701,1,0);
    if (erx<=_rLockeD) then begin
      vOK # FindeKommission(var aAufNr, var aAufPos);
    end;
    RekRestore(v701);
  end;
  
  RETURN vOK;
end;


//========================================================================
//  HatEinsatzReservierungen
//========================================================================
sub HatEinsatzReservierungen() : logic;
local begin
  Erx : int;
end;
begin

  // Inputs loopen
  FOR Erx # RecLink(701,702,2,_recFirst)
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.MaterialRstNr<>0) then begin
      Mat.Nummer # BAG.IO.MaterialRstNr;
      Erx # RecLinkInfo(203,200,13,_recCount);  // Reservierungen zählen
      if (Erx>0) then RETURN true;
    end;
  END;

  RETURN false;
end;


//========================================================================
//========================================================================