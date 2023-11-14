@A+
//===== Business-Control =================================================
//
//  Prozedur    VsP_Data
//                  OHNE E_R_G
//  Info
//
//
//  09.07.2009  AI  Erstellung der Prozedur
//  09.04.2010  AI  sub SavePool
//  10.12.2012  AI  BAGInput2Pool: Termin ggf. aus Kommission
//  20.09.2021  AH  ERX
//  08.11.2021  AH  Gewichte eher Brutto
//  27.01.2022  AH  Vsp.AuftragsKdSW
//  2022-11-07  AH  "SavePool" arbeitet mit aktuellm Materialbuffer
//
//  Subprozeduren
//  SUB Rest2Pool(aNr : int);
//  SUB BAGInput2Ablage();
//  SUB BAGInput2Pool();
//  SUB Mat2Pool(aMat : int; aTyp : alpha; aNr : int; aPos1 : word; aPos2) : int;
//  SUB Pool2Ablage(aTyp : alpha) : int; opt aMan : logic;
//  SUB Ablage2Pool(aTyp : alpha) : int;
//  SUB DelMatAusPool(aMat : int);
//  SUB DelPool(aVrg : alpha; aNr : int; aPos: word; aPos2 : word; aTyp  : alpha): logic;
//  SUB LfsPos_Verbuchen();
//  SUB ErzeugePoolZumVersand();
//  SUB SavePool() : int;
//  SUB Auf2Pool(aNr : int; aPos1 : word; aPos2 : word; aGew : float; aStk : int) : int;
//  SUB ExistsPaket(aPak : int) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

declare Pool2Ablage(aTyp : alpha; opt aMan : logic) : int;
declare DelPool(aVrg : alpha; aNr : int; aPos : word; aPos2 : word; aTyp  : alpha): logic;
declare Ablage2Pool(aTyp : alpha) : int;
declare NimmPaketDaten(aPak : int) : int;

//========================================================================
//  Rest2Pool    +ERR
//
//========================================================================
sub Rest2Pool(aNr : int);
local begin
  Erx : int;
end;
begin DoLogProc;
  "VsP.Nummer" # aNr;
  Erx # RecRead(655,1,0);
  if (Erx<=_rLocked) then begin           // Bestandsdatei!
    if ("VsP.Materialnr"=0) then RETURN;

    Erx # RecLink(200,655,2,_recFirst);   // Material hilen
    if (Erx>_rLocked) then RETURN;

    if ("Mat.Löschmarker"='*') then RETURN;
    if (Mat.Bestand.Gew=0.0) then RETURN;
  end
  else begin  // ABLAGE???
    "VsP~Nummer" # aNr;
    Erx # RecRead(656,1,0);
    if (Erx>_rLocked) then RETURN;

    if ("VsP~Materialnr"=0) then RETURN;

    Erx # RecLink(200,656,2,_recFirst);   // Material hilen
    if (Erx>_rLocked) then RETURN;

    if ("Mat.Löschmarker"='*') then RETURN;
    if (Mat.Bestand.Gew=0.0) then RETURN;

    if (Ablage2Pool('AUTO')<>_rOK) then begin
// Was bei Fehler??
    end;
  end;


  if (VsP.Nummer=aNr) then begin
    RecRead(655,1,_recLock);
    // Mengen setzen...
    VsP.Menge.In.Soll     # Mat.Bestand.Gew;
    VsP.Menge.In.Rest     # VsP.Menge.In.Soll;
    VsP.Menge.In.Ist      # 0.0;
    VsP.Menge.Out.Soll    # Mat.Bestand.Gew;
    VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll;
    VsP.Menge.Out.Ist     # 0.0;
    "VsP.Stück.Soll"      # Mat.Bestand.Stk;
    "VsP.Stück.Rest"      # "VsP.Stück.Soll";
    "VsP.Stück.Ist"       # 0;
    VsP.Gewicht.Soll      # Mat.Gewicht.Brutto;// Mat.Bestand.Gew; 08.11.2021 AH
    if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll # Mat.Bestand.Gew;
    VsP.Gewicht.Rest      # VsP.Gewicht.Soll;
    VsP.Gewicht.Ist       # 0.0;
    RekReplace(655,0,'AUTO');
  end;

  // 12.04.2022 AH: auch aus VERSAND entfernen
  Erx # RecLink(651,655,6,_recFirst);
  if (Erx<=_rLocked) then begin
    RekDelete(651);
  end;
  
end;


//========================================================================
//  BAGInput2Ablage    +ERR
//
//========================================================================
sub BAGInput2Ablage();
local begin
  Erx : int;
end;
begin DoLogProc;
  RecBufClear(655);
  VsP.Vorgangstyp     # c_VSPTyp_BAG;
  VsP.Vorgangsnr      # BAG.IO.Nummer;
  VsP.Vorgangspos1    # BAG.IO.ID;
  VsP.Vorgangspos2    # 0;
  Erx # RecRead(655,2,0);       // Pool prüfen
  if (Erx<=_rMultikey) then begin
    Erx # Pool2Ablage('AUTO');
  end;
end;


//========================================================================
//  BAGInput2Pool      +ERR
//
//========================================================================
sub BAGInput2Pool() : logic;
local begin
  Erx           : int;
  vInDatei      : word;
  vBuf702       : int;
  vOK           : logic;
  v401          : int;
  v400          : int;
end;
begin DoLogProc;

  // nur Versand kann Pool generieren
  if (BAG.P.Aktion<>c_BAG_Versand) then RETURN true;
  if (BAG.VorlageYN) then RETURN true;    // 24.03.2022 AH

  // ist vorherige Position noch aktiv?
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin
    vOK # y;
    vBuf702 # RecBufCreate(702);
    Erx # RecLink(vBuf702,701,2,_recFirst);   // Vorgänger-Position holen
    if (Erx<=_rLocked) and (vBuf702->"BAG.P.Löschmarker"='*') then VOK # n;
    RecBufDestroy(vBuf702);
    if (vOK=false) then RETURN true;
  end;

  vInDatei # 0;
  RecBufClear(655);
  VsP.Vorgangstyp     # c_VSPTyp_BAG;
  VsP.Vorgangsnr      # BAG.IO.Nummer;
  VsP.Vorgangspos1    # BAG.IO.ID;
  VsP.Vorgangspos2    # 0;
  RecBufCopy(655,656);
  Erx # RecRead(655,2,0);       // Pool prüfen
  if (Erx<=_rMultikey) then vInDatei # 655;
  if (vInDatei=0) then begin
    RecBufCopy(656,655);
    Erx # RecRead(656,2,0);     // ~Pool prüfen
    if (Erx<=_rMultikey) then vInDatei # 656;
  end;


  if (vInDatei=655) and ("BAG.P.Löschmarker"<>'') then begin
    Erx # Pool2Ablage('AUTO');
    RETURN (Erx=_rOK);
  end;


  TRANSON;

  // Satz neu anlegen?
  if (vInDatei=655) then begin
    RecRead(655,1,_recLock);
  end
  else begin
    RecBufClear(655);
  end;

  VsP.Vorgangstyp       # c_VSPTyp_BAG;
  VsP.Vorgangsnr        # BAG.IO.Nummer;
  VsP.Vorgangspos1      # BAG.IO.ID;
  VsP.Vorgangspos2      # 0;
  VsP.Termin.MinDat     # BAG.P.Plan.StartDat;
  VsP.Termin.MaxDat     # BAG.P.Plan.EndDat;
  VsP.Termin.Zusatz     # '';
  Erx # RecLink(100,702,7,_recFirst);   // Lohnarbeiter holen
  if (Erx>_rLocked) or (BAG.P.ExterneLiefNr=0) then RecBufClear(100);
  VsP.Spediteurnr       # Adr.Nummer;
  VsP.SpediteurSW       # Adr.Stichwort;
  //VsP.Materialnr        # BAG.IO.MaterialRstNr;//BAG.IO.Materialnr;
  VsP.Materialnr        # BAG.IO.Materialnr;
  if (BAG.IO.MaterialTyp=c_IO_BAG) then
    VsP.Materialnr        # 0;

  VsP.Artikelnr         # BAG.IO.Artikelnr;
  VsP.Art.Adresse       # BAG.IO.LagerAdresse;
  VsP.Art.Anschrift     # BAG.IO.LagerAnschr;
  VsP.Art.Charge        # BAG.IO.Charge;

  VsP.Auftragsnr        # BAG.IO.Auftragsnr;
  VsP.Auftragspos       # BAG.IO.AuftragsPos;
  Vsp.AuftragsPos2      # BAG.IO.AuftragsFert;
  if (VsP.Auftragsnr<>0) then begin
    v400 # RekSave(400);
    Auf.Nummer # VsP.Auftragsnr;
    Erx # RecRead(400,1,0);
    if (Erx>_rLocked) then begin
      "Auf~Nummer" # VsP.Auftragsnr;
      Erx # RecRead(410,1,0);
      if (Erx>_rLocked) then RecBufClear(410);
      RecBufCopy(410,400);
    end;
    VsP.AuftragsKundennr  # Auf.Kundennr;
    VsP.AuftragsKdSW      # Auf.KundenStichwort;
    RekRestore(v400);
  end;
// 27.01.2022 AH: besser wie oben
//  if (Vsp.Materialnr<>0) then begin
//    Erx # RecLink(200,655,2,_recFirst);   // Material holen
//    if (Erx<=_rLocked) then
//      Vsp.AuftragsKundennr  # Mat.KommKundennr;
//  end;

  // 10.12.2012 AI: ggf. Kommission holen
  if (VsP.Termin.MinDat=0.0.0) or (VsP.Termin.MaxDat=0.0.0) then begin
    Erx # RekLinkB(v401,655,10,_recFirst);    // Auftragspos holen
    if (Erx<=_rLocked) then begin
      if (VsP.Termin.MinDat=0.0.0) then VsP.Termin.MinDat # v401->Auf.P.Termin1Wunsch;
      if (VsP.Termin.MaxDat=0.0.0) then VsP.Termin.MaxDat # v401->Auf.P.Termin1Wunsch;
    end;
  end;


  // Mengen setzen...
//  if (vInDatei<>655) then begin
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin
    VsP.Menge.In.Soll     # BAG.IO.Plan.In.Menge;
    VsP.Menge.In.Rest     # VsP.Menge.In.Soll - BAG.IO.Ist.In.Menge;
    VsP.MEH.In            # BAG.IO.MEH.In;
    VsP.Menge.Out.Soll    # BAG.IO.Plan.Out.Meng;
    VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll - BAG.IO.Ist.In.Menge;;
    VsP.MEH.Out           # BAG.IO.MEH.Out;
    "VsP.Stück.Soll"      # BAG.IO.Plan.In.Stk;
    "VsP.Stück.Rest"      # "VsP.Stück.Soll" - BAG.IO.Ist.In.Stk;
    VsP.Gewicht.Soll      # BAG.IO.Plan.In.GewB;  //  BAG.IO.Plan.In.GewN; 08.11.2021 AH
    if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll      # BAG.IO.Plan.In.GewN;
    VsP.Gewicht.Rest      # VsP.Gewicht.Soll - BAG.IO.Ist.In.GewN;
  end
  else begin
    VsP.Menge.In.Soll     # BAG.IO.Plan.Out.Meng;
    VsP.Menge.In.Rest     # VsP.Menge.In.Soll - BAG.IO.Ist.Out.Menge;
    VsP.MEH.In            # BAG.IO.MEH.In;
    VsP.Menge.Out.Soll    # VsP.Menge.In.Soll;
    VsP.Menge.Out.Rest    # VsP.Menge.In.Rest;
    VsP.MEH.Out           # VsP.MEH.In;
    "VsP.Stück.Soll"      # BAG.IO.Plan.Out.Stk;
    "VsP.Stück.Rest"      # "VsP.Stück.Soll" - BAG.IO.Ist.Out.Stk;
    VsP.Gewicht.Soll      # BAG.IO.Plan.In.GewB;  //  BAG.IO.Plan.In.GewN; 08.11.2021 AH
    if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll      # BAG.IO.Plan.In.GewN;
    VsP.Gewicht.Rest      # VsP.Gewicht.Soll - BAG.IO.Ist.Out.GewN;
  end;

  // Startdaten setzen...
  VsP.Start.Adresse      # BAG.IO.LagerAdresse;
  VsP.Start.Anschrift    # BAG.IO.LagerAnschr;
  Erx # RecLink(101, 655, 4, _recFirst);    // Startanschrift holen
  if (Erx>_rlocked) then begin
    TRANSBRK;
    Error(655101,AInt(VsP.Start.Adresse)+'/'+aInt(VsP.Start.Anschrift));
    RETURN false;
  end;
  VsP.Start.Lagerplatz  # '';
  VsP.Start.Tour        # '';


  // Zieldaten setzen...
  VsP.Ziel.Adresse      # BAG.P.ZielAdresse;
  VsP.Ziel.Anschrift    # BAG.P.ZielAnschrift;
  Erx # RecLink(101, 655, 5, _recFirst);    // Zielanschrift holen
  if (Erx>_rlocked) then begin
    Error(655101,AInt(VsP.Ziel.Adresse)+'/'+aInt(VsP.Ziel.Anschrift));
    RETURN false;
  end;
  VsP.Ziel.Lagerplatz   # '';
  VsP.Ziel.Tour         # '';


  if (vInDatei<>655) then begin
    // Nummernvergabe...
    VsP.Nummer # Lib_Nummern:ReadNummer('Versandpool');
    if (VsP.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      TRANSBRK;
      Error(655001,'');
      RETURN false;
    end;
    Erx # RekInsert(655,_recUnlock,'AUTO');
  end
  else begin
    Erx # RekReplace(655,_RecUnlock,'AUTO');
  end;
  if (Erx<>_rOK) then begin
    TRANSBRK;
    Error(655000,'');
    RETURN false;
  end;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  Mat2Pool    +ERR
//              RETURN Poolnummer
//========================================================================
sub Mat2Pool(
  aMat        : int;
  aTyp        : alpha;
  aNr         : int;
  aPos1       : word;
  aPos2       : word;
  ) : int;
local begin
  Erx           : int;
  vZielAdr    : int;
  vZielAnschr : int;
  vBuf101     : int;
  vBuf200     : int;
  vBuf400     : int;
  vPak        : int;
end;
begin DoLogProc;

  if (aMat=0) then begin
    Error(655200,AInt(aNr));
    RETURN 0;
  end;

  RecBufClear(655);
  VsP.Vorgangstyp       # StrCut(aTyp,1,3);
  VsP.Vorgangsnr        # aNr;
  VsP.VorgangsPos1      # aPos1;
  VsP.VorgangsPos2      # aPos2;
  VsP.Materialnr        # aMat;
  Erx # RecRead(655,5,_recTest);
  if (Erx<=_rMultikey) then begin
    // EXISITERT BEREITS!!!
    Error(655201,AInt(aNr));
    RETURN 0;
  end;

  vBuf200 # RecBufCreate(200);
  Erx # RecLink(vBuf200, 655,2,_recFirst);    // Material holen
  if (Erx>_rLocked) then begin
    RecBufDestroy(vBuf200);
    Error(655200,AInt(aNr));
    RETURN 0;
  end;

  if (vBuf200->"Mat.Löschmarker"='*') then begin
    RecBufDestroy(vBuf200);
    Error(655202,AInt(aNr));
    RETURN 0;
  end;
  
  // Mengen setzen...
  VsP.Menge.In.Soll     # vBuf200->Mat.Bestand.Gew;   // 26.04.2022 AH: alles mit vBuf200
  "VsP.Stück.Soll"      # vBuf200->Mat.Bestand.Stk;
  VsP.Gewicht.Soll      # vBuf200->Mat.Gewicht.Brutto; // Mat.Bestand.Gew; 08.11.2021 AH
  if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll # vBuf200->Mat.Bestand.Gew;

  // Startdaten setzen...
  VsP.Auftragsnr        # vBuf200->Mat.Auftragsnr;
  VsP.AuftragsPos       # vBuf200->Mat.AuftragsPos;
  Vsp.AuftragsKundennr  # vBuf200->Mat.KommKundennr;
  VsP.AuftragsKdSW      # vBuf200->Mat.KommKundenSWort;
  VsP.Start.Adresse     # vBuf200->Mat.Lageradresse;
  VsP.Start.Anschrift   # vBuf200->Mat.Lageranschrift;
  VsP.Start.Lagerplatz  # vBuf200->Mat.Lagerplatz;
  VsP.Start.Tour        # '';

    // 26.04.2022 AH: PAKETE EINZELN
  if (vBuf200->Mat.Paketnr<>0) then begin
    vPak # NimmPaketDaten(vBuf200->Mat.Paketnr);
    // Fehler?
    if (vPak<0) then begin
      RecBufDestroy(vBuf200);
      RETURN 0;
    end;
  end;
  RecBufDestroy(vBuf200);
  
  VsP.Menge.In.Rest     # VsP.Menge.In.Soll;
  "VsP.Stück.Rest"      # "VsP.Stück.Soll";
  VsP.Menge.Out.Soll    # Vsp.Menge.In.Soll;
  VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll;
  VsP.Gewicht.Rest      # VsP.Gewicht.Soll;

  if (vPak=0) then begin
    // Zieldaten setzen...
    // Versand für Kundenauftrag?
    if (aTyp=c_VSPTyp_Auf) then begin
      vBuf400 # RecBufCreate(400);
      vBuf400->Auf.Nummer # aNr;
      Erx # RecRead(vBuf400, 1, 0); // Auftrag holen
      if (Erx>_rLocked) then begin
        RecBufDestroy(vBuf400);
        Error(655400,AInt(aNr));
        RETURN 0;
      end;
      vZielAdr    # vBuf400->Auf.Lieferadresse;
      vZielAnschr # vBuf400->Auf.Lieferanschrift;
      RecBufDestroy(vBuf400);
    end;

    if (aTyp=c_VSPTyp_Ein) then begin
      vZielAdr    # Set.EigeneAdressnr;
      vZielAnschr # 1;
    end;


    // Zieldaten setzen...
    VsP.Ziel.Adresse      # vZielAdr;
    VsP.Ziel.Anschrift    # vZielAnschr;
    vBuf101 # RecBufCreate(101);
    Erx # RecLink(vBuf101, 655, 5, _recFirst);    // Zielanschrift holen
    if (Erx>_rlocked) then begin
      RecBufDestroy(vBuf101);
      Error(655101,AInt(vZielAdr)+'/'+aInt(vZielanschr));
      RETURN 0;
    end;
    VsP.Ziel.Lagerplatz   # '';
    VsP.Ziel.Tour         # vBuf101->Adr.A.Tour;

    RecBufDestroy(vBuf101);

    // Nummernvergabe...
    VsP.Nummer # Lib_Nummern:ReadNummer('Versandpool');
    if (VsP.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      Error(655001,'');
      RETURN 0;
    end;
    Erx # RekInsert(655,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(655000,'');
      RETURN 0;
    end;
  end;  // einzelnes Material ODER NEUES PAKET

  // 10.11.2021 AH: Materialstatus setzen
  if (Mat.Status=c_Status_Vsb) then begin
    RecRead(200,1,_RecLock);
    Mat_Data:SetStatus(c_Status_Versand);
    Erx # Mat_data:Replace(0,'AUTO');
    if (Erx<>_rOK) then RETURN 0;
  end;
 

  RETURN VsP.Nummer;
end;


//========================================================================
//  Pool2Ablage   +ERR
//
//========================================================================
Sub Pool2Ablage(
  aTyp      : alpha;
  opt aMan  : logic;
  ) : int;
local begin
  Erx : int;
end;
begin DoLogProc;
 
  TRANSON;

  if (VSP.Materialnr<>0) and (aMan) then begin
    Erx # RecLink(200,655,2,_recFirst);   // Material holen
    if (Erx<=_rLocked) then begin
      RecRead(200,1,_recLock);
      Mat_Data:SetStatus(c_Status_VersandDel);
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        TRANSBRK;
        RETURN Erx;
      end;
    end;
  end;

  // "brutal" in Ablage schieben...
  RecBufCopy(655,656);
  Rekdelete(656,0,aTyp);
  RekInsert(656,0,aTyp);

  Erx # RekDelete(655,0,aTyp);
  if (erx<>_rOK) then begin
    TRANSBRK;
//      Error(001000+Erx,gTitle);
    RETURN Erx;
  end;

  TRANSOFF;

  RETURN Erx;
end;


//========================================================================
//  Ablage2Pool   +ERR
//
//========================================================================
Sub Ablage2Pool(aTyp : alpha) : int;
local begin
  Erx : int;
end;
begin DoLogProc;

    TRANSON;

    // "brutal" in Ablage schieben...
    RecBufCopy(656,655);
    RekDelete(655,0,aTyp);
    RekInsert(655,0,aTyp);

    Erx # RekDelete(656,0,aTyp);
    if (erx<>_rOK) then begin
      TRANSBRK;
      RETURN Erx;
    end;

    TRANSOFF;

    RETURN Erx;
end;


//========================================================================
//  DelPool       +ERR
//
//========================================================================
sub DelPool(
  aVrg  : alpha;
  aNr   : int;
  aPos  : word;
  aPos2 : word;
  aTyp  : alpha;
) : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  RecBufClear(655);
  VsP.Vorgangstyp     # aVrg;
  VsP.Vorgangsnr      # aNr;
  VsP.Vorgangspos1    # aPos;
  VsP.Vorgangspos2    # aPos2;

  TRANSON;

  Erx # RecRead(655,2,0);       // Pool prüfen
  WHILE (Erx<=_rMultikey) and (VsP.Vorgangstyp=aVrg) and
    (VsP.Vorgangsnr=aNr) and (VsP.Vorgangspos1=aPos) and (VsP.Vorgangspos2=aPos2) do begin

    // Pool wurde schon benutzt???
    if (VsP.Menge.In.Ist<>0.0) or (VsP.Menge.In.Rest<>VsP.Menge.In.Soll) or
        (VsP.Menge.Out.Ist<>0.0) or (VsP.Menge.Out.Rest<>VsP.Menge.Out.Soll) or
        ("VsP.Stück.Ist"<>0) or ("VsP.Stück.Rest"<>"VsP.Stück.Soll") or
        (VsP.Gewicht.Ist<>0.0) or (VsP.Gewicht.Rest<>VsP.Gewicht.Soll) then begin
      TRANSBRK;
      RETURN false;
    end;

    if (Pool2Ablage(aTyp)<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecRead(655,2,_recNext);
  END;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  DelMatAusPool       +ERR
//
//========================================================================
sub DelMatAusPool(aMat : int) : logic;
local begin
  Erx : int;
end;
begin DoLogProc;

  RecBufClear(655);
  VsP.Materialnr      # aMat;

  TRANSON;

  Erx # RecRead(655,5,0);       // Pool prüfen
  WHILE (Erx<=_rMultikey) and (VsP.MaterialNr=aMat) do begin

    // Pool wurde schon benutzt???
    if (VsP.Menge.In.Ist<>0.0) or (VsP.Menge.In.Rest<>VsP.Menge.In.Soll) or
        (VsP.Menge.Out.Ist<>0.0) or (VsP.Menge.Out.Rest<>VsP.Menge.Out.Soll) or
        ("VsP.Stück.Ist"<>0) or ("VsP.Stück.Rest"<>"VsP.Stück.Soll") or
        (VsP.Gewicht.Ist<>0.0) or (VsP.Gewicht.Rest<>VsP.Gewicht.Soll) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RekDelete(655,0,'AUTO');
    if (Erx<>_rOK) then begin
      TRANSBRK;
      RETURN false;
    end;

    Erx # RecRead(655,5,0);
  END;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  LfsPos_Verbuchen   +ERR
//
//========================================================================
sub LfsPos_Verbuchen();
local begin
  Erx : int;
end;
begin DoLogProc;

//    WHILE (Erx<=_rMultikey) and (VsP.Materialnr=Mat.Nummer) do begin
//      if (VsP.Vorgangstyp=c_VSPTyp_Auf) and (LFS.P.zuBA.Nummer=0) then begin
//        if (VsP.Vorgangsnr=Lfs.P.Auftragsnr) and (VsP.VorgangsNr
//        VsP.Vorgangspos1
//      end;
//      Erx # RecRead(655,5,_RecNext);
//    END;

  RecBufClear(655);
  VsP.Materialnr # Mat.Nummer;
  Erx # RecRead(655,5,0);   // Versandpool loopen
  if (Erx<=_rMultikey) and (VsP.Materialnr=Mat.Nummer) then begin

    RecRead(655,1,_recLock);
    VsP.Menge.In.Ist      # VsP.Menge.In.Ist + Lfs.P.Menge.Einsatz;
    VsP.Menge.Out.Ist     # VsP.Menge.Out.Ist + Lfs.P.Menge;
    "VsP.Stück.Ist"       # "VsP.Stück.Ist" + "Lfs.P.Stück";
    VsP.Gewicht.Ist       # VsP.Gewicht.Ist + Lfs.P.Gewicht.Netto;
    RekReplace(655,0,'AUTO');


    // Pool erledigt?
    if (VsP.Menge.In.Ist >= VsP.Menge.In.Soll) and
      (VsP.Menge.Out.Ist >= VsP.Menge.Out.Soll) and
      ("VsP.Stück.Ist" >= "VsP.Stück.Soll") and
      (VsP.Gewicht.Ist >= VsP.Gewicht.Soll) then begin

      Pool2Ablage('MAN');
    end;

  end;

end;


//========================================================================
//  ErzeugePoolZumVersand   +ERR
//
//========================================================================
sub ErzeugePoolZumVersand() : logic;
local begin
  Erx           : int;
  vOK       : logic;
  vBuf701   : int;
end;
begin DoLogProc;

  // nur VERSAND kann Pool generieren
  if (BAG.P.Aktion<>c_BAG_Versand) then RETURN true;

  TRANSON;

  // VSP anlegen für Input ************************************************
  Erx # RecLink(701,702,2,_recFirst);     // Input loopen
  WHILE (Erx<=_rLockeD) do begin

    // Weiterbearbeitungen überspringen
    if ("BAG.IO.LöschenYN") then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
    if (BAG.IO.BruderID<>0) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;

/*
    Erx # RecLink(703,701,10,_recFirst);  // nachFertigung holen
    if (Erx>_rLocked) then begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;
*/
    vOK # n;
    RecBufClear(655);
    VsP.Vorgangstyp     # c_VSPTyp_BAG;
    VsP.Vorgangsnr      # BAG.IO.Nummer;
    VsP.Vorgangspos1    # BAG.IO.ID;
    VsP.Vorgangspos2    # 0;

    if (BAG.IO.MaterialTyp=c_IO_BAG) then begin
      vOK # y;
    end
    else if (BAG.IO.MaterialTyp=c_IO_VSB) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID=0)) then begin
      vOK # y;
    end
    else if (BAG.IO.MaterialTyp=c_IO_VSB) or
      ((BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID<>0)) then begin
      vOK # y;
    end
    else if (BAG.IO.MaterialTyp=c_IO_ART) and (BAG.IO.BruderID=0) then begin
todo('ARTIKEL');
    end
    else begin
      Erx # RecLink(701,702,2,_recNext);
      CYCLE;
    end;


    if (vOK) then begin
      vOK # BAGInput2Pool();
      if (vOK=false) then begin
        TRANSBRK;
        RETURN false;
      end;
    end;


    Erx # RecLink(701,702,2,_recNext);
  END; // Input loopen



  // im Pool nach gelöschten Einträgen suchen...
  RecBufClear(655);
  VsP.Vorgangstyp     # c_VSPTyp_BAG;
  VsP.Vorgangsnr      # BAG.P.Nummer;
  VsP.Vorgangspos1    # 0;
  VsP.Vorgangspos2    # 0;
  Erx # RecRead(655,2,0);       // Pool prüfen
  WHILE (Erx<=_rNoKey) and (VsP.Vorgangstyp=c_VSPTyp_BAG) and (VsP.Vorgangsnr=BAG.P.Nummer) do begin
    Erx # RecLink(701,655,8,_recFirst);   // BA-Input holen
    if (Erx<=_rLocked) then begin
      vOK # n;
      if ("BAG.IO.LöschenYN") then vOK # y;
      if (BAG.IO.NachPosition=BAG.P.Position) and ("BAG.P.Löschmarker"<>'') then vOK # y;
      if (BAG.IO.NachPosition=0) then vOK # Y;

      if (vOK) then begin
        // Material aus Pool löschen...
        if (VsP_Data:DelPool(c_VSPTyp_BAG, BAG.IO.Nummer, BAG.IO.ID, 0, 'AUTO')=false) then begin
          TRANSBRK;
          RETURN false;
        end;
      end;
    end;

    Erx # RecRead(655,2,_recNext);
  END;

  TRANSOFF;

  RETURN true;
end;


//========================================================================
//  NummPaketDaten  +ERR
//========================================================================
sub NimmPaketDaten(aPak : int) : int;
local begin
  Erx : int;
end;
begin
  if (aPak=0) then RETURN -1;

  // Paket holen
  if (Pak.Nummer<>aPak) then begin
    Pak.Nummer # aPak;
    Erx # RecRead(280,1,0);
    if (Erx>_rLocked) then begin
      Error(655200,'');
      RETURN -1;
    end;
  end;
  
  VsP.Paketnr # aPak;
  Erx # RecRead(655,10,_recTest);
  // Paket ist schon eingetragen? -> ENDE mit OK
  if (Erx<=_rMultikey) then begin
    Erx # RecRead(655,10,0);
    RETURN VsP.Nummer;
  end;

  // Mengen setzen...
  VsP.Menge.In.Soll     # Max(Pak.Gewicht, Pak.Inhalt.Brutto);
  "VsP.Stück.Soll"      # 1;
  VsP.Gewicht.Soll      # VsP.Menge.In.Soll;
  VsP.Materialnr        # 0;
  VsP.Paketnr           # aPak;
  
  // 2022-11-30 AH
  if (Vsp.Vorgangstyp=c_VSPTyp_mat) then begin
    VsP.Vorgangstyp       # c_VSPTyp_Pak;
    VsP.Vorgangsnr        # aPak;
  end;

  RETURN 0;
  
end;


//========================================================================
//  SavePool    +ERR
//              RETURN Poolnummer
//========================================================================
sub SavePool() : int;
local begin
  Erx           : int;
  vBuf101     : int;
  vBuf200     : int;
  vBuf400     : int;
  v401        : int;
  vPak        : int;
end;
begin DoLogProc;

  if (VsP.Materialnr=0) then begin
    Error(655200,'');
    RETURN 0;
  end;
  Erx # RecRead(655,5,_recTest);
  if (Erx<=_rMultikey) then begin
    // EXISITERT BEREITS!!!
    Error(655201,AInt(VsP.Materialnr));
    RETURN 0;
  end;

/*    2022-11-07  AH
  vBuf200 # RecBufCreate(200);
  Erx # RecLink(vBuf200, 655,2,_recFirst);    // Material holen
  if (Erx>_rLocked) then begin
    RecBufDestroy(vBuf200);
    Error(655200,AInt(VsP.Materialnr));
    RETURN 0;
  end;
  if (vBuf200->"Mat.Löschmarker"='*') then begin
    RecBufDestroy(vBuf200);
    Error(655202,AInt(VsP.Materialnr));
    RETURN 0;
  end;
*/
  if (Mat.Nummer<>VsP.Materialnr) then begin
    Erx # RecLink(200, 655,2,_recFirst);    // Material holen
    if (Erx>_rLocked) then begin
      Error(655200,AInt(VsP.Materialnr));
      RETURN 0;
    end;
  end;
  if ("Mat.Löschmarker"='*') then begin
    Error(655202,AInt(VsP.Materialnr));
    RETURN 0;
  end;
  vBuf200 # RecBufCreate(200);
  RecbufCopy(200,vBuf200);


  // Mengen setzen...
  // 25.04.2022 AH: alles mit vBuf200
  VsP.MEH.In            # 'kg';
  VsP.MEH.Out           # 'kg';
  VsP.Menge.In.Soll     # vBuf200->Mat.Bestand.Gew;
  "VsP.Stück.Soll"      # vBuf200->Mat.Bestand.Stk;
  VsP.Gewicht.Soll      # vBuf200->Mat.Gewicht.Brutto; // Mat.Bestand.Gew; 08.11.2021 AH
  if (VsP.Gewicht.Soll=0.0) then VsP.Gewicht.Soll # vBuf200->Mat.Bestand.Gew;

  // Startdaten setzen...
  VsP.Auftragsnr        # vBuf200->Mat.Auftragsnr;
  VsP.AuftragsPos       # vBuf200->Mat.AuftragsPos;
  Vsp.AuftragsKundennr  # vBuf200->Mat.KommKundennr;
  VsP.AuftragsKdSW      # vBuf200->Mat.KommKundenSWort;
  VsP.Start.Adresse     # vBuf200->Mat.Lageradresse;
  VsP.Start.Anschrift   # vBuf200->Mat.Lageranschrift;
  VsP.Start.Lagerplatz  # vBuf200->Mat.Lagerplatz;
  VsP.Start.Tour        # '';
/*
  if (Set.Installname='HWN') then begin // 2022-12-13 AH
debugx('HACK');
    if (vBuf200->Mat.MEH<>'kg') then begin
      VsP.MEH.In            # vBuf200->Mat.MEH;
      VsP.MEH.Out           # vBuf200->Mat.MEH;
      VsP.Menge.In.Soll     # vBuf200->Mat.Bestand.Menge;
    end;
  end;
*/

  // 26.04.2022 AH: PAKETE EINZELN
  if (vBuf200->Mat.Paketnr<>0) then begin
    vPak # NimmPaketDaten(vBuf200->Mat.Paketnr);
    // Fehler?
    if (vPak<0) then begin
      RecBufDestroy(vBuf200);
      RETURN 0;
    end;
  end;
  
  VsP.Menge.In.Rest     # VsP.Menge.In.Soll;
  "VsP.Stück.Rest"      # "VsP.Stück.Soll";
  VsP.Menge.Out.Soll    # Vsp.Menge.In.Soll;
  VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll;
  VsP.Gewicht.Rest      # VsP.Gewicht.Soll;

  RecBufDestroy(vBuf200);

  if (vPak=0) then begin
    // Zieldaten setzen...
    vBuf101 # RecBufCreate(101);
    Erx # RecLink(vBuf101, 655, 5, _recFirst);    // Zielanschrift holen
    if (Erx>_rlocked) then begin
      RecBufDestroy(vBuf101);
      Error(655101,AInt(VsP.Ziel.Adresse)+'/'+aInt(VsP.Ziel.Anschrift));
      RETURN 0;
    end;
    VsP.Ziel.Lagerplatz   # '';
    VsP.Ziel.Tour         # vBuf101->Adr.A.Tour;
    RecBufDestroy(vBuf101);

    // 10.12.2012 AI: ggf. Kommission holen
    if (VsP.Termin.MinDat=0.0.0) or (VsP.Termin.MaxDat=0.0.0) then begin
      Erx # RekLinkB(v401,655,10,_recFirst);    // Auftragspos holen
      if (Erx<=_rLocked) then begin
        if (VsP.Termin.MinDat=0.0.0) then VsP.Termin.MinDat # v401->Auf.P.Termin1Wunsch;
        if (VsP.Termin.MaxDat=0.0.0) then VsP.Termin.MaxDat # v401->Auf.P.Termin1Wunsch;
      end;
    end;


    // Nummernvergabe...
    VsP.Nummer # Lib_Nummern:ReadNummer('Versandpool');
    if (VsP.Nummer<>0) then Lib_Nummern:SaveNummer()
    else begin
      Error(655001,'');
      RETURN 0;
    end;
    Erx # RekInsert(655,_recUnlock,'AUTO');
    if (erx<>_rOK) then begin
      Error(655000,'');
      RETURN 0;
    end;
  end;  // einzelnes Material ODER NEUES PAKET
  
  if (Mat.Status<>c_Status_VSB) then begin
    Erx # RecRead(200,1,_recLock);
    Mat_Data:SetStatus(c_Status_Versand);
    if (Erx=_rOK) then begin    // 2022-11-07 AH
      Erx # Mat_Data:Replace(_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        RecBufDestroy(vBuf200);
        Error(655000,'');
        RETURN 0;
      end;
    end;
  end;


  RETURN VsP.Nummer;
end;


//========================================================================
//  xMat2Pool
//
//========================================================================
/*
sub xMat2Pool() : logic
local begin
  vPool   : int;
  vZusatz : alpha;
  vDat1   : date;
  vDat2   : date;
end;
begin
  vPool # VsP_Data:Mat2Pool(Mat.Nummer, c_VSPTyp_EIN, Mat.Einkaufsnr, Mat.Einkaufspos, 0);
  if (vPool=0) then begin
    Error(655000,'');
    RETURN false;
  end;

  vZusatz     # '';
  vDat1       # today;
  vDat2       # today;

  // weitere Daten nachtragen...
  RecRead(655,1,_recLock);
  VsP.Termin.MinDat # vDat1;
  VsP.Termin.MaxDat # vDat2;
  VsP.Termin.Zusatz # vZusatz;
  RekReplace(655,_recUnlock,'AUTO');

  // Wareneingang auf Versand setzen...
  RecRead(506,1,_recLock);
  Ein.E.VersandPoolnr # vPool;
  Rekreplace(506,_RecUnlock,'AUTO');
  if (Erx<>_rOK) then begin
    Error(655000,'');
    RETURN false;
  end;

  RETURN true;
end;
*/

//========================================================================
//  Auf2Pool    +ERR
//              RETURN Poolnummer
//========================================================================
sub Auf2Pool() : int;
local begin
  Erx           : int;
  vBuf101     : int;
  vDat1       : date;
  vDat2       : date;
end;
begin DoLogProc;

/***
  Auf.P.Nummer    # aNr;
  Auf.p.Position  # aPos1;
  Erx # RecRead(401,1,0);
  if (Erx>_rLockeD) then RETURN 0;

  Erx # RecLink(400,401,3,_recFirst);   // Kopf holen
  if (Erx>_rLocked) then begin
    Error(655400,AInt(aNr));
    RETURN 0;
  end;

  // Zeitfenster errechnen...
  if (Auf.P.TerminZusage<>0.0.0) then begin
    vDat1       # Auf.P.TerminZusage;
    vDat2       # vDat1;
    Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.TerminZ.Zahl, var Auf.P.TerminZ.Jahr, var vDat2);
  end
  else begin
    vDat1       # Auf.P.Termin1Wunsch;
    vDat2       # vDat1;
    if (Auf.P.Termin2Wunsch<>0.0.0) then begin
      vDat2     # Auf.P.Termin2Wunsch;
      Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.Termin2W.Zahl, var Auf.P.Termin2W.Jahr, var vDat2);
    end
    else begin
      Lib_Berechnungen:EndDatum_aus_ZahlJahr(Auf.P.Termin1W.Art, var Auf.P.Termin1W.Zahl, var Auf.P.Termin1W.Jahr, var vDat2);
    end;
  end;


  RecBufClear(655);
  VsP.Vorgangstyp       # c_VSPTyp_Auf;
  VsP.Vorgangsnr        # aNr;
  VsP.VorgangsPos1      # aPos1;
  VsP.VorgangsPos2      # aPos2;
  VsP.Materialnr        # 0;

  // Mengen setzen...
  VsP.Menge.In.Soll     # aGew;
  VsP.Menge.In.Rest     # VsP.Menge.In.Soll;
  VsP.MEH.In            # 'kg';
  VsP.Menge.Out.Soll    # aGew;
  VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll;
  VsP.MEH.Out           # 'kg';
  "VsP.Stück.Soll"      # aStk;
  "VsP.Stück.Rest"      # "VsP.Stück.Soll";
  VsP.Gewicht.Soll      # aGew;
  VsP.Gewicht.Rest      # VsP.Gewicht.Soll;

  // Startdaten setzen...
  VsP.Auftragsnr        # aNr;
  VsP.AuftragsPos       # aPos1;
  Vsp.AuftragsKundennr  # Auf.Kundennr;
  VsP.Start.Adresse     # Auf.Lieferanschrift;
  VsP.Start.Anschrift   # Auf.Lieferadresse;
  VsP.Start.Lagerplatz  # '';
  VsP.Start.Tour        # '';

  // Zieldaten setzen...
  VsP.Termin.MinDat     # vDat1;
  VsP.Termin.MaxDat     # vDat2;
  VsP.Termin.Zusatz     # Auf.P.Termin.Zusatz;
  VsP.Ziel.Adresse      # Auf.Lieferadresse;
  VsP.Ziel.Anschrift    # Auf.Lieferanschrift;
  vBuf101 # RecBufCreate(101);
  Erx # RecLink(vBuf101, 655, 5, _recFirst);    // Zielanschrift holen
  if (Erx>_rlocked) then begin
    RecBufDestroy(vBuf101);
    Error(655101,AInt(Auf.Lieferadresse)+'/'+aInt(Auf.Lieferanschrift));
    RETURN 0;
  end;
  VsP.Ziel.Lagerplatz   # '';
  VsP.Ziel.Tour         # vBuf101->Adr.A.Tour;

  RecBufDestroy(vBuf101);
***/

  Erx # RecLink(400,401,3,_recFirst);   // AufKopf holen
  if (Erx>_rLocked) then begin
    Error(655400,AInt(Auf.P.Nummer));
    RETURN 0;
  end;

  VsP.Vorgangstyp       # c_VSPTyp_Auf;
  VsP.Vorgangsnr        # Auf.P.Nummer;
  VsP.VorgangsPos1      # Auf.P.Position;
  VsP.VorgangsPos2      # 0;
  VsP.Materialnr        # 0;

  // Mengen setzen...
  VsP.Gewicht.Rest      # VsP.Gewicht.Soll;
  "VsP.Stück.Rest"      # "VsP.Stück.Soll";
  VsP.Menge.In.Soll     # VsP.Gewicht.Soll;
  VsP.Menge.In.Rest     # VsP.Menge.In.Soll;
  VsP.MEH.In            # 'kg';
  VsP.Menge.Out.Soll    # VsP.Menge.In.Soll;
  VsP.Menge.Out.Rest    # VsP.Menge.Out.Soll;
  VsP.MEH.Out           # 'kg';
  //Startdaten setzen...
  VsP.Auftragsnr        # Auf.P.Nummer;
  VsP.AuftragsPos       # Auf.P.Position;
  Vsp.AuftragsKundennr  # Auf.P.Kundennr;
  VsP.AuftragsKdSW      # Auf.P.KundenSW;
//  VsP.Start.Adresse     # Auf.Lieferanschrift;
//  VsP.Start.Anschrift   # Auf.Lieferadresse;
  VsP.Start.Lagerplatz  # '';
  VsP.Start.Tour        # '';

  // Zieldaten setzen...
//  VsP.Termin.MinDat     # vDat1;
//  VsP.Termin.MaxDat     # vDat2;
//  VsP.Termin.Zusatz     # Auf.P.Termin.Zusatz;
  VsP.Ziel.Adresse      # Auf.Lieferadresse;
  VsP.Ziel.Anschrift    # Auf.Lieferanschrift;
  vBuf101 # RecBufCreate(101);
  Erx # RecLink(vBuf101, 655, 5, _recFirst);    // Zielanschrift holen
  if (Erx>_rlocked) then begin
    RecBufDestroy(vBuf101);
    Error(655101,AInt(Auf.Lieferadresse)+'/'+aInt(Auf.Lieferanschrift));
    RETURN 0;
  end;
  VsP.Ziel.Lagerplatz   # '';
  VsP.Ziel.Tour         # vBuf101->Adr.A.Tour;

  RecBufDestroy(vBuf101);


  // Nummernvergabe...
  VsP.Nummer # Lib_Nummern:ReadNummer('Versandpool');
  if (VsP.Nummer<>0) then Lib_Nummern:SaveNummer()
  else begin
    Error(655001,'');
    RETURN 0;
  end;
  Erx # RekInsert(655,_recUnlock,'AUTO');
  if (erx<>_rOK) then begin
    Error(655000,'');
    RETURN 0;
  end;

  RETURN VsP.Nummer;
end;


//========================================================================
//  ExistsPaket
//
//========================================================================
sub ExistsPaket(aPak : int) : logic;
local begin
  Erx           : int;
end;
begin DoLogProc;

  VsP.Paketnr # aPak;
  Erx # RecRead(655,10,0);
  if (Erx<=_rMultikey) then RETURN true;

  "VsP~Paketnr" # aPak;
  Erx # RecRead(656,10,0);
  if (Erx>_rMultikey) then RETURN false;
  
  RecBufCopy(656,655);

  RETURN true;
end;


//========================================================================