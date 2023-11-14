@A+
//===== Business-Control =================================================
//
//  Prozedur  Vsd_Data
//                OHNE E_R_G
//
//  Info
//
//
//  13.07.2009  AI  Erstellung der Prozedur
//  09.04.2010  AI  für EK-VSB erweitert
//  28.04.2010  AI  Materialstatus bei LFS-Positionsanlage egal
//  11.12.2012  AI  NEU: VsPTo2VsdP, PoolMarkToVersandPos
//  28.09.2021  AH  ERX
//  29.09.2021  MR  AFX "Vsd.Verbuchen.Post" (2166/55/1)
//  04.11.2021  AH  "FMalleLFS"
//  20.12.2021  AH  "PruefeObAllesErledigt"
//  27.04.2022  AH  Paketversand
//  2022-11-10  AH  Versandgesamtpreis wird an BAs übergeben (TODO: AUFTEILEN)
//  2022-12-13  AH  Bugfix: LFA hatte als ABHOLORT schon das Ziel
//  2022-12-19  AH  neue BA-MEH-Logik
//  2023-01-10  AH  Versand-Kennzeichen&Bemerkung wird an LFS übertragen
//
//  Subprozeduren
//    SUB _Erzeuge700() : logic;
//    SUB _Erzeuge702() : logic;
//    SUB _Erzeuge701(aCount : int) : logic;
//    SUB _Erzeuge441(aMat : int; aPos : int) : logic;
//    SUB _VerbuchenBAG() : logic;
//    SUB FMaufVersandLFA() : logic;
//    SUB _VerbuchenLFS() : logic;
//    SUB Verbuchen() : logic;
//    SUB VsPTOVsdP() : logic;
//    SUB PoolMarkToVersandPos() : logic;
//    SUB _655To651Delegate() : int;
//    SUB FMalleLFS(aNr : int; aDatum : date; opt aPlatz : alpha; opt aAbschluss  : logic) : logic;
//    SUB PruefeObAllesErledigt
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//@define Debugmode
//@undef Debugmode

@ifdef Debugmode
  define begin
    ABBRUCH   : debugx('AUA!'); RETURN false;
  end;
@else
  define begin
    ABBRUCH   : RETURN false;
  end;
@Endif


//========================================================================
//  _Erzeuge700
//
//========================================================================
sub _Erzeuge700() : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  RecBufClear(700);

  BAG.Nummer # Lib_Nummern:ReadNummer('Betriebsauftrag');
  if (BAG.Nummer<>0) then Lib_Nummern:SaveNummer()
  else RETURN false;

  BAG.BuchungsAlgoNr  # Set.BA.BuchungAlgoNr;
  BAG.Bemerkung     # Translate('Versand')+' '+aInt(Vsd.Nummer);
  BAG.Anlage.Datum  # Today;
  BAG.Anlage.Zeit   # Now;
  BAG.Anlage.User   # gUserName;
  RekInsert(700,0,'AUTO');
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


//========================================================================
//  _Erzeuge702
//
//========================================================================
sub _Erzeuge702() : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  ArG.Aktion2           # c_BAG_Fahr09;
  erx # RecRead(828,1,0);
  if (erx>_rLocked) then RecBufClear(828);

  RecBufClear(702);         // BA-Position anlegen
  BAG.P.Nummer            # BAG.Nummer;
  BAG.P.Position          # 1;
  BAG.P.Aktion            # ArG.Aktion;
  BAG.P.Aktion2           # ArG.Aktion2;
  "BAG.P.Typ.1In-1OutYN"  # "ArG.Typ.1In-1OutYN";
  "BAG.P.Typ.1In-yOutYN"  # "ArG.Typ.1In-yOutYN";
  "BAG.P.Typ.xIn-yOutYN"  # "ArG.Typ.xIn-yOutYN";
  "BAG.P.Typ.VSBYN"       # "ArG.Typ.VSBYN";
  BAG.P.Bezeichnung       # ArG.Bezeichnung
  if (VsP.Spediteurnr<>set.eigeneAdressnr) then begin
    erx # RecLink(100,650,1,_recFirst);   // Spediteur holen
    if (erx>_rLocked) then RecbuFClear(100);
    if (Adr.Lieferantennr<>0) then begin
      BAG.P.ExterneLiefNr   # Adr.Lieferantennr;
      BAG.P.ExternYN        # y;
    end;
  end;

  BAG.P.Ressource.Grp     # Vsd.Ressource.Grp;
  BAG.P.Ressource         # Vsd.Ressource;
  BAG.P.Plan.EndDat       # Vsd.Datum;
  BAG.P.Plan.EndZeit      # Vsd.Zeit;

  BAG.P.Auftragsnr        # VsP.Auftragsnr;
  BAG.P.AuftragsPos       # VsP.Auftragspos;
  if (BAG.P.Auftragsnr<>0) then
    BAG.P.Kommission      # AInt(BAG.P.Auftragsnr)+'/'+aInt(BAG.P.AuftragsPos);
  BAG.P.Zieladresse       # VsP.Ziel.Adresse;
  BAG.P.Zielanschrift     # Vsp.Ziel.anschrift;
  erx # RecLink(101,702,13,_RecFirst);  // Zielanschrift holen
  if (erx>_rLocked) then RecBufClear(101);
  BAG.P.Zielstichwort     # Adr.A.Stichwort;
  BAG.P.ZielVerkaufYN     # y;
  BAG.P.Kosten.Wae        # 1;
  BAG.P.Kosten.PEH        # 1000;
  BAG.P.Kosten.MEH        # 'kg';
  BAG.P.Kosten.Fix        # Vsd.GesamtKostenW1;   // 2022-11-10 AH
  BA1_Data:SetStatus(c_BagStatus_Offen);

  BAG.P.Position # 1;
  WHILE (RecRead(702,1,_RecTest)<=_rLocked) do
    BAG.P.Position # BAG.P.Position + 1;
  Erx # BA1_P_Data:Insert(0,'MAN');
  if (Erx<>_rOk) then RETURN False;


  RecBufClear(701);
/****
  // 1 zu 1 Arbeitsgang?
  if ("BAG.P.Typ.1In-1OutYN") then begin // autom. 1. Fertigung anlegen
    RecBufClear(703);
    BAG.F.Nummer            # BAG.P.Nummer;
    BAG.F.Position          # BAG.P.Position;
    BAG.F.Fertigung         # 1;
    BAG.F.AutomatischYN     # y;
    "BAG.F.KostenträgerYN"  # y;
    BAG.F.MEH               # 'kg';

    BAG.F.Dicke             # BAG.IO.Dicke;
    BAG.F.Dickentol         # BAG.IO.Dickentol;
    BAG.F.Breite            # BAG.IO.Breite;
    BAG.F.Breitentol        # BAG.IO.Breitentol;
    "BAG.F.Länge"           # "BAG.IO.Länge";
    "BAG.F.Längentol"       # "BAG.IO.Längentol";
    "BAG.F.Gütenstufe"      # "BAG.IO.Gütenstufe";
    "BAG.F.Güte"            # "BAG.IO.Güte";
    RekInsert(703,0,'AUTO');
    if (Erx<>_rOk) then RETURN False;
  end;
***/

  RETURN true;
end;


//========================================================================
//  _Erzeuge701
//
//========================================================================
sub _Erzeuge701(
  aCount      : int;
  aAusPakPos  : logic) : logic;
local begin
  Erx       : int;
  vBuf401   : int;
end;
begin DoLogProc;

  // Einsatzmaterial anlegen **************************
  RecBufClear(701);
  BAG.IO.Nummer         # BAG.P.Nummer;
  BAG.IO.NachBAG        # BAG.P.Nummer;
  BAG.IO.NachPosition   # BAG.P.Position;
  BAG.IO.NachFertigung  # aCount;

  BAG.IO.ID # 0;
  REPEAT
    BAG.IO.ID # BAG.IO.ID + 1;
    Erx # RecRead(701,1,_recTest);
  UNTIL (Erx<>_rOK);

  // VSD-Position anpassen
  Vsd.P.BAG           # BAG.Nummer;
  Vsd.P.BAG.Position  # BAG.P.Position;
  Vsd.P.BAG.Fertigung # BAG.IO.nachFertigung;
  Vsd.P.BAG.IO.ID     # BAG.IO.ID;


    // 27.04.2022 AH: Paketversand
    if (aAusPakPos) then begin
      VsP.Materialnr  # Pak.P.Materialnr;
    end;
    

  // ECHTES MATERIAL ??? -----------------------------------------------
//  If (Lfs.P.Materialtyp=c_IO_MAT) then begin // Material?
  if (VsP.Materialnr<>0) then begin
    Mat.Nummer # VsP.Materialnr;
    Erx # RecRead(200,1,0);
    if (Erx>_rLocked) then begin
      Error(010001,AInt(BAG.P.Position)+'|'+AInt(VsP.Materialnr));
      RETURN false;
    end;
   
    // 27.04.2022 AH: Paketversand
    if (aAusPakPos) then begin
      "Vsd.P.Stück"   # Mat.Bestand.Stk;
      Vsd.P.Gewicht   # Mat.Bestand.Gew;
      Vsd.P.Menge.In  # Mat.Bestand.Gew;
    end;

    // Verwieungsart beachten
    BAG.IO.Versandpoolnr  # VsD.P.Poolnr;
    BAG.IO.Materialnr     # Mat.Nummer;
    BAG.IO.Dicke          # Mat.Dicke;
    BAG.IO.Breite         # Mat.Breite;
    "BAG.IO.Länge"        # "Mat.Länge";
    BAG.IO.Dickentol      # Mat.Dickentol;
    BAG.IO.Breitentol     # Mat.Breitentol;
    "BAG.IO.Längentol"    # "Mat.Längentol";
    BAG.IO.AusfOben       # "Mat.AusführungOben";
    BAG.IO.AusfUnten      # "Mat.AusführungUnten";
    "BAG.IO.Güte"         # "Mat.Güte";

    BAG.IO.Warengruppe    # Mat.Warengruppe;
// 2022-12-13 AH    BAG.IO.Lageradresse   # VsP.Ziel.Adresse;
//    BAG.IO.Lageranschr    # VsP.Ziel.Anschrift;
    BAG.IO.Lageradresse   # Mat.Lageradresse;
    BAG.IO.Lageranschr    # Mat.Lageranschrift;
    if (VsP.Vorgangstyp=c_VSPTyp_Ein) then
      BAG.IO.Materialtyp    # c_IO_VSB
    else
      BAG.IO.Materialtyp    # c_IO_Mat;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;
    BAG.IO.Auftragsnr     # Vsp.Auftragsnr;
    BAG.IO.AuftragsPos    # Vsp.Auftragspos
    BAG.IO.AuftragsFert   # 0;


    BAG.IO.MEH.In         # Vsd.P.MEH.In;
    BAG.IO.MEH.Out        # Vsd.P.MEH.Out;

    BAG.IO.Plan.Out.Stk   # "Vsd.P.Stück";
    BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
/*** 30.09.2021
    BAG.IO.Plan.Out.GewN  # Vsd.P.Gewicht;
    BAG.IO.Plan.Out.GewB  # Vsd.P.Gewicht;
    BAG.IO.Plan.Out.Meng  # Vsd.P.Menge.Out;

    BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
    BAG.IO.Plan.In.Menge  # Vsd.P.Menge.In;
    if (BAG.IO.MEH.In='kg') then
      BAG.IO.Plan.In.Menge  # Mat.Bestand.Gew;
***/
    if (BAG.IO.Plan.In.Stk<>BAG.IO.Plan.Out.Stk) then begin // 30.09.2021 AH: Splittung??
      BAG.IO.Plan.Out.GewN  # Vsd.P.Gewicht;
      BAG.IO.Plan.Out.GewB  # Vsd.P.Gewicht;
      BAG.IO.Plan.Out.Meng  # Vsd.P.Menge.Out;
      BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
      BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
      BAG.IO.Plan.In.Menge  # Vsd.P.Menge.In;
      if (BAG.IO.MEH.In='kg') then
        BAG.IO.Plan.In.Menge  # Mat.Bestand.Gew;
    end
    else begin
      BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
      BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
      if (BAG.IO.Plan.In.GewN=0.0) then BAG.IO.Plan.In.GewN # Mat.Bestand.Gew;
      if (BAG.IO.Plan.In.GewB=0.0) then BAG.IO.Plan.In.GewB # Mat.Bestand.Gew;
      if (Mat.MEH=BAG.IO.MEH.Out) then begin   // 2022-12-08 AH
        BAG.IO.Plan.In.Menge # Mat.Bestand.Menge;
      end
      else if (BAG.IO.MEH.Out='qm') then begin
        "BAG.IO.Länge"  # Lib_berechnungen:L_aus_KgStkDBDichte2(BAG.IO.Plan.In.GewN, BAG.IO.Plan.In.Stk, BAG.IO.Dicke, BAG.IO.Breite, Mat.Dichte, "Wgr.TränenKgProQM");
        BAG.IO.Plan.In.Menge  # Rnd( cnvfi(BAG.IO.Plan.In.Stk) * BAG.IO.Breite * "BAG.IO.Länge" / 1000000.0 ,Set.Stellen.Menge);
        "BAG.IO.Länge"        # "Mat.Länge";
      end
      else if (BAG.IO.MEH.Out='m') then begin
        BAG.IO.Plan.In.Menge # Lib_Einheiten:WandleMEH(200, BAG.IO.Plan.In.Stk, BAG.IO.Plan.In.GewN, 0.0, '', BAG.IO.MEH.Out);
      end
      else begin
        BAG.IO.Plan.In.Menge  # BAG.IO.Plan.In.GewN;
      end;

      BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
      BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
      BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
      BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

      BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
      BAG.IO.Plan.Out.GewN  # BAG.IO.PLan.In.GewN;
      BAG.IO.Plan.Out.GewB  # BAG.IO.PLan.In.GewB;
    end;

    if (aAusPakPos) then begin  // 2022-12-21 AH
      BAG.IO.Auftragsnr     # Mat.Auftragsnr;
      BAG.IO.AuftragsPos    # Mat.Auftragspos;
      BAG.IO.MEH.In         # Mat.MEH;
      BAG.IO.MEH.Out        # Mat.MEH;
      BAG.IO.Plan.In.Stk    # Mat.Bestand.Stk;
      BAG.IO.Plan.Out.Stk   # Mat.Bestand.Stk;
      BAG.IO.Plan.In.GewN   # Mat.Gewicht.Netto;
      BAG.IO.Plan.Out.GewN  # Mat.Gewicht.Netto;
      BAG.IO.Plan.In.GewB   # Mat.Gewicht.Brutto;
      BAG.IO.Plan.Out.GewB  # Mat.Gewicht.Brutto;
      BAG.IO.Plan.In.Menge  # Mat.Bestand.Menge;
      BAG.IO.Plan.Out.Meng  # Mat.Bestand.Menge;
    end;

    // Material auf diesen neuen Einsatz hin anpassen
    if (BA1_Mat_Data:MatEinsetzen()=false) then begin
      Error(010007,AInt(BAG.p.position)+'|'+AInt(VsP.Materialnr));
      RETURN false;
    end;

  end;  // Material


  // THEORETISCHES MATERIAL ???-----------------------------------------
  if (VsP.Materialnr=0) and (VsP.Vorgangstyp=c_VSPTyp_Auf) then begin
    RecBufCleaR(404);
    Erx # RecLink(401,655,10,_recFirst);  //Auftrags-Position holen
    if (Erx>_rLocked) then RecbufClear(401);
    // Verwieungsart beachten
    BAG.IO.Materialnr     # 0;
    BAG.IO.Dicke          # Auf.P.Dicke;
    BAG.IO.Breite         # Auf.P.Breite;
    "BAG.IO.Länge"        # "Auf.P.Länge";
    BAG.IO.Dickentol      # Auf.P.Dickentol;
    BAG.IO.Breitentol     # Auf.P.Breitentol;
    "BAG.IO.Längentol"    # "Auf.P.Längentol";
    BAG.IO.AusfOben       # Auf.P.AusfOben;
    BAG.IO.AusfUnten      # Auf.P.AusfUnten;
    "BAG.IO.Güte"         # "Auf.P.Güte";

    BAG.IO.MEH.In         # Vsd.P.MEH.In;
    BAG.IO.MEH.Out        # Vsd.P.MEH.Out;

    BAG.IO.Plan.Out.Stk   # "Vsd.P.Stück";
    BAG.IO.Plan.Out.GewN  # Vsd.P.Gewicht;
    BAG.IO.Plan.Out.GewB  # Vsd.P.Gewicht;
    BAG.IO.Plan.Out.Meng  # Vsd.P.Menge.Out;

    BAG.IO.Plan.In.Stk    # BAG.IO.PLan.Out.Stk;
    BAG.IO.Plan.In.GewN   # BAG.IO.Plan.Out.GewN;
    BAG.IO.Plan.In.GewB   # BAG.IO.Plan.Out.GewB;
    BAG.IO.Plan.In.Menge  # Vsd.P.Menge.In;
    if (BAG.IO.MEH.In='kg') then
      BAG.IO.Plan.In.Menge  # BAG.IO.Plan.Out.GewN;

    BAG.IO.Warengruppe    # Auf.P.Warengruppe;
// 2022-12-13 AH    BAG.IO.Lageradresse   # VsP.Ziel.Adresse;
//    BAG.IO.Lageranschr    # VsP.Ziel.Anschrift;
    BAG.IO.Lageradresse   # Mat.Lageradresse;
    BAG.IO.Lageranschr    # Mat.Lageranschrift;

    BAG.IO.Materialtyp    # c_IO_Theo;
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;

    BAG.IO.Auftragsnr     # Vsp.Auftragsnr;
    BAG.IO.AuftragsPos    # Vsp.Auftragspos
    BAG.IO.AuftragsFert   # 0;

  end;  // Theorie


  // VSB-MATERIAL ??? --------------------------------------------------
//  If (Lfs.P.Materialtyp=c_IO_VSB) then begin // VSB-Material?
  if (1=2) then begin
    Mat.Nummer # Lfs.P.Materialnr;
    Erx # RecRead(200,1,0);
    if (Erx>_rLocked) then begin
      Error(010001,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;

    // Verwieungsart beachten
    BAG.IO.Materialnr     # Mat.Nummer;
    BAG.IO.Dicke          # Mat.Dicke;
    BAG.IO.Breite         # Mat.Breite;
    "BAG.IO.Länge"        # "Mat.Länge";
    BAG.IO.Dickentol      # Mat.Dickentol;
    BAG.IO.Breitentol     # Mat.Breitentol;
    "BAG.IO.Längentol"    # "Mat.Längentol";
    BAG.IO.AusfOben       # "Mat.AusführungOben";
    BAG.IO.AusfUnten      # "Mat.AusführungUnten";
    "BAG.IO.Güte"         # "Mat.Güte";
    BAG.IO.Plan.In.Stk    # "Lfs.P.Stück";
    BAG.IO.Plan.In.GewN   # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Lfs.P.Gewicht.Brutto;
    BAG.IO.MEH.In         # Lfs.P.MEH;
    BAG.IO.MEH.Out        # Lfs.P.MEH;
    BAG.IO.Plan.In.Menge  # Lfs.P.Menge;
    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
    BAG.IO.Warengruppe    # Mat.Warengruppe;
    BAG.IO.Lageradresse   # Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Lfs.P.Art.Anschrift;
    BAG.IO.Materialtyp    # Lfs.P.Materialtyp
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;

    // Material auf diesen neuen Einsatz hin anpassen
    if (BA1_Mat_Data:VSBEinsetzen()=false) then begin
      Error(010007,AInt(lfs.p.position)+'|'+AInt(Lfs.P.Materialnr));
      RETURN false;
    end;

  end;  // VSB-Material



  // ARTIKEL ??? --------------------------------------------------------
//  if (Lfs.P.Materialtyp=c_IO_ART) then begin // Artikel?
  if (1=2) then begin
    Erx # RecLink(250,441,3,_recFirst); // Artikel holen
    if (Erx>_rLocked) then begin
      Error(010001,AInt(lfs.p.position)+'|'+Lfs.P.Artikelnr);
      RETURN false;
    end;

    BAG.IO.Artikelnr      # Lfs.P.Artikelnr;
    BAG.IO.Lageradresse   # Lfs.P.Art.Adresse;
    BAG.IO.Lageranschr    # Lfs.P.Art.Anschrift;
    BAG.IO.Charge         # LFs.P.Art.Charge;

    BAG.IO.Plan.In.Stk    # "Lfs.P.Stück";
    BAG.IO.Plan.In.GewN   # Lfs.P.Gewicht.Netto;
    BAG.IO.Plan.In.GewB   # Lfs.P.Gewicht.Brutto;

    BAG.IO.MEH.In         # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.In.Menge  # Lfs.P.Menge.Einsatz;

// LFA-Update
//      BAG.IO.MEH.Out        # Lfs.P.MEH;
//      BAG.IO.Plan.Out.Meng  # Lfs.P.Menge;
    BAG.IO.MEH.Out        # Lfs.P.MEH.Einsatz;
    BAG.IO.Plan.Out.Meng  # Lfs.P.Menge.Einsatz;

    BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
    BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
    BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;
    BAG.IO.Warengruppe    # Art.Warengruppe;
    BAG.IO.Materialtyp    # Lfs.P.Materialtyp
    BAG.IO.VonBAG         # 0;
    BAG.IO.VonPosition    # 0;
    BAG.IO.VonFertigung   # 0;
    BAG.IO.VonID          # 0;
  end;  // Artikel



  // ID vergeben
  BAG.IO.ID # 0;//Lfs.P.Position;
  REPEAT
    BAG.IO.ID # BAG.IO.ID +1; //Lfs.P.Position;
    BAG.IO.UrsprungsID    # BAG.IO.ID;
    BAG.IO.Anlage.Datum   # Today;
    BAG.IO.Anlage.Zeit    # Now;
    BAG.IO.Anlage.User    # gUserName;
    Erx # BA1_IO_Data:Insert(0,'MAN');
  UNTIL (Erx=_rOK);


/*** 15.02.2012 AI : wird bereits im BA1_IO_DATA geregelt
  // Fertigung anlegen **************************
  RecBufClear(703);
  BAG.F.Nummer            # BAG.Nummer;
  BAG.F.Position          # BAG.P.Position;
  BAG.F.Fertigung         # BAG.IO.nachFertigung;
  "BAG.F.KostenträgerYN"  # y;
  BAG.F.ReservierenYN     # y;

  BAG.F.Auftragsnummer    # BAG.IO.Auftragsnr;
  BAG.F.Auftragspos       # BAG.IO.AuftragsPos;
  BAG.F.AuftragsFertig    # BAG.IO.AuftragsFert;

  if (Auf.A.Nummer<>0) and (BAG.F.Auftragsnummer=0) then begin
    BAG.F.Auftragsnummer    # Auf.A.Nummer;
    BAG.F.Auftragspos       # Auf.A.Position;
    BAG.F.AuftragsFertig    # Auf.A.Position2;
  end;
  if (BAG.F.Auftragsnummer<>0) then begin
    BAG.F.Kommission        # AInt(BAG.F.Auftragsnummer)+'/'+AInt(BAG.F.AuftragsPos);
    vBuf401 # RecBufCreate(401);
    Erx # RecLink(vBuf401,703,9,_RecFirsT);     // AufPos holen
    if (Erx<=_rLocked) then begin
      Erx # RecLink(100,vBuf401,4,_RecFirst);   // Adresse holen
      if (Erx>_rLocked) then RecBufClear(100);
      "BAG.F.ReservFürKunde"  # Adr.Kundennr;
    end;
    RecBufDestroy(vBuf401);
  end;

  "BAG.F.Stückzahl"       # BAG.IO.Plan.Out.Stk;
  BAG.F.Gewicht           # BAG.IO.Plan.Out.GewN;
  BAG.F.Menge             # BAG.IO.Plan.Out.Meng;
  BAG.F.MEH               # BAG.IO.MEH.Out;
  BAG.F.Artikelnummer     # BAG.IO.Artikelnr;
  BAG.F.Warengruppe       # BAG.IO.Warengruppe;

  BAG.F.ZuVersand         # Vsd.P.Nummer;
  BAG.F.ZuVersand.Pos     # Vsd.P.Position;

  BAG.F.Anlage.Datum   # Today;
  BAG.F.Anlage.Zeit    # Now;
  BAG.F.Anlage.User    # gUserName;
  RekInsert(703,0,'MAN');
  if (Erx<>_rOk) then begin
    Error(010033,AInt(BAG.F.Nummer));
    RETURN false;
  end;
***/
  // Versandnumemr in LFA-Fertigung eintregen!
  if (BAG.IO.NachBAG<>0) then begin
    Erx # RecLink(703,701,10,_RecLock);
    BAG.F.ZuVersand         # Vsd.P.Nummer;
    BAG.F.ZuVersand.Pos     # Vsd.P.Position;
    RekReplace(703,_recunlock,'AUTO');
  end;

  // Output aktualisieren ****************
  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    Error(010034,AInt(BAG.F.Nummer));
    RETURN false;
  end;

  RETURN true;
end;


//========================================================================
//  _Erzeuge441   +ERR
//
//========================================================================
sub _Erzeuge441(
  aMat      : int;
  var aPos  : int) : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  Mat.Nummer # aMat;        // Material holen...
  Erx # RecRead(200,1,0);
  if (Erx>_rLocked) then begin
    Error(001003,Translate('Material')+' '+AInt(aMat));
    RETURN false;
  end;

  if (Mat.AuftragsNr=0) then begin
    Error(441007,AInt(aMat));
    RETURN false;
  end;

  if ("Mat.Löschmarker"='*') then begin
    Error(200006,'');
    RETURN false;
  end;
/** 28.04.2010 AI
  if (Mat.Status>c_Status_bisFrei) and
    (Mat.Status<>c_STATUS
    (Mat.Status<>c_STATUS_VSB) and (Mat.Status<>c_STATUS_VSBKonsi) then begin
    Error(441002,'');
    RETURN false;
  end;
**/
  Erx # RecLink(401,200,16,_RecFirst);      // Auftragspos holen
  if (Erx>_rLocked) then begin
    Error(401999,Translate('Auftrag')+' '+AInt(Mat.Auftragsnr)+'/'+Aint(Mat.auftragspos));
    RETURN false;
  end;
  Erx # RecLink(400,401,3,_RecFirst);       // Kopf holen
  if (Erx>_rLocked) then RETURN false;


  if (Lfs.Kundennummer=0) then begin
    Lfs.Kundennummer    # Auf.P.Kundennr;
    Lfs.Kundenstichwort # Auf.P.KundenSW;
    Lfs.Zieladresse     # Auf.Lieferadresse;
    Lfs.Zielanschrift   # Auf.Lieferanschrift;
  end;

  if((Lfs.Kundennummer<>Auf.P.Kundennr) or
    (Lfs.Zieladresse<>Auf.Lieferadresse) or
    (Lfs.Zielanschrift<>Auf.Lieferanschrift)) then begin
    Error(441006,'');
    RETURN false;
  end;

  // Position in temp. Lieferschein aufnehmen...
  RETURN Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer, var aPos, 0);

end;


//========================================================================
//  _VerbuchenBAG
//
//========================================================================
sub _VerbuchenBAG() : logic;
local begin
  Erx       : int;
  vPosTree  : int;
  vSort     : alpha;
  vSort2    : alpha;
  vItem     : int;
  vCount    : int;
  vBuf655   : int;
  vBuf404   : int;
  vAnz      : int;
end;
begin DoLogProc;

  // Positionen nach ZIELORT + KUNDE im Baum sortieren...
  vPosTree # CteOpen(_CteTreeCI);
  If (vPosTree=0) then RETURN false;

  TRANSON;

  Erx # RecLink(651,650,3,_recFirst);     // Positionen loopen
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      Sort_KillList(vPosTree);
      ABBRUCH;
    end;

    vSort # '';
    case (VsP.Vorgangstyp) of

      // Auftragsversand/VSB **********************************************
      c_VSPTyp_Auf : begin

//        Erx # RecLink(404,655,7,_recFirst);   // Auftragskation holen
//        if (Erx<=_rLocked) then begin
//          Erx # RecLink(401,404,1,_recFirst); //Position holen
        if (1=1) then begin
          Erx # RecLink(401,655,10,_recFirst);  //Auftrags-Position holen
          if (Erx>_rLocked) then begin
            TRANSBRK;
            Sort_KillList(vPosTree);
            ABBRUCH;
          end;
          vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(Auf.P.Kundennr);
          end
        else begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
      end;  // VSPTyp_Auf


      // BA-Versand *******************************************************
      c_VSPTyp_BAG : begin
        Erx # RecLink(701,655,8,_recFirst);   // BA-Input holen
        if (Erx>_rLocked) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
        Erx # RecLink(702,701,4,_recFirst);   // nachPos holen
        if (Erx>_rLocked) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
if (Set.Installname='HWE') then BAG.P.ZielVerkaufYN # y;
        // reines Umlagern? -> KEIN Zielkunde
        //if (BAG.P.ZielVerkaufYN=n) then begin
        if (BAG.IO.Auftragsnr=0) or (BAG.P.ZielVerkaufYN=n) then begin
          vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(0);
        end
        else begin
          Erx # RecLink(401,701,16,_recFirst);      // Auftragspos holen
          if (Erx<=_rLocked) then
            vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(Auf.P.Kundennr);
        end;

      end;  // VSPTyp_BAG


      // Einkaufsversand/VSB **********************************************
      c_VSPTyp_Ein : begin
        Erx # RecLink(501,655,11,_recFirst);  //Einkaufs-Position holen
        if (Erx>_rLocked) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
       vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(Ein.P.KommiKunde);
      end;  // VSPTyp_Ein


      // Paketversand/Lagerumbuchung ***********************************
      c_VSPTyp_Pak : begin
       vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(0);
      end;  // VSPTyp_Pak


      // Materialversand/Lagerumbuchung ***********************************
      c_VSPTyp_Mat : begin
        Erx # RecLink(200,655,2,_recFirst);  //Material holen
        if (Erx>_rLocked) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
       vSort # AInt(Vsp.Ziel.Adresse)+'|'+AInt(VsP.Ziel.Anschrift)+'|'+AInt(0);
      end;  // VSPTyp_Mat

      // sonstiges ********************************************************
      otherwise begin
TRANSBRK;
TODO('Versand für '+VsP.Vorgangstyp);
Sort_KillList(vPosTree);
RETURN false
      end;  // otherwise

    end;  // case VsP.Vorgangstyp

    if (vSort<>'') then
      Sort_ItemAdd(vPosTree, vSort, 651, RecInfo(651,_RecId));

    Erx # RecLink(651,650,3,_recNext);
  END;  // Positionen loopen


  // einen neuen BA anlegen----------------------
  if (_Erzeuge700()=false) then begin
    TRANSBRK;
    Sort_KillList(vPosTree);
    ABBRUCH;
  end;


  vSort # '';
  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vPosTree)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(651,0,0,vItem->spID);         // Custom=Dateinr, ID=SatzID

    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      Sort_KillList(vPosTree);
      ABBRUCH;
    end;
    Erx # RecLink(404,655,7,_recFirsT);   // Auftragskation holen
    if (Erx>_rLocked) then RecBufClear(404);

    vSort2 # StrCut(vItem->spName,1,StrLen(vItem->spname)-8);

    // Zielwechsel?
    if (vSort<>vSort2) then begin

      if (vSort<>'') then begin
        // automatischer VSB eintragen----------
        vBuf404 # RekSave(404);
        vBuf655 # RekSave(655);
        if (BA1_P_Data:AutoVSB()=false) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          RecBufDestroy(vBuf404);
          RecBufDestroy(vBuf655);
          Error(010034,AInt(BAG.P.Nummer));
          ABBRUCH;
        end;
        RekRestore(vBuf404);
        RekRestore(vBuf655);
      end;

      // eine neue Position anlegen---------------
      if (_Erzeuge702()=false) then begin
        TRANSBRK;
        Sort_KillList(vPosTree);
        ABBRUCH;
      end;
      vAnz # vAnz + 1;    // 2022-11-10 AH
      vCount # 0;
    end;

    vSort # vSort2;

    // einen Einsatz aufnehmen--------------------
    vCount # vCount + 1;
    
    // 27.04.2022 AH: Paketversand
    if (VsP.Paketnr<>0) then begin
      Pak.Nummer # VsP.Paketnr;
      Erx # RecRead(280,1,0);
      if (erx>_rLocked) then begin
        TRANSBRK;
        Sort_KillList(vPosTree);
        ABBRUCH;
      end;
      
      vBuf655 # RekSave(655);
      // Positionen loopen...
      FOR Erx # RecLink(281,280,1,_recFirst)
      LOOP Erx # RecLink(281,280,1,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (_Erzeuge701(vCount, true)=false) then begin
          TRANSBRK;
          Sort_KillList(vPosTree);
          ABBRUCH;
        end;
        RecBufCopy(vBuf655, 655);
      END;
      RekRestore(vBuf655);
    end
    else begin
      if (_Erzeuge701(vCount, false)=false) then begin
        TRANSBRK;
        Sort_KillList(vPosTree);
       ABBRUCH;
      end;
    end;
//debugx(' SEHR ungenau!!');
    // VSD-Position rückspeichern
    RecRead(651,1, _recNoLoad | _RecLock);
    Erx # RekReplace(651,0,'AUTO');
    
    // ggf. Pool löschen...
    if (VSp.Paketnr<>0) then
      Erx # VsP_Data:Pool2Ablage('AUTO');
    else if  (VsP.Materialnr=0) and (VSp.Paketnr=0) and
        (VsP.Menge.In.Ist+VsP.Menge.In.Rest<=0.0) and
        (VsP.Menge.Out.Ist+VsP.Menge.Out.Rest<=0.0) and
        ("VsP.Stück.Ist"+"VsP.Stück.Rest"<=0) and
        (VsP.Gewicht.Ist+VsP.Gewicht.Rest<=0.0) then
      Erx # VsP_Data:Pool2Ablage('AUTO');

    else if  (VsP.Vorgangstyp=c_VSPTyp_Ein) and
        (VsP.Menge.In.Ist+VsP.Menge.In.Rest<=0.0) and
        (VsP.Menge.Out.Ist+VsP.Menge.Out.Rest<=0.0) and
        ("VsP.Stück.Ist"+"VsP.Stück.Rest"<=0) and
        (VsP.Gewicht.Ist+VsP.Gewicht.Rest<=0.0) then
      Erx # VsP_Data:Pool2Ablage('AUTO');


    vPosTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vPosTree)
  END;  // Baum loopen


  if (vSort<>'') then begin
    // automatischer VSB eintragen----------
    if (BA1_P_Data:AutoVSB()=false) then begin
      TRANSBRK;
      Sort_KillList(vPosTree);
      Error(010034,AInt(BAG.P.Nummer));
      ABBRUCH;
    end;
  end;

  // komplette Levelsortierung setzen...
  BA1_P_Data:UpdateSort();

  Sort_KillList(vPosTree);

  // Versand rückspeichern
  RecRead(650,1, _RecLock);
  Vsd.Datum.Verbucht  # today;
  "Vsd.Löschmarker"   # '*';
  Erx # RekReplace(650,0,'AUTO');

  // 2023-01-10 AH...
  Erx # RecRead(440,1,_recLock);
  Lfs.Kennzeichen   # Vsd.Kennzeichen;
  Lfs.Bemerkung     # StrCut(Vsd.Bemerkung,1,64);
  Erx # RekReplace(440);

  TRANSOFF;

  // 2022-11-10 AH    Proj. 2228/179
  if (vAnz>1) and (Vsd.GesamtKostenW1<>0.0) then begin
    Msg(650003,'',0,0,0);
  end;

  RETURN true;
end;


//========================================================================
//  FMaufVersandLFA   +ERR
//
//========================================================================
sub FMaufVersandLFA() : logic;
local begin
  Erx           : int;
  vStatus       : int;
  vNextAktion   : alpha;
  vBuf701       : int;
  vBuf702       : int;
  vBuf703       : int;
  vBuf707       : int;
  vNachID       : int;
  vDatei        : int;
end;
begin DoLogProc;

  if (BAG.F.zuVersand=0) or (BAG.P.Aktion<>c_BAG_Fahr09) then RETURN true;
  Erx # RecLink(651,703,12,_recFirsT);    // Versandpos holen
  if (Erx>_rLocked) then begin
    ABBRUCH;
  end;
  Erx # RecLink(655,651,2,_recFirst);     // Versandpool holen
  if (Erx>_rLocked) then begin
    Erx # RecLink(656,651,3,_recFirst);   // ~Versandpool holen
    if (Erx>_rLocked) then begin
      ABBRUCH;
    end;
    RecBufCopy(656,655);
  end;

  // ist für einen Versand-BA??
  If (VsP.Vorgangstyp<>c_VSPTyp_BAG) then begin
    RETURN true;
  end;

  vBuf701 # RekSave(701);
  Erx # RecLink(701,655,8,_recFirst);       // BA-Input holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf701);
    ABBRUCH;
  end;
  vBuf703 # RekSave(703);


  if (BAG.IO.NachFertigung<>0) then begin
    Erx # RecLink(703,701,10,_recFirst);      // nachFertigung holen
  end
  else begin  // 28.09.2021 AH
    vBuf702 # RekSave(702);
    Erx # RecLink(702,701,4,_recFirst);       // Nach_Pos holen 28.09.2021
    Erx # RecLink(703,702,4,_recFirst);       // 1. Fertigung holen
    RekRestore(vBuf702);
  end;
  if (Erx>_rLocked) then begin
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;


  // echten INPUT ändern---------------------------------------------
  Erx # RecRead(701,1,0);   // echten Input holen
  if (Erx>_rLocked) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;
  vNachID # BAG.IO.NachID;

  Erx # RecRead(701,1,_recLock);
  BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + "BAG.FM.Stück";
  BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + BAG.FM.Gewicht.Brutt;
  if (BAG.FM.MEH=BAG.IO.MEH.Out) then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge
  else if (BAG.IO.MEH.Out='kg') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Gewicht.Netto
  else if (BAG.IO.MEH.Out='t') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + (BAG.FM.Gewicht.Netto / 1000.0)
  else if (BAG.IO.MEH.Out='Stk') then
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + cnvfi("BAG.FM.Stück")
  else
    BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge +
                          Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
  Erx # RekReplace(701,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;

  vBuf707 # RekSave(707);

  // Fertigmeldung Klon anlegen..............
  BAG.FM.Nummer         # BAG.F.Nummer;
  BAG.FM.Position       # BAG.F.Position;
  BAG.FM.Fertigung      # BAG.F.Fertigung;
  BAG.FM.InputBAG       # BAG.F.Nummer;
  BAG.FM.InputID        # BAG.IO.ID;
  BAG.FM.BruderID       # BAG.IO.NachID;

  BAG.FM.OutputID       # 9999; // weiter unten setzen...
  BAG.FM.Fertigmeldung  # 1;
  REPEAT
    Erx # RekInsert(707,0,'MAN');
    if (Erx<>_rOK) then BAG.FM.Fertigmeldung # BAG.FM.Fertigmeldung + 1;
  UNTIL (erx=_rOK);


  if (BAG.IO.BruderID<>0) then begin
    // theo.INPUT ändern ...........................
    BAG.IO.Nummer  # BAG.IO.NachBAG;
    BAG.IO.ID      # BAG.IO.BruderID;
    Erx # RecRead(701, 1,0);    // NachID holen (Typ 701...)
    if (Erx>_rLocked) then begin
      RekRestore(vBuf707);
      RekRestore(vBuf703);
      RekRestore(vBuf701);
      ABBRUCH;
    end;
    RecRead(701,1,_recLock);
    BAG.IO.Ist.Out.Stk   # BAG.IO.Ist.Out.Stk   + "BAG.FM.Stück";
    BAG.IO.Ist.Out.GewN  # BAG.IO.Ist.Out.GewN  + BAG.FM.Gewicht.Netto;
    BAG.IO.Ist.Out.GewB  # BAG.IO.Ist.Out.GewB  + BAG.FM.Gewicht.Brutt;
    if (BAG.FM.MEH=BAG.IO.MEH.Out) then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Menge
    else if (BAG.IO.MEH.Out='kg') then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + BAG.FM.Gewicht.Netto
    else if (BAG.IO.MEH.Out='t') then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + (BAG.FM.Gewicht.Netto / 1000.0)
    else if (BAG.IO.MEH.Out='Stk') then
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge + cnvfi("BAG.FM.Stück")
    else
      BAG.IO.Ist.Out.Menge # BAG.IO.Ist.Out.Menge +
                            Lib_Einheiten:WandleMEH(707, "BAG.FM.Stück", BAG.FM.Gewicht.Netto, BAG.FM.Menge, BAG.FM.MEH, BAG.IO.MEH.Out);
    Erx # RekReplace(701,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      RekRestore(vBuf703);
      RekRestore(vBuf701);
      ABBRUCH;
    end;
  end;


  // neuen Output anlegen..........................
  BAG.IO.Nummer  # BAG.IO.NachBAG;
  BAG.IO.ID      # vNachID;//BAG.FM.BruderID;//BAG.IO.NachID;
  Erx # RecRead(701, 1,0);    // NachID holen (Typ 701...)
  if (Erx>_rLocked) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;

  SbrCopy(vBuf701,2, 701,2);
  SbrCopy(vBuf701,3, 701,3);
  SbrCopy(vBuf701,4, 701,4);
  SbrCopy(vBuf701,5, 701,5);
  BAG.IO.Materialtyp    # vBuf701->BAG.IO.Materialtyp;
  BAG.IO.MEH.IN         # vBuf701->BAG.IO.MEH.In;
  BAG.IO.MEH.Out        # vBuf701->BAG.IO.MEH.Out;
  BAG.IO.GesamtKostW1   # vBuf701->BAG.IO.GesamtKostW1;
  BAG.IO.BruderID       # BAG.IO.ID;
  BAG.IO.vonFertigmeld  # BAG.FM.Fertigmeldung;
  WHILE (RekInsert(701,0,'AUTO')<>_rOK) do
    BAG.IO.ID # BAG.IO.ID + 1;

  // Daten in der Fertigmeldung nachtragen...
  RecRead(707,1,_recLock);
  BAG.FM.OutputID # BAG.IO.ID;
  Erx # RekReplace(707,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;


  // Fertigungsmengen erhöhen ----------------------------------------------
  Recread(703,1,_RecLock);
  BAG.F.Fertig.Gew    # BAG.F.Fertig.Gew    + BAG.FM.Gewicht.Netto;
  BAG.F.Fertig.Stk    # BAG.F.Fertig.Stk    + "BAG.FM.Stück";
  BAG.F.Fertig.Menge  # BAG.F.Fertig.Menge  + BAG.FM.Menge;
  Erx # RekReplace(703,_recUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;

  // theoretischen Output ändern -------------------------------------------
  RecBufClear(701);
  BAG.IO.Nummer         # BAG.FM.Nummer;
  BAG.IO.ID             # BAG.FM.BruderID;
//debuG('modde:'+aint(bag.io.nummer)+'/'+aint(bag.iO.id));
  Erx # RecRead(701,1,_recLock);
  if (Erx<>_rOK) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;
  BAG.IO.Ist.In.Stk  # BAG.IO.Ist.In.Stk   + "BAG.FM.Stück";
  BAG.IO.Ist.In.GewN # BAG.IO.Ist.In.GewN  + BAG.FM.Gewicht.Netto;
  BAG.IO.Ist.In.GewB # BAG.IO.Ist.In.GewB  + BAG.FM.Gewicht.Brutt;
  if (BAG.FM.Meh=BAG.IO.MEH.In) then
    BAG.IO.Ist.IN.Menge # BAG.IO.Ist.IN.Menge + BAG.FM.Menge;
  Erx # RekReplace(701,_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    RekRestore(vBuf707);
    RekRestore(vBuf703);
    RekRestore(vBuf701);
    ABBRUCH;
  end;


  // Material anpassen..............................
  if (BAG.FM.Materialnr<>0) then begin
  // 27.04.2022 AH : BUG wenn direkt MatLöschen
//    Erx # RecLink(200,707,7,_recFirst);     // Materialkarte holen
  //  if (Erx>_rLocked) then begin
    vDatei # Mat_data:read(BAG.FM.Materialnr);
    if (vDatei<200) then begin
      RekRestore(vBuf707);
      RekRestore(vBuf703);
      RekRestore(vBuf701);
      ABBRUCH;
    end;
    vStatus # c_Status_BAGOutput;
    if (BAG.IO.NachBAG<>0) then begin     // Weiterbearbeitung?
      vBuf702 # RekSave(702);
      Erx # RecLink(702,701,4,_recFirst); // nächste Pos. holen
      if (Erx<=_rOK) then begin
        vNextAktion # BAG.P.Aktion;
        vStatus # BA1_Mat_Data:StatusLautEinsatz(BAG.P.Aktion, BAG.P.Auftragsnr);
      end;
      RekRestore(vBuf702);

      if (vNextAktion=c_BAG_Fahr09) then begin
        // FAHR-Reservierung neu anlegen ---------------------------------------
        RecBufClear(203);
        Mat.R.Materialnr      # Mat.Nummer;
        "Mat.R.Stückzahl"     # Mat.Bestand.Stk;
        Mat.R.Gewicht         # Mat.Bestand.Gew;
        Mat.R.Bemerkung       # vNextAktion;
        "Mat.R.Trägertyp"     # c_Akt_BAInput;
        "Mat.R.TrägerNummer1" # BAG.IO.Nummer;
        "Mat.R.TrägerNummer2" # BAG.IO.ID;
        if (Mat_Rsv_Data:Neuanlegen()=false) then begin
          RekRestore(vBuf707);
          RekRestore(vBuf703);
          RekRestore(vBuf701);
          Error(707106,'');
          ABBRUCH;
        end;
      end;
    end;

    if (vDatei=200) then begin
      Erx # RecRead(200,1,_RecLock);
      Mat_Data:SetStatus(vStatus);
      Erx # Mat_data:Replace(_recUnlock, 'AUTO');
      if (Erx<>_rOK) then begin
        RekRestore(vBuf707);
        RekRestore(vBuf703);
        RekRestore(vBuf701);
        ABBRUCH;
      end;
    end;
  end;  // Material anpassen


  // alles OK..........
  RekRestore(vBuf707);
  RekRestore(vBuf703);
  RekRestore(vBuf701);
  RETURN true;

end;


//========================================================================
//  _VerbuchenLFS
//
//========================================================================
sub _VerbuchenLFS() : logic;
local begin
  Erx       : int;
  vPos      : int;
end;
begin DoLogProc;

  RecBufClear(440);
  Lfs.Nummer        # myTmpNummer;
  Lfs.Lieferdatum   # VsD.Datum;
  Lfs.Anlage.Datum  # today;
  // 2023-01-10 AH...
  Lfs.Kennzeichen   # Vsd.Kennzeichen;
  Lfs.Bemerkung     # StrCut(Vsd.Bemerkung,1,64);
  vPos # 1;

  TRANSON;

  FOR Erx # RecLink(651,650,3,_recFirst)    // Positionen loopen
  LOOP Erx # RecLink(651,650,3,_recNext)
  WHILE (Erx<=_rLocked) do begin

    Erx # RecLink(655,651,2,_recFirst);     // Pool holen
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RETURN false
    end;

    Erx # RecLink(404,655,7,_recFirst);   // Auftragskation holen
    if (Erx<=_rLocked) then begin
      Erx # RecLink(401,404,1,_recFirst); //Position holen
    end
    else begin
      Erx # RecLink(401,655,10,_recFirst);    // Auftragspos holen  15.11.2021
    end;
    if (Erx>_rLocked) then begin
      TRANSBRK;
      RETURN false;
    end;

    // 27.04.2022 AH: Paketversand
    if (VsP.Paketnr<>0) then begin
      Pak.Nummer # VsP.Paketnr;
      Erx # RecRead(280,1,0);
      if (erx>_rLocked) then begin
        TRANSBRK;
        RETURN false
      end;
      // Positionen loopen...
      FOR Erx # RecLink(281,280,1,_recFirst)
      LOOP Erx # RecLink(281,280,1,_recNext)
      WHILE (Erx<=_rLocked) do begin
        if (_Erzeuge441(Pak.P.MaterialNr,var vPos)=false) then begin
          TRANSBRK;
          RETURN false
        end;
      END;
    end
    else begin
  //    if (VsP.Vorgangstyp<>c_VSPTyp_Auf) then begin
      if (VsP.Materialnr=0) then begin
        TRANSBRK;
        RETURN false;
      end;
      if (_Erzeuge441(VSP.Materialnr,var vPos)=false) then begin
        TRANSBRK;
        RETURN false
      end;
    end;
  END;

  // LFS komplett speichern...
  if (Lfs_Data:SaveLFS()=false) then begin
    TRANSBRK;
    RETURN false;
  end;

  // Versand rückspeichern
  RecRead(650,1, _RecLock);
  Vsd.Datum.Verbucht  # today;
  "Vsd.Löschmarker"   # '*';
  RekReplace(650,0,'AUTO');

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  Verbuchen
// AFX  SFX_Vsd:Vsd.Verbuchen.Post  29.09.2021  MR  (2166/55/1)
//========================================================================
sub Verbuchen() : logic;
local begin
  vRes       : logic;
end;
begin DoLogProc;

  // Selbstabholer?? ---> dann nur LFS anlegen
  if (Vsd.SelbstabholKdNr<>0) then
    vRes # _VerbuchenLFS();
  else
    vRes # _VerbuchenBAG();
 
  RunAFX('Vsd.Verbuchen.Post',ABool(vRes));
  RETURN vRes;
end;


//========================================================================
//  VsTo2VsdP
//          nimmt kompletten Pooleintrag in den Versand auf
//========================================================================
sub VsPToVsdP() : logic;
local begin
  Erx   : int;
  vPos  : int;
end;
begin
  Erx # RecLink(651,650,3,_recLast);
  if (Erx>_rLocked) then vPos # 1
  else vPos # Vsd.P.Position + 1;

  RecBufClear(651);
  Vsd.P.Nummer          # Vsd.Nummer;
  Vsd.P.Position        # vPos;
  Vsd.P.Verladetermin   # today;
  Vsd.P.Verladezeit     # now;
  Vsd.P.Poolnr          # VsP.Nummer;
  Vsd.P.MEH.In          # VsP.MEH.In;
  Vsd.P.MEH.Out         # VsP.MEH.Out;
  Vsd.P.Menge.In        # VsP.Menge.In.Rest;
  Vsd.P.Menge.Out       # VsP.Menge.Out.Rest;
  "Vsd.P.Stück"         # "VsP.Stück.Rest";
  Vsd.P.Gewicht         # VsP.Gewicht.Rest;

  REPEAT
    Erx # RekInsert(gFile,0,'MAN');
    if (erx<>_rOK) then Vsd.P.Position # Vsd.P.Position + 1;
  UNTIl (erx=_rOK);

  // Verbuchen....
  RecRead(655,1,_recLock);
  VsP.Menge.In.Rest   # VsP.Menge.In.Rest - VsD.P.Menge.In;
  VsP.Menge.Out.Rest  # VsP.Menge.Out.Rest - VsD.P.Menge.Out;
  "VsP.Stück.Rest"    # "VsP.Stück.Rest" - "VsD.P.Stück";;
  VsP.Gewicht.Rest    # VsP.Gewicht.Rest - VsD.P.Gewicht;
  Erx # RekReplace(655,_RecUnlock,'AUTO');

  // 2022-11-10 AH
  RecRead(650,1,_recLock);
  Vsd.Positionsgewicht # Vsd.Positionsgewicht + VsD.P.Gewicht;
  RekReplace(650,_RecUnlock,'AUTO');

  RETURN (Erx=_rOK);
end;


//========================================================================
//  PoolMarkToVersandPos
//
//========================================================================
sub PoolMarkToVersandPos() : int;
local begin
  Erx : int;
end;
begin

  TRANSON;

  Erx # Lib_Mark:Foreach(655, here+':_655To651Delegate');
  if (Erx<>0) then begin
    TRANSBRK;
    RETURN Erx;
  end;

  TRANSOFF;

  Lib_Mark:Reset(655);

  RETURN _rOK;
end;


//========================================================================
//  _655To651Delegate
//
//========================================================================
sub _655To651Delegate() : int;
local begin
  Erx : int;
  vOK : logic;
end;
begin

  // Selbstabholer dürfen nur eigenes Material holen und das muss VON und NACH eigene Firma gehen
  if (Vsd.SelbstabholKdNr<>0) then begin
    Erx # RecLink(655,651,2,_recFirst);   // Pool holen
    if (Erx<=_rLocked) then begin
//debugx(VsP.Vorgangstyp+'; '+aint(VsP.AuftragsKundennr)+'<>'+aint(Vsd.SelbstabholKdNr)+' or '+aint(VsP.Start.Adresse)+'<>'+aint(VsP.Ziel.Adresse)+' or '+aint(VsP.Start.Adresse)+'<>'+aint(Set.EigeneAdressnr));
//      if (VsP.Vorgangstyp=c_VSPTyp_BAG) or
//        (VsP.AuftragsKundennr<>Vsd.SelbstabholKdNr) or
//        (VsP.Start.Adresse<>VsP.Ziel.Adresse) or (VsP.Start.Adresse<>Set.EigeneAdressnr) then begin
      vOK # (VsP.Materialnr<>0) and (VsP.AuftragsKundennr=Vsd.SelbstabholKdNr);
      if (vOK) then begin
        Erx # RecLink(401,655,10,_recFirst);    // Auftragspos holen
        if (Erx<=_rLocked) then begin
          vOK # (VsP.Ziel.Adresse=Auf.Lieferadresse);
          if (vOK) then begin
            vOK # (VsP.Start.Adresse=Set.EigeneAdressnr) or (VsP.Start.Adresse=Auf.Lieferadresse);
          end;
        end;
      end;
      if (vOK=false) then RETURN 651002;
    end;
  end;

  if (Vsd_Data:VsPtoVsdP()=false) then begin
    RETURN 2;
  end;

  RETURN 0;

end;


//========================================================================
// FMalleLFS
//========================================================================
sub FMalleLFS(
  aNr             : int;
  aDatum          : date;
  opt aPlatz      : alpha;
  opt aAbschluss  : logic) : logic;
local begin
  Erx         : int;
  vTxt        : int;
  vA          : alpha;
  vOK         : logic;
end;
begin
  Vsd.Nummer # aNr;
  Erx # recRead(650,1,0);
  if (Erx>_rLocked) then begin
    Error(99,'Versand nicht gefunden');
    RETURN false;
  end;
  
  vTxt # TextOpen(20);

  TRANSON;
  APPOFF();

  // Versandpos loopen...
  FOR Erx #  RecLink(651,650,3,_recFirst)
  LOOP Erx #  RecLink(651,650,3,_recNext)
  WHILE (Erx<=_rLocked) do begin
    Erx # RecLink(441,651,4,_recFirst);   // LfsPos holen
    if (erx>_rMultikey) then CYCLE;
    
    vA # '|'+aint(lfs.p.nummer)+'|';
    // der LFS ist schon erledigt?
    if (TextSearch(vTxt, 1, 1, 0, vA)>0) then CYCLE;
    TextAddline(vTxt, vA);
    vOK # false;
    Lfs.Nummer # Lfs.P.Nummer;
    Erx # RecRead(440,1,0);
    if (Erx>_rLocked) then BREAK;
    if ("Lfs.Löschmarker"<>'') then BREAK;
    if (Lfs.Datum.Verbucht<>0.0.0) then BREAK;

//debugx('verbuche KEY440');
    vOK # Lfs_LFA_Data:GesamtFM(aDatum, aPlatz);
    if (vOK=false) then BREAK;

    if (aAbschluss) then begin
      vOK # false;
      Erx # RecLink(702,440,7,_recFirst);   // BA-Position prüfen
      if (Erx>_rLocked) then begin
        Error(702440,'');
        BREAK;
      end;
      vOK # Lfs_LFA_Data:Abschluss(aDatum, true);   // SILENT
      if (vOK=false) then BREAK;
    end;
  END;

  TextClose(vTxt);

  APPON();

  if (vOK=false) then begin
    TRANSBRK;
    RETURN False;
  end;

  TRANSOFF;
 
  RETURN true;
end;


//========================================================================
SUB _BauePoolTxt() : int;
local begin
  Erx   : int;
  vTxt  : int;
end;
begin
end;


//========================================================================
sub _Merke(
  aTxt  : int;
  aWas  : alpha)
begin
  aWas # '|'+aWas+'|';
//debugx('merke '+aWas);
  TextAddLine(aTxt, aWas)
end;


//========================================================================
sub _Finde(
  aTxt  : int;
  aWas  : alpha) : logic;
local begin
  vI  : int;
end;
begin
  aWas # '|'+aWas+'|';
//debugx('suche '+aWas);
  vI # TextSearch(aTxt, 1, 1, 0, aWas);
  RETURN vI>0;
end;


//========================================================================
SUB _CheckPoolErledigt(aTxt : int)
local begin
  Erx   : int;
  vPool : int;
  v441  : int;
end;
begin
  vPool # Lfs.P.Versandpoolnr;

  // ist Pool noch aktiv?
  VsP.Nummer # vPool;
  Erx # RecRead(655,1,0);
  if (Erx<=_rLocked) then begin
                                                            // wenn kein BA-Versand? -> ENDE
                                                            // noch Restmengen? -> ENDE
    if (VsP.Vorgangstyp<>c_VSPTyp_BAG) or (Vsp.Gewicht.Rest>0.0) then begin
      _Merke(aTxt, '!POOL'+aint(vPool));
      RETURN;
    end;
  end
  else begin
    "VsP~Nummer" # vPool;
    Erx # RecRead(656,1,0);
    if (Erx<=_rLocked) then begin
      RecBufCopy(656,655);
      if (VsP.Vorgangstyp<>c_VSPTyp_BAG) then begin         // wenn kein BA-Versand? -> ENDE
        _Merke(aTxt, '!POOL'+aint(vPool));
        RETURN;
      end;
    end;
  end;

  // ! Pool ist "BA-VERSAND" und Pool-Soll-Menge ist Null !
  _Merke(aTxt, 'POOL'+aint(Lfs.P.Versandpoolnr));


  Erx # RecLink(701,655,8,_recfirst);   // BA-Input holen
  if (erx>_rLocked) then RETURN;
  Erx # RecLink(702,701,4,_recFirst);   // BA-Pos "VERSAND" holen
  if (erx>_rLocked) then RETURN;

  // Prüfen, ob der gesamte Versand erledigt ist:
  if (_Finde(aTxt, 'BAG'+aint(BAG.P.Nummer)+'/'+aint(BAg.P.Position))) then RETURN;
  if (_Finde(aTxt, '!BAG'+aint(BAG.P.Nummer)+'/'+aint(BAg.P.Position))) then RETURN;

/***
  // LFS loopen...
  FOR Erx # RecLink(440,702,14,_recFirst)
  LOOP Erx # RecLink(440,702,14,_recNext)
  WHILE (Erx<=_rLocked) do begin
    // LFS noch offen?
    if (Lfs.Datum.Verbucht=0.0.0) then RETURN false;
  END;
***/

  // für diesen BA-VERSAND müssen wir alle LFS-Pos. prüfen...
  v441 # RekSave(441);
  RecBufClear(441);
  Lfs.P.Versandpoolnr # vPool;
  // LFS-Positionen loopen...
//debugx('Lfspos...');
  FOR Erx # Recread(441,6,0)
  LOOP Erx # Recread(441,6,_recNext)
  WHILE (erx<=_rMultikey) and (Lfs.P.Versandpoolnr=vPool) do begin
//debugx('KEY441');
    if (Lfs.P.Datum.Verbucht=0.0.0) then begin
      RekRestore(v441);
      _Merke(aTxt, '!BAG'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
      RETURN;
    end;
  END;
  RekRestore(v441);

  // ! ALLE LFS-Pos. sind verbucht!
  
  // dieser "BA-VERSAND" ist damit erledigt!
  _Merke(aTxt, 'BAG'+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position));
  
  RETURN;
  
  /**
  v441 # RekSave(441);
  RecBufClear(441);
  Lfs.P.Versandpoolnr # vPool;
  FOR Erx # Recread(441,6,0)
  LOOP Erx # Recread(441,6,_recNext)
  WHILE (erx<=_rMultikey) and (Lfs.P.Versandpoolnr=vPool) do begin
    if (Lfs.P.Datum.Verbucht=0.0.0) then begin
      RekRestore(v441);
      RETURN false;
    end;
  END;

  // ALLE LFS verbucht!!
  RekRestore(v441);
  RETURN true;
  */
end;


//========================================================================
//
//========================================================================
SUB PruefeObAllesErledigtBeiLFS();
local begin
  Erx   : int;
  v701  : int;
  v702  : int;
  vTxt  : int;
  vA    : alpha;
  vI    : int;
end;
begin

  if (Set.Installname<>'HWE') then RETURN;
  
  v701 # RekSave(701);
  v702 # RekSave(702);

  vTxt # TextOpen(20);

  // ! ein LFS wurde abgeschlossen !

  // LFS-Positionen loopen...
  FOR Erx # RecLink(441,440,4,_RecFirst)
  LOOP Erx # RecLink(441,440,4,_RecNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lfs.P.Versandpoolnr>0) then begin
      // schon OK?
      if (_Finde(vTxt, 'POOL'+aint(Lfs.P.Versandpoolnr))) then CYCLE;
      if (_Finde(vTxt, '!POOL'+aint(Lfs.P.Versandpoolnr))) then CYCLE;
      
      _CheckPoolErledigt(vTxt);
    end;
  END;
//debugx('Erledigt:'+abool(vOK));
/**
  ANDERER ANSATZ:
  - TXT sollte alle BA-VERSAND enthalten, die ab jetzt erledigt sind!
  - diese abschließen
**/
  FOR vI # TextSearch(vTxt, 1, 1, 0, '|BAG')
  LOOP vI # TextSearch(vTxt, vI+1, 1, 0, '|BAG')
  WHILE (vI>0) do begin
    vA # TextLineRead(vTxt, vI, 0);
//debugx('schliße '+vA);
    vA # Str_token(vA, 'BAG',2);
    BAG.P.Nummer    # cnvia(Str_Token(vA,'/',1));
    BAG.P.Position  # cnvia(Str_Token(vA,'/',2));
    Erx # RecRead(702,1,0);
    BA1_Fertigmelden:AbschlussPos(BAG.P.nummer, BAG.P.Position, today, now, true);
  END;
  
  Textclose(vTxt);
  RekRestore(v701);
  RekRestore(v702);
end;


//========================================================================