@A+
//===== Business-Control =================================================
//
//  Prozedur  BA1_F_ArtPrd_Data
//                    OHNE E_R_G
//  Info
//
//
//  31.08.2012  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    sub RecalcEinsatz(aMenge : float);
//    sub Erzeuge701AusSL() : logic;
//    sub CopySLToInput() : logic;
//    sub Verbuchen(var aEKSum : float) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_Aktionen

//========================================================================
//  RecalcEinsatzToDL
//
//========================================================================
sub RecalcEinsatzToDL(
  aMenge  : float;
  aDL     : int;) : logic;
local begin
  Erx     : int;
  vFak    : float;
  vCharge : alpha;
  vM      : float;
  vHdl    : int;
end;
begin

  // Stücklisten anpassen...

  WinLstDatLineRemove(aDL, _WinLstDatLineAll); // ALLE löschen

  if (BAG.F.Menge<>0.0) then
    vFak  # aMenge / BAG.F.Menge;

  FOR Erx # RecLink(701,702,2,_recFirst) // Input loopen
  LOOP Erx # RecLink(701,702,2,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.BruderID<>0) then CYCLE;

    vCharge # '';
    if (BAG.IO.Materialtyp=c_IO_Art) then begin

      Erx # RecLink(250,701,8,_recFirst); // Artikel holen
      if (Erx>_rLocked) then CYCLE;

      vCharge # BAG.IO.Charge;
      // bei allgemeinan Chargen, ggf. die eine Summencharge finden
      if (vCharge='') then begin
        // das klappt nicht bei Chargenartikeln!
        if ("Art.ChargenführungYN"=false) then begin
          if (Art_Data:ReadChargeByPara(BAG.IO.Lageradresse, BAG.IO.Lageranschr, BAG.IO.Art.Zustand)) then
            vCharge # Art.C.Charge.Intern;
        end;
      end;

    end;  // Attikel

    vM # Rnd(BAG.IO.Plan.Out.Meng * vFak, Set.Stellen.Menge);

    aDL->WinLstDatLineAdd(BAG.IO.Artikelnr,_WinLstDatLineLast);
    aDL->WinLstCellSet(vCharge,2);
    aDL->WinLstCellSet(vM,3);       // Soll
    if (vCharge<>'') then
      aDL->WinLstCellSet(vM,4);     // Ist
    aDL->WinLstCellSet(BAG.IO.MEH.In,5);
//    vHdl->WinLstCellSet('',6);    // Bemerkung

/*
    BAG.FM.B.Nummer       # BAG.FM.Nummer;
    BAG.FM.B.Position     # BAG.FM.Position;
    BAG.FM.B.Fertigung    # BAG.FM.Fertigung;
    BAG.FM.B.Fertigmeld   # BAG.FM.Fertigmeldung;
    BAG.FM.B.Artikelnr    # BAG.IO.Artikelnr;
    BAG.FM.B.Art.Adresse  # BAG.IO.Lageradresse;
    BAG.FM.B.Art.Anschr   # BAG.IO.Lageranschr;
    BAG.FM.B.Art.Charge   # vCharge;
    BAG.FM.B.Bemerkung    # '';
    BAG.FM.B.MEH          # BAG.IO.MEH.In;
    BAG.FM.B.Menge        # Rnd(BAG.IO.Plan.Out.Meng * vFak, Set.Stellen.Menge);
    REPEAT
      BAG.FM.B.lfdNr       # vLfd;
      Erx # Rekinsert(708,0,'MAN');
      if (Erx<>_rOK) then vLfd # vLfd + 1;
    UNTIL (Erx=_rOK);
*/
  END;

  RETURN true;
end;


//========================================================================
//  EinsatzEdit
//
//========================================================================
sub EinsatzEdit(
  aDL   : int;
  aLine : int);
local begin
  vHdl  : int;
end;
begin
  RecBufClear(708);

  if (aLine <= 0) then
    aLine # aDl->wpCurrentInt;

  // Daten zum Editieren aus DL-Zeile lesen und an Puffer übergeben
  aDl->WinLstCellGet(BAG.FM.B.Artikelnr,  1,aLine);
  aDl->WinLstCellGet(BAG.FM.B.Art.Charge, 2,aLine);
  // 3 = Menge Soll
  aDl->WinLstCellGet(BAG.FM.B.Menge,      4,aLine);
  aDl->WinLstCellGet(BAG.FM.B.MEH,        5,aLine);
  aDl->WinLstCellGet(BAG.FM.B.Bemerkung,  6,aLine);

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.FM.ArtPrd.B.Maske',here+':AusMaske',false, true,'');
  vHdl # Winsearch(gMDI,'lb.Datalist');
  if (vHdl <> 0) then begin
    vHdl->wpcustom  # aint(aDL);
    vHdl->wpcaption # aint(aLine);
  end else begin

    debugstamp('EinsatzEdit: lb.Datalist nicht gefunden');

  end;

  // gleich in Neuanlage....
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
//  Mode # c_ModeEdit;
  Mode # c_ModeNew;


  w_Command # '->POS';
  Lib_GuiCom:RunChildWindow(gMDI);

  aDL->wpcustom # 'edit';
end;


//========================================================================
//  EinsatzDel
//
//========================================================================
sub EinsatzDel(
  aDL   : int;
  aLine : int);
begin
  aDL->wpcustom # 'del';
  aDL->WinLstDatLineRemove(aLine);
end;


//========================================================================
//  EinsatzIns
//
//========================================================================
sub EinsatzIns(
  aDL   : int);
local begin
  vHdl  : int;
  vDl, vLine : int;

end;
begin
  RecBufClear(708);

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'BA1.FM.ArtPrd.B.Maske',here+':AusMaske');
  // gleich in Neuanlage....
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vHdl # Winsearch(gMDI,'lb.Datalist');
  if (vHdl <> 0) then begin
    vHdl->wpcustom  # aint(aDL);
    vHdl->wpcaption # '0';
  end else begin
    debugstamp('EinsatzIns: lb.Datalist nicht gefunden');
  end;

  Mode # c_ModeNew;
  w_Command # '->POS';
  Lib_GuiCom:RunChildWindow(gMDI);

  aDL->wpcustom # 'ins';
end;


//========================================================================
//========================================================================
sub AusMaske();
local begin
  vHdl : int;
  vDl  : int;
  vLine : int;
end
begin
  gSelected # 0;
end;


//========================================================================
//  Erzeuge701ausSL
//
//========================================================================
sub Erzeuge701AusSL() : logic;
local begin
  Erx     : int;
  vMenge  : float;
  v250    : int;
end;
begin

  // Menge multiplizieren
  vMenge # BAG.F.Menge * Art.SL.Menge;


  v250 # RekSave(250);

  RecBufClear(701);
  BAG.IO.Nummer         # BAG.P.Nummer;
  BAG.IO.ID             # 1;
  BAG.IO.NachBAG        # BAG.P.Nummer;
  BAG.IO.NachPosition   # BAG.P.Position;
  BAG.IO.Materialtyp    # c_IO_Art;
  BAG.IO.Artikelnr      # Art.SL.Input.ArtNr;
  Erx # RecLink(250,701,8,_recFirst);    // EinsatzArtikel holen
  if (Erx>_rLocked) then begin
    RekRestore(v250);
    RETURN false;
  end;

  BAG.IO.Bemerkung      # Art.SL.Bemerkung;

  BAG.IO.Lageradresse   # BAG.P.Zieladresse;
  BAG.IO.Lageranschr    # BAG.P.Zielanschrift;

  BAG.IO.MEH.Out        # Art.SL.MEH;
  BAG.IO.MEH.In         # Art.SL.MEH;

  BAG.IO.Warengruppe    # Art.Warengruppe;
  "BAG.IO.Güte"         # "Art.Güte";
  BAG.IO.Dicke          # Art.Dicke;
  BAG.IO.Breite         # Art.Breite;
  "BAG.IO.Länge"        # "Art.Länge";
  BAG.IO.Dickentol      # Art.Dickentol;
  BAG.IO.Breitentol     # Art.Breitentol;
  "BAG.IO.Längentol"    # "Art.Längentol";
  BAG.IO.AutoTeilungYN  # n;

  BAG.IO.Plan.In.Menge # Rnd(vMenge, Set.Stellen.Menge);
  if (BAG.IO.MEH.IN='Stk') then
    BAG.IO.Plan.In.Stk  # cnvif(BAG.IO.Plan.In.Menge)
  else if (BAG.IO.MEH.IN='kg') then
    BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.Menge, Set.Stellen.Gewicht)
  else if (BAG.IO.MEH.IN='t') then
    BAG.IO.Plan.In.GewN   # Rnd(BAG.IO.Plan.In.Menge / 1000.0, Set.Stellen.Gewicht)
  BAG.IO.Plan.In.GewB   # BAG.IO.Plan.In.GewN;

  BAG.IO.Plan.Out.Meng  # BAG.IO.Plan.In.Menge;
  BAG.IO.Plan.Out.Stk   # BAG.IO.Plan.In.Stk;
  BAG.IO.Plan.Out.GewN  # BAG.IO.Plan.In.GewN;
  BAG.IO.Plan.Out.GewB  # BAG.IO.Plan.In.GewB;

  BAG.IO.Ist.In.Menge   # BAG.IO.Plan.In.Menge;
  BAG.IO.Ist.In.Stk     # BAG.IO.Plan.In.Stk;
  BAG.IO.Ist.In.GewN    # BAG.IO.Plan.In.GewN;
  BAG.IO.Ist.In.GewB    # BAG.IO.Plan.In.GewB;

  REPEAT
    BAG.IO.UrsprungsID    # BAG.IO.ID;
    Erx # BA1_IO_Data:Insert(0,'AUTO');
    if (erx<>_rOK) then BAG.IO.ID # BAG.IO.ID + 1;
  UNTIL (erx=_rOK);

  RekRestore(v250);

  if (BA1_F_Data:UpdateOutput(701,n)=false) then begin
    TRANSBRK;
    ERROROUTPUT;  // 01.07.2019
    RETURN false;
  end;

  RETURN true; // alles IO

end;


//========================================================================
// CopySLToInput
//
//========================================================================
sub CopySLToInput() : logic;
local begin
  Erx : int;
end;
begin

  Erx # RecLink(250,703,13,_RecFirst);      // Artikel holen
  if (Erx<=_rLocked) then begin
    Erx # RecLink(255,250,22,_recFirst);    // aktive SL holen
    if (Erx>_rLocked) then begin
      Error(250011,'');
      RETURN false;
    end;
    FOR Erx # RecLink(256,255,2,_RecFirst)
    LOOP Erx # RecLink(256,255,2,_RecNext)
    WHILE (Erx<=_rLocked) do begin
      if (Art.SL.Typ=250) then begin
        if (Erzeuge701AusSL()=falsE) then begin
          Error(123123,'');
          RETURN false;
        end;
      end;
    END;

    Erx # RecRead(703,1,_recLock);
    BAG.F.Bemerkung # StrCut(BAG.F.Bemerkung + Art.SLK.Name,1,64);
    RekReplace(703,_Recunlock,'MAN');

  end;

  RETURN true;
end;


//========================================================================
//  Verbuchen
//
//========================================================================
sub Verbuchen(var aEKSum : float) : logic;
local begin
  Erx     : int;
  vStk    : int;
  vGew    : float;
  vM      : float;
  vOk     : logic;
  vEKSum  : float;
  v701    : int;
end;
begin

  v701 # Reksave(701);

  Erx # RecLink(708,707,12,_recFirst);  // BAG-Bewegungen loopen
  WHILE (Erx<=_rLocked) do begin

    if (BAG.FM.B.Art.Charge='') or (BAG.FM.B.Art.Adresse=0) then begin
      RekRestore(v701);
      RETURN false;
    end;

    Erx # RecLink(252,708,2,_recFirst); // Charge holen
    if (Erx>_rLocked) then begin
      RekRestore(v701);
      RETURN false;
    end;

    Erx # RecLink(250,252,1,_recFirst); // Artikel holen
    if (Erx>_rLocked) then begin
      RekRestore(v701);
      RETURN false;
    end;

    vStk  # cnvif(Lib_Einheiten:WandleMEH(250, 0, 0.0, BAG.FM.B.Menge, BAG.FM.B.MEH, 'Stk'))
    vM    # BAG.FM.B.Menge;
    vGew  # Rnd(Lib_Einheiten:WandleMEH(252, 0, 0.0, BAG.FM.B.Menge, BAG.FM.B.MEH, 'kg'), Set.Stellen.Gewicht);

    // passenden Input suchen...
    FOR Erx # RecLink(701,702,2,_RecFirst)
    LOOP Erx # RecLink(701,702,2,_Recnext)
    WHILE (Erx<=_rLocked) do begin
      if (BAG.IO.Artikelnr=BAG.FM.B.Artikelnr) then BREAK;
    END;
    // ggf. Reservierung mindern
    if (Erx<=_rLocked) then begin
      Art_Data:Reservierung(BAG.IO.Artikelnr, BAG.IO.LagerAdresse, BAG.IO.Lageranschr, BAG.IO.Charge, BAG.IO.Art.Zustand, c_Akt_BAInput, BAG.IO.Nummer, BAG.IO.ID, 0, - BAG.FM.B.Menge, - vStk, 0);
      end
    else begin
      RecBufClear(701);
    end;


    // Bewegung buchen...
    RecBufClear(253);
    Art.J.Datum           # BAG.FM.Datum;
    Art.J.Bemerkung       # c_Akt_BA+' '+AInt(BAG.FM.Nummer)+'/'+AInt(BAG.FM.Position)+'/'+aint(BAG.FM.Fertigung)+'/'+aint(BAG.FM.Fertigmeldung);
    "Art.J.Stückzahl"     # vStk;
    Art.J.Menge           # (-1.0) * BAG.FM.B.Menge;
Art.J.Adressnr    # BAG.FM.B.Art.Adresse;
Art.J.Anschriftnr # BAG.FM.B.Art.Anschr;
debugx('J:'+aint(art.j.adressnr));
    "Art.J.Trägertyp"     # c_Akt_BA;
    "Art.J.Trägernummer1" # BAG.FM.Nummer;
    "Art.J.Trägernummer2" # BAG.FM.Position;
    "Art.J.Trägernummer3" # BAG.FM.Fertigung;
    vOK # Art_Data:Bewegung(0.0, 0.0);
    if (vOK=false) then begin
      RekRestore(v701);
      RETURN false;
    end;
    if (Art.PEH=0) then Art.PEH # 1;
    if (BAG.FM.B.MEH=Art.MEH) then
      vEKSum # BAG.FM.B.Menge * Art.C.EKDurchschnitt / cnvfi(Art.PEH);

    if (BAG.FM.B.Artikelnr=BAG.IO.Artikelnr) then begin
      RecRead(701,1,_recLock);
      BAG.IO.Ist.Out.Stk    # BAG.IO.Ist.Out.Stk + vStk;
      BAG.IO.Ist.Out.GewN   # BAG.IO.Ist.Out.GewB + vGew;
      BAG.IO.Ist.Out.GewB   # BAG.IO.Ist.Out.GewB + vGew;
      BAG.IO.Ist.Out.Menge  # BAG.IO.Ist.Out.Menge + vM;
      Erx # BA1_IO_Data:Replace(_recUnlock,'AUTO');
      if (erx<>_rOK) then begin
        RekRestore(v701);
        RETURN false;
      end;
    end;

    Erx # RecLink(708,707,12,_recNext);
  END;


  RekRestore(v701);

  aEKSum # vEKSum;
aeksum # 123.45;
  RETURN true;
end;


//========================================================================