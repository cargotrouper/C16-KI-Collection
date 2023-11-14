@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Laufzeit
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  18.01.2019  AH  Edit: "Automatisch" mit Resultat und ahctet auf "Plan.ManuellYN"
//  05.04.2022  AH  ERX
//
//  Subprozeduren
//    SUB Vorgabe(aCode : alpha; aKey1 : float; aKey2 : float) : logic;
//    SUB Automatisch(aMitAnzeige : logic) : logic;
//
//========================================================================
@I:Def_global
@I:Def_BAG

global Block begin
  block_name    : alpha;
  block_Breite  : float;
  block_Laenge  : float;
  block_gesL    : float;
  block_LTol    : float;
  block_Messer  : alpha;
end;

declare _Standard(aMitAnzeige   : logic)

//========================================================================
//  Vorgabe
//
//========================================================================
sub Vorgabe(aCode : alpha; aKey1 : float; aKey2 : float) : logic;
local begin
  vErx : int;
end;
begin
  RecBufClear(161);
  Rso.Tab.RessourceGrp  # Rso.Gruppe;
  Rso.Tab.RessourceNr   # Rso.Nummer;
  Rso.Tab.Code          # aCode;
  Rso.Tab.Key1          # aKey1;
  Rso.Tab.Key2          # aKey2;
  vErx # RecRead(161,1,0);
  if (vErx<>_rNoRec) and
    (Rso.Tab.RessourceGrp =Rso.Gruppe) and
    (Rso.Tab.RessourceNr  =Rso.Nummer) and
    (Rso.Tab.Code         =aCode) and
    (Rso.Tab.Key1         >=aKey1) then
    RETURN true;
  else
    RETURN false;
end;


//========================================================================
//  Automatisch
//      pro geladener Pos, TRUE
//========================================================================
sub Automatisch(
  aMitAnzeige   : logic;
  opt aReplace  : logic) : logic;
local begin
  vA            : alpha;
  v702          : int;
  vDauer        : float;
  vDauerPost    : float;
end;
begin
//todox('LAUFZEIT');

  if (BAG.P.Plan.ManuellYN) then RETURN false;

  // ohne anz, repl
  if (aMitAnzeige) then vA # 'Y'
  else vA # 'N';
  if (aReplace) then vA # vA + '|Y'
  else vA # vA + '|N';

  v702 # RekSave(702);
  if (RunAFX('BAG.Laufzeit.Automatik',vA)<>0) then begin
  end
  else begin
    _Standard(aMitAnzeige);
  end;
  
  if (aReplace) and
    ((v702->BAG.P.Plan.Dauer<>BAG.P.Plan.Dauer) or (v702->BAG.P.Plan.DauerPost<>BAG.P.Plan.DauerPost)) then begin
    vDauer      # BAG.P.Plan.Dauer;
    vDauerPost  # BAG.P.Plan.DauerPost;
    RecRead(702,1,_recLock);
    BAG.P.Plan.Dauer      # vDauer;
    BAG.P.Plan.DauerPost  # vDauerPost;
    BA1_P_Data:Replace(_recunlock,'AUTO');
  end;

  RETURN true;
  
// für Automatik könnte man nach jedem "UpdateOutput" eintragen:
// Laufzeitermittlung
//    BA1_Laufzeit:Automatisch(n,y);
end;


//========================================================================
//========================================================================
sub _Standard(aMitAnzeige   : logic)
local begin
  Erx         : int;
  vA          : alpha;
  vX          : float;
  vI          : int;
  vEinsatzStk : float;
  vEinsatzGew : float;
  vEinsatzD   : float;
  vEinsatzB   : float;

  vFertigStk  : float;
  vFertigGew  : float;
  vFertigPAK  : float;
  vAbsetzStk  : float;
  vAbsetzGew  : float;

  vtRuest     : float;
  vtLauf      : float;
  vtAbsetz    : float;

  vBlockList  : int;
  vBlock      : int;
  vBlockBonus : int;
  vMesVorher  : alpha;
  vLenVorher  : float;

  vBasis      : float;
  v702        : int;
end;
begin

  if (BAG.P.Ressource=0) or (BAG.P.Ressource.Grp=0) then RETURN;
  if (BAG.P.Aktion<>c_BAG_TAFEL) and (BAG.P.Aktion<>c_BAG_ABCOIL) then RETURN;

  Erx # RecLink(160,702,11,_RecFirst);  // Hauptressource holen
  if (Erx>_rLocked) then RETURN;

  if (Rso.autoLaufZeitYN=n) then RETURN;

  // Fertigungen durchlaufen & Blockliste bauen ****************************
  vBlocklist # CteOpen(_CteTreeCI);
  vA # '';
  Erx # RecLink(703,702,4,_RecFirst); // Fertigungen loopen
  WHILE (Erx<=_rLockeD) do begin

    if (BAG.F.Block='') or (BAG.F.AutomatischYN) then begin
      if (BAG.F.Block='') and (BAG.F.AutomatischYN) then begin
        vAbsetzStk # vAbsetzStk + cnvfi("BAG.F.Stückzahl");
        vAbsetzGew # vAbsetzGew + BAG.F.Gewicht;
      end;
      Erx # RecLink(703,702,4,_RecNext);
      CYCLE;
    end;

    if (BAG.F.Streifenanzahl<>0) then begin
      vX # CnvfI("BAG.F.Stückzahl") div cnvfi(BAG.F.Streifenanzahl);
      if (CnvfI("BAG.F.Stückzahl") % cnvfi(BAG.F.Streifenanzahl) >0.0) then
        vX # vX + 1.0;
      end
    else begin
      vX # 0.0;
    end;

    // neuen Block anlegen ??
    if (vBlockList->CteRead(_CteFirst | _CteSearch, 0, BAG.F.Block)=0) then begin
      vBlock # CteOpen(_CteItem);
      vBlockBonus # VarAllocate(Block);
      HdlLink(vBlock,vBlockBonus);

      Block_name      # BAG.F.Block;
      Block_Breite    # BAG.F.Breite*cnvfi(BAG.F.Streifenanzahl);
      Block_Laenge    # "BAG.F.Länge";
      Block_gesL      # Rnd(vX * block_Laenge,2);
      Block_LTol      # "BAG.F.Längentol.Bis" - "BAG.F.Längentol.Von";
      Block_Messer    # '';
      FOR vI # 1 loop inc(vI) WHILE (vI<=BAG.F.Streifenanzahl) do
        Block_Messer    # Block_Messer + ANum(BAG.F.Breite,2)+'|';
      vBlock->spname  # BAG.F.Block;
      vBlockList->CteInsert(vBlock);
      end
    // Block existiert
    else begin
      vBlockBonus # HdlLink(vBlock);
      VarInstance(Block,vBlockBonus);

      Block_Breite    # Block_Breite + (BAG.F.Breite*cnvfi(BAG.F.Streifenanzahl));
      if ("BAG.F.Länge">Block_Laenge) then begin
        Block_Laenge    # "BAG.F.Länge";
        Block_gesL      # Rnd(vX * block_Laenge,2);
        Block_LTol      # "BAG.F.Längentol.Bis" - "BAG.F.Längentol.Von";
      end;
      FOR vI # 1 loop inc(vI) WHILE (vI<=BAG.F.Streifenanzahl) do
        Block_Messer    # Block_Messer + ANum(BAG.F.Breite,2)+'|';
    end;

    Erx # RecLink(703,702,4,_RecNext);
  END;




  // Output loopen *********************************************************
  Erx # RecLink(701,702,3,_RecFirst);
  WHILE (Erx<=_rLocked) do begin
    if (BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID<>0) then begin  // echte Zwischenverwiegungen übergehen
      Erx # RecLink(701,702,3,_RecNext);
      CYCLE;
    end;
    RecLink(703,701,3,_RecFirst);   // Fertigung holen

    if (BAG.F.Block<>'') or (BAG.F.AutomatischYN=n) then begin
      vFertigStk # vFertigStk + cnvfi(BAG.IO.Plan.OUT.Stk);
      vFertigGew # vFertigGew + BAG.IO.Plan.OUT.GewB;
    end;

    Erx # RecLink(701,702,3,_RecNext);
  END;


  vtRuest   # "Rso.t_Rüstbasis";
  vtLauf    # "Rso.t_Prodbasis";
  vtAbsetz  # "Rso.t_Absetzbasis";


  // Input loopen **********************************************************
  Erx # RecLink(701,702,2,_RecFirst);
  WHILE (Erx<=_rLocked) do begin

    if (BAG.IO.MaterialTyp=c_IO_Mat) and (BAG.IO.BruderID<>0) then begin  // echte Zwischenverwiegungen übergehen
      Erx # RecLink(701,702,2,_RecNext);
      CYCLE;
    end;
    vEinsatzStk # vEinsatzStk + cnvfi(BAG.IO.Plan.IN.Stk);
    vEinsatzGew # veinsatzGew + BAG.IO.Plan.In.GewB;
    vEinsatzD   # BAG.IO.Dicke;
    vEinsatzB   # BAG.IO.Breite;

    Erx # RecLink(701,702,2,_RecNext);
  END;



  // Basisgeschwindigkeit holen
  vBasis # 0.0;
  if (Vorgabe('TAF_B_ZEIT', vEinsatzD ,0.0)) then
    vBasis # Rso.Tab.Wert1;


  // Blöcke loopen
  vBlock # vBlockList->CteRead(_CteFirst);
  WHILE (vBlock<>0) do begin
    vBlockbonus # HdlLink(vBlock);
    VarInstance(Block,vBlockBonus);

    // Aufschlag für Besäumen
    if (Block_Breite<vEinsatzB) then
      vBasis # vBasis * ((100.0+"Rso.Proz_Besäumen")/100.0);
    // Aufschlag für Länge
    if (Vorgabe('TAF_B_%ZEIT_L', Block_Laenge, 0.0)) then
      vBasis # vBasis * ((100.0+Rso.Tab.Wert1)/100.0);
    // Aufschlag für Längentol
    if (Vorgabe('TAF_B_%ZEIT_LTOL', Block_LTol, 0.0)) then
      vBasis # vBasis * ((100.0+Rso.Tab.Wert1)/100.0);

    // Laufzeit einrechnen
    vX # 0.0;
    if (vBasis<>0.0) then
      vX # (Block_gesL/1000.0) / vBasis;

    vtLauf # vtLauf + vX;
    if (aMitAnzeige) and (vX<>0.0) then Todo('Prod Blockdauer:'+cnvaf(vX));

    // Messerbau einrechnen
    if (vMesVorher<>'') and (Block_Messer<>vMesVorher) then begin
      vX # Rso.t_Messerbau;
      vtRuest # vtRuest + vX;
      if (aMitAnzeige) and (vX<>0.0) then Todo('Ruest Messerbau:'+cnvaf(vX));
    end;

    // Längenänderung einrechnen
    if (vLenVorher<>0.0) and (Block_Laenge<>vLenVorher) then begin
      vX # "Rso.t_Längenänderung";
      vtRuest # vtRuest + vX;
      if (aMitAnzeige) and (vX<>0.0) then Todo('Ruest Längenänderung:'+cnvaf(vX));
    end;

    vMesVorher # Block_Messer;
    vLenVorher # Block_Laenge;

    vBlock # vBlockList->CteRead(_CteNext,vBlock);
  END;





  // Einsatzmengen einrechnen
  vX # vEinsatzStk * "Rso.t_RüstJeInputStk";
  vX # vX + (vEinsatzGew * "Rso.t_RüstJeInputlfd");
  vtRuest # vtRuest + vX;
  if (aMitAnzeige) and (vX<>0.0) then Todo('Ruest Einsatzmat:'+cnvaf(vX));
  vX # "Rso.t_AbsetzJeInpStk" * vAbsetzStk;
  vX # vX + ("Rso.t_AbsetzJeInpLfd" * vAbsetzGew);
  vtAbsetz # vtAbsetz + vX;
  if (aMitAnzeige) and (vX<>0.0) then Todo('Absetz Einsatzmat:'+cnvaf(vX));


  // Fertigmengen einrechnen
  vX # "Rso.t_ProdJeOutStk" * vFertigStk;
  vX # vX + ("Rso.t_ProdJeOutLfd" * vFertigGew);
  vtLauf # vtLauf + vX;
  if (aMitAnzeige) and (vX<>0.0) then Todo('Prod Fertigmat:'+cnvaf(vX));
  vX # "Rso.t_AbsetzJeOutStk" * vFertigStk;
  vX # vX + ("Rso.t_AbsetzJeOutLfd" * vFertigGew);
  vX # vX + ("Rso.t_AbsetzJeOutVPE" * vFertigPAK);
  vtAbsetz # vtAbsetz + vX;
  if (aMitAnzeige) and (vX<>0.0) then Todo('Absetz Fertigmat:'+cnvaf(vX));


  // Alle Zeiten Addieren
  BAG.P.Plan.Dauer # vtRuest + vtLauf + vtAbsetz;
  BAG.P.Plan.StartInfo # 'R:'+cnvaf(vtRuest)+'  P:'+cnvaf(vtLauf)+'  A:'+cnvaf(vtAbsetz);

  vBlock # vBlockList->CteRead(_CteFirst);
  WHILE (vBlock<>0) do begin
    vBlockbonus # HdlLink(vBlock);
    VarInstance(Block,vBlockBonus);
    VarFree(Block);
    vBlockList->CteDelete(vBlock);
    vBlock # vBlockList->CteRead(_CteFirst);
  END;;
  vBlockList->CteClear(y);
  vBlockList->CteClose();

end;

//========================================================================