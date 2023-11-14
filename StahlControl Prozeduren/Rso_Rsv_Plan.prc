@A+
//===== Business-Control =================================================
//
//  Prozedur  Rso_Rsv_Plan
//                  OHNE E_R_G
//  Info
//
//
//  09.02.2015  AH  Erstellung der Prozedur
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//  SUB _GetStruct(aTree : int; aNr : int) : logic;
//  SUB _CalcStructLevel(aTree : int) : logic;
//  SUB _LevelTree(var aTree : int) : logic;
//  SUB _BuildTree(aTyp : alpha; var aTree : int) : logic;
//  SUB _SaveTree(aTree : int) : logic;
//  SUB _CleanTree(aTree : int);
//  SUB _RecalcMinDat(aTree : int) : logic;
//  SUB _RecalcMaxDat(aTree : int) : logic;
//  SUB _GibtsReservierungsKollision(aGrp : int; aRes : int; var aDat1 : date; var aTim1 : time; var aDat2 : date; var aTim2 : time) : logic;
//  SUB _GibtsInnerKollision(aTree : int; aGrp : int; aRes : int; var aDat1 : date; var aTim1 : time; var aDat2 : date; var aTim2 : time) : logic;
//  SUB _PlanLinks(aTree : int) : logic;
//  SUB VerplaneVonHinten(aTyp : alpha) : logic;
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
  NewCT : Lib_Berechnungen:NewCalTime
end;

global Struct_Rso_Plan begin
  s_Rso_Plan_ResNr        : int;
  s_Rso_Plan_StartDat     : date;
  s_Rso_Plan_StartZeit    : time;
  s_Rso_Plan_EndDat       : date;
  s_Rso_Plan_EndZeit      : time;
//  s_Rso_Plan_Reihenfolge : int;
  s_Rso_Plan_Res1         : int;
  s_Rso_Plan_Res2         : int;
  s_Rso_Plan_Dauer        : int;      // in vollen MINUTEN
  s_Rso_Plan_Menge        : float;

  s_Rso_Plan_MinDat1      : date;     // Fenster Start
  s_Rso_Plan_MinZeit1     : time;
  s_Rso_Plan_MinDat2      : date;
  s_Rso_Plan_MinZeit2     : time;

  s_Rso_Plan_MaxDat1      : date;     // Fenster Ende
  s_Rso_Plan_MaxZeit1     : time;
  s_Rso_Plan_MaxDat2      : date;
  s_Rso_Plan_MaxZeit2     : time;

  s_Rso_Plan_Level        : int;
  s_Rso_Plan_ListOut      : int;
  s_Rso_Plan_ListIn       : int;
end;


//========================================================================
// _GetStruct
//========================================================================
sub _GetStruct(
  aTree : int;
  aNr   : int) : logic;
local begin
  vSort : alpha;
  vItem : int;
end;
begin
  if (aTree=0) then RETURN false;

  vSort # aint(aNr);
  vItem # aTree->CteRead(_CteFirst | _cteCustom | _CteSearch, 0, vSort);
//  vItem # aTree->CteRead(_CteFirst | _CteSearch, 0, vSort);
  if (vItem=0) then RETURN false;
  VarInstance(Struct_Rso_Plan,HdlLink(vItem));
  RETURN true;
end;


//========================================================================
//  _CalcStructLevel
//========================================================================
sub _CalcStructLevel(
  aTree : int;
) : logic;
local begin
  vLevel  : int;
  vList   : int;
  vItem   : int;
  vNr     : int;
end;
begin

  if (s_Rso_Plan_level<>0) then RETURN true;

  // gegen Zirkel
  vLevel # 1;
  s_Rso_Plan_Level # vLevel;

  if (s_Rso_Plan_ListIn<>0) then begin
    vNr   # s_Rso_Plan_ResNr;
    vList # s_Rso_Plan_ListIn;

    // Vorgänger loopen...
    FOR vItem   # vList->CteRead(_CteFirst);
    LOOP vItem  # vList->CteRead(_CteNext, vItem);
    WHILE (vItem<>0) do begin
//    vBuf # s_Rso_Plan_ResNr;
      if (_GetStruct(aTree, vItem->spID)=false) then RETURN false;
      if (_CalcStructLevel(aTree)=false) then RETURN false;
      vLevel # Max(vLevel, s_Rso_Plan_Level + 1);
//    GetStruct(aTree, vBuf);
    END;

    _GetStruct(aTree, vNr);
  end;

  s_Rso_Plan_Level # vLevel;
//debugx(aint(s_Rso_Plan_resnr)+' setlevel : '+aint(vLevel));

  RETURN true;
end;



//========================================================================
//  _LevelTree
//      +ERR
//========================================================================
Sub _LevelTree(
  var aTree : int) : logic;
local begin
  vItem   : int;
  vItem2  : int;
  vTree   : int;
  vErr    : logic;
end;
begin

  // 2. Baum zum umsortieren anlegen
  vTree # CteOpen(_CteTreeCI);

  // Baum loopen....
  FOR vItem # aTree->CteRead(_CteFirst)
  LOOP vItem # aTree->CteRead(_CteNext, vItem)
  WHILE (vItem<>0) and (vErr=false) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));
    if (_CalcStructLevel(aTree)=false) then begin
      vTree->CteClear(true);
      vTree->CteClose();
      RETURN false;
    end;

    // umsortieren nach Level
    vItem2 # CteOpen(_CteItem);
    if (vItem2=0) then begin
      vErr # true;
      Error(999999, 'Out of memory!');
      BREAK;
    end;
    vItem2->spID     # s_Rso_Plan_ResNr;
    vItem2->spCustom # aint(s_Rso_Plan_ResNr);
    vItem2->spName # cnvai(s_Rso_Plan_Level, _FmtNumLeadZero,0,3)+'|'+vItem->spCustom;
    HdlLink(vItem2, VarInfo(Struct_Rso_Plan));

    // in zweiten Baum speichern
    if (vTree->CteInsert(vItem2)=false) then vErr # true;
  END;

  aTree->CteClear(false);
  aTree->CteClose();
  aTree # vTree;

  RETURN (vErr=false);
end;


//========================================================================
//  _BuildTree
//      +ERR
//========================================================================
Sub _BuildTree(
  aTyp      : alpha;
  var aTree : int) : logic;
local begin
  Erx       : int;
  vItem     : int;
  vItem2    : int;
  vSort     : alpha;
  vStruct   : int;
  vDatEnde  : date;
  vTimEnde  : time;
  vNr1      : int;
  vNr2      : int;
  vNr3      : int;
end;
begin

  if (aTree=0) then aTree # CteOpen(_CteTreeCI);

  // existiert von dem BA schon irgendwas???
//  vSort # cnvai(BAG.P.Nummer)+'|*';

//  vItem # aTree->CteRead(_CteFirst | _CteCustom | _CteSearch, 0, vSort);
//  if (vItem<>0) then RETURN;  // JA -> ENDE

  if (Rso_Rsv_Data:GetTraegerNummern(aTyp, var vNr1, var vNr2, var vNr3)=false) then RETURN false;
  // letze Nummer ignorieren
  if (vNr3<>0) then vNr3 # 0
  else if (vNr2<>0) then vNr2 # 0
  else if (vNr1<>0) then vNr1 # 0;


  RecBufClear(170);
  "Rso.R.Trägertyp"     # aTyp;
  "Rso.R.TrägerNummer1" # vNr1;
  "Rso.R.TrägerNummer2" # vNr2;
  FOR Erx # RecRead(170,3,0)
  LOOP Erx # RecRead(170,3,_recNext)
  WHILE (Erx<_rNoRec) and
    ("Rso.R.Trägertyp"=aTyp) and
    (("Rso.R.TrägerNummer1"=vNr1) or (vNr1=0)) and
    (("Rso.R.TrägerNummer2"=vNr2) or (vNr2=0)) do begin


    vSort # '000|'+aint(Rso.R.Reservierungnr);

    vItem # CteOpen(_CteItem);
    if (vItem=0) then begin
      Error(999999, 'Out of memory!');
      RETURN false;
    end;
    vItem->spID     # Rso.R.Reservierungnr;
    vItem->spCustom # aint(Rso.R.Reservierungnr);
    vItem->spName   # vSort;
    vStruct # VarAllocate(Struct_Rso_Plan);
    if (vStruct=0) then begin
      Error(999999, 'Out of memory!');
      RETURN false;
    end;

    s_Rso_Plan_ResNr      # Rso.R.Reservierungnr;
    s_Rso_Plan_StartDat   # Rso.R.Plan.StartDat;
    s_Rso_Plan_StartZeit  # Rso.R.Plan.StartZeit;
//        s_BA_Plan_EndDat    # BAG.P.Plan.EndDat;
//        s_BA_Plan_EndZeit   # BAG.P.Plan.EndZeit;
    s_Rso_Plan_EndDat     # s_Rso_Plan_StartDat;
    s_Rso_Plan_EndZeit    # s_Rso_Plan_StartZeit;
    s_Rso_Plan_Dauer      # Rso.R.Dauer;
    s_Rso_Plan_Res1       # Rso.R.Ressource.Grp;
    s_Rso_Plan_Res2       # Rso.R.Ressource.Nr;

    s_Rso_Plan_MinDat1    # Rso.R.MinDat.Start;
    s_Rso_Plan_MinZeit1   # Rso.R.MinZeit.Start;
    s_Rso_Plan_MaxDat2    # Rso.R.MaxDat.Ende;  // ACHTUNG !!! ENDE setzen!!!
    s_Rso_Plan_MaxZeit2   # Rso.R.MaxZeit.Ende;
//        Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit, cnvif(-s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);
    // Endtermin ausrechnen
//        Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_EndDat, var s_BA_Plan_EndZeit, cnvif(s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);

    // Verknüpfung von Datenbereich mit dem Item Element
    HdlLink(vItem,vStruct);

    CteInsert(aTree,vItem); // in Baum einbinden

    // Input-Liste füllen...
    // Vorgänger loopen...
    FOR Erx # RecLink(171,170,2,_recFirst)
    LOOP Erx # RecLink(171,170,2,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (s_Rso_Plan_ListIn=0) then s_Rso_Plan_ListIn  # CteOpen(_CteList);

      vItem2 # CteOpen(_CteItem);
      if (vItem2<>0) then begin
        vItem2->spID     # "Rso.R.V.Vorgänger";//RecInfo(171,_RecID);
        vItem2->spName   # aint("Rso.R.V.Vorgänger");
//        vItem2->spName   # aint("Rso.R.V.Vorgänger")+'|'+aint("Rso.R.V.Nachfolger");
//debug('ins IN:'+vItem2->spname+' -> '+cnvai(bag.p.position));
        CteInsert(s_Rso_Plan_ListIn,vItem2); // in Liste einbinden
      end;
    END;


    // Output-Liste füllen...
    // Nachfolger loopen...
    FOR Erx # RecLink(171,170,3,_recFirst)
    LOOP Erx # RecLink(171,170,3,_recNext)
    WHILE (Erx<=_rLocked) do begin

      if (s_Rso_Plan_ListOut=0) then s_Rso_Plan_ListOut  # CteOpen(_CteList);

      vItem2 # CteOpen(_CteItem);
      if (vItem2<>0) then begin
        vItem2->spID     # Rso.R.V.Nachfolger;//RecInfo(171,_RecID);
        vItem2->spName   # aint(Rso.R.V.Nachfolger);
//        vItem2->spName   # aint("Rso.R.V.Vorgänger")+'|'+aint("Rso.R.V.Nachfolger");
//debug('ins IN:'+vItem2->spname+' -> '+cnvai(bag.p.position));
        CteInsert(s_Rso_Plan_ListOut,vItem2); // in Liste einbinden
      end;
    END;

  END;

  RETURN true;
end;


//========================================================================
//  _SaveTree
//      +ERR
//========================================================================
sub _SaveTree(aTree : int) : logic;
local begin
  Erx   : int;
  vItem : int;
  vA    : alpha(500);
end;
begin

  // Baum loopen....
  FOR vItem # aTree->CteRead(_CteFirst);
  LOOP vItem # aTree->CteRead(_CteNext, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));
/***
vA #      'item:'+aint(s_rso_Plan_ResNr)+'  Level:'+aint(s_rso_plan_level)+'  name:'+vitem->spName;
vA # vA + '   Min Von:'+cnvad(s_rso_Plan_MinDat1)+' '+cnvat(s_rso_Plan_MinZeit1);
vA # vA + '   Max Von:'+cnvad(s_rso_Plan_MaxDat1)+' '+cnvat(s_rso_Plan_MaxZeit1);
vA # vA + '   FIX Start:'+cnvad(s_rso_Plan_StartDat)+' '+cnvat(s_rso_Plan_StartZeit);
debug(vA);
vA # '                           ';
vA # vA + '       bis:'+cnvad(s_rso_Plan_MinDat2)+' '+cnvat(s_rso_Plan_MinZeit2);
vA # vA + '       bis:'+cnvad(s_rso_Plan_MaxDat2)+' '+cnvat(s_rso_Plan_MaxZeit2);
vA # vA + '        Ende:'+cnvad(s_rso_Plan_EndDat)+' '+cnvat(s_rso_Plan_EndZeit);
debug(vA);
***/
    // Reservierung updaten...
    Rso.R.Reservierungnr # s_Rso_Plan_ResNr;
    Erx # RecRead(170,1,_recLock);
    if (Erx>_rLocked) then begin
      Error(999999,'Satz nicht änderbar: Rsrv.'+aint(s_Rso_Plan_resNr));
      RETURN false;
    end;

    Rso.R.Level           # s_Rso_Plan_Level;
    Rso.R.Plan.StartDat   # s_Rso_Plan_StartDat;
    Rso.R.Plan.StartZeit  # s_Rso_Plan_StartZeit;
    Rso.R.Plan.EndDat     # s_Rso_Plan_EndDat;
    Rso.R.Plan.EndZeit    # s_Rso_Plan_EndZeit;
    Rso.R.Dauer           # s_Rso_Plan_dauer;
    Rso.R.Ressource.Grp   # s_Rso_Plan_Res1;
    Rso.R.Ressource.Nr    # s_Rso_Plan_Res2;

    Rso.R.MinDat.Start    # s_Rso_Plan_MinDat1;
    Rso.R.MinZeit.Start   # s_Rso_Plan_MinZeit1;
    Rso.R.MinDat.Ende     # s_Rso_Plan_MinDat2;
    Rso.R.MinZeit.Ende    # s_Rso_Plan_MinZeit2;

    Rso.R.MaxDat.Start    # s_Rso_Plan_MaxDat1;
    Rso.R.MaxZeit.Start   # s_Rso_Plan_MaxZeit1;
    Rso.R.MaxDat.Ende     # s_Rso_Plan_MaxDat2;
    Rso.R.MaxZeit.Ende    # s_Rso_Plan_MaxZeit2;

    Erx # RekReplace(170);
    if (Erx>_rLocked) then begin
      Error(999999,'Satz nicht änderbar: Rsrv.'+aint(s_Rso_Plan_resNr));
      RETURN false;
    end;
    if (Rso_Rsv_Data:UpdateTraeger()=false) then begin
      Error(999999,'Reservierungs-Träger nicht änderbar: '+aint(s_Rso_Plan_resNr));
      RETURN false;
    end;
  END;

  RETURN true;
end;


//========================================================================
// _CleatTree
//
//========================================================================
sub _CleanTree(aTree : int);
local begin
  vItem : int;
end;
begin

  // Baum loopen....
  FOR vItem # aTree->CteRead(_CteFirst);
  LOOP vItem # aTree->CteRead(_CteNext, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));

    // ggf. Input-Liste löschen
    if (s_Rso_Plan_ListIn<>0) then begin
      s_Rso_Plan_ListIn->CteClear(true);
      s_Rso_Plan_ListIn->CteClose();
    end;
    // ggf. Output-Liste löschen
    if (s_Rso_Plan_ListOut<>0) then begin
      s_Rso_Plan_ListOut->CteClear(true);
      s_Rso_Plan_ListOut->CteClose();
    end;

    HdlLink(vItem,0);
    VarFree(Struct_Rso_Plan);
  END;

  aTree->CteClear(true);
  aTree->CteClose();
end;


//========================================================================
// _RecalcMinDat
//      +ERR
//========================================================================
sub _RecalcMinDat(aTree : int) : logic;
local begin
  vItem   : int;
  vItem2  : int;
  vCT     : caltime;
  vCT2    : caltime;
  vList   : int;
  vNr     : int;
  vDat    : date;
  vTim    : time;
  vI      : int;
end;
begin

  // Vorwärts durch Level loopen...
  FOR vItem # aTree->CteRead(_CteFirst);
  LOOP vItem # aTree->CteRead(_CteNext, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));

    if (s_Rso_Plan_MinDat1<>0.0.0) then begin
      vI # s_Rso_Plan_Dauer;
      Rso_Kal_Data:PasstRechtsInKalender(s_Rso_Plan_Res1, var s_Rso_Plan_MinDat1, var s_Rso_Plan_MinZeit1, var vI, var s_Rso_Plan_MinDat2, var s_Rso_Plan_MinZeit2);
      CYCLE;
    end;

    vCT2->vpDate # 01.01.2000;
    vCT2->vpTime # 0:0;

    if (s_Rso_Plan_ListIn<>0) then begin
      // Vorgänger loopen...
      vList # s_Rso_Plan_ListIn;
      FOR vItem2  # vList->CteRead(_CteFirst);
      LOOP vItem2 # vList->CteRead(_CteNext, vItem2);
      WHILE (vItem2<>0) do begin
        if (_GetStruct(aTree, vItem2->spID)=false) then begin
          Error(999999, 'unknown item!');
          RETURN false;
        end;

        // Maximum suchen
        if (s_Rso_Plan_MinDat2<>0.0.0) then begin
          vCT   # NewCT(s_Rso_Plan_MinDat2, s_Rso_Plan_MinZeit2);
          vCT2  # Max(vCT, vCT2);
        end;

      END;
      VarInstance(Struct_Rso_Plan,HdlLink(vItem));
    end;

    Lib_Berechnungen:NewDateTime(vCT2, var vDat, var vTim);
    s_Rso_Plan_MinDat1  # vDat;
    s_Rso_Plan_MinZeit1 # vTim;
    vI # s_Rso_Plan_Dauer;
    Rso_Kal_Data:PasstRechtsInKalender(s_Rso_Plan_Res1, var s_Rso_Plan_MinDat1, var s_Rso_Plan_MinZeit1, var vI, var s_Rso_Plan_MinDat2, var s_Rso_Plan_MinZeit2);
//debugx('SetMin :'+cnvac(vCT2, _FmtCaltimeRFC));
//    _VererbeMinmax();
  END;

  RETURN true;
end;


//========================================================================
// _RecalcMaxDat
//        +ERR
//========================================================================
sub _RecalcMaxDat(aTree : int) : logic;
local begin
  vItem   : int;
  vItem2  : int;
  vCT     : caltime;
  vCT2    : caltime;
  vList   : int;
  vNr     : int;
  vDat    : date;
  vTim    : time;
  vL      : int;
end;
begin

  // Rückwärts durch Level loopen...
  FOR vItem # aTree->CteRead(_CteLast);
  LOOP vItem # aTree->CteRead(_CtePrev, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));

    if (s_Rso_Plan_MaxDat2<>0.0.0) then begin
      vL # s_Rso_Plan_Dauer;
      Rso_Kal_Data:PasstLinksInKalender(s_Rso_Plan_Res1, var s_Rso_Plan_MaxDat1, var s_Rso_Plan_MaxZeit1, var vL, var s_Rso_Plan_MaxDat2, var s_Rso_Plan_MaxZeit2);
      CYCLE;
    end;


    vCT2->vpDate # 01.01.2099;
    vCT2->vpTime # 0:0;

    if (s_Rso_Plan_ListOut<>0) then begin

      // Nachfolger loopen...
      vList # s_Rso_Plan_ListOut;
      FOR vItem2  # vList->CteRead(_CteFirst);
      LOOP vItem2 # vList->CteRead(_CteNext, vItem2);
      WHILE (vItem2<>0) do begin
        if (_GetStruct(aTree, vItem2->spID)=false) then begin
          Error(999999, 'unknown item!');
          RETURN false;
        end;

        // Minimum suchen
        if (s_Rso_Plan_MaxDat1<>0.0.0) then begin
          vCT   # NewCT(s_Rso_Plan_MaxDat1, s_Rso_Plan_MaxZeit1);
          vCT2  # Min(vCT, vCT2);
        end;

      END;
      VarInstance(Struct_Rso_Plan,HdlLink(vItem));
    end;

    Lib_Berechnungen:NewDateTime(vCT2, var vDat, var vTim);
    s_Rso_Plan_MaxDat2  # vDat;
    s_Rso_Plan_MaxZeit2 # vTim;
    vL # s_Rso_Plan_Dauer;
    Rso_Kal_Data:PasstLinksInKalender(s_Rso_Plan_Res1, var s_Rso_Plan_MaxDat1, var s_Rso_Plan_MaxZeit1, var vL, var s_Rso_Plan_MaxDat2, var s_Rso_Plan_MaxZeit2);
  END;

  RETURN true;
end;


//========================================================================
// _GibtsReservierungsKollision
//          TRUE, dann aDat1, aTim1, aDat2, aTim2 mit Kollisionszeit gefüllt
//========================================================================
sub _GibtsReservierungsKollision(
  aGrp      : int;
  aRes      : int;
  var aDat1 : date;
  var aTim1 : time;
  var aDat2 : date;
  var aTim2 : time;
) : logic;
local begin
  Erx       : int;
  vCT, vCT2 : caltime;
end;
begin

//debugx('checke outer Kollission '+cnvad(aDat1)+' '+cnvat(aTim1)+' bis '+cnvad(aDat2)+' '+cnvat(aTim2));

  RecBufClear(170);
  Rso.R.Ressource.Grp   # aGrp;
  Rso.R.Ressource.Nr    # aRes;
  Rso.R.Plan.StartDat   # aDat1;
  Rso.R.Plan.StartZeit  # aTim1;
  Erx # RecRead(170,2,0); // Reservierung holen
  if (Erx<=_rLastRec) and (Rso.R.Ressource.Grp=aGrp) and (Rso.R.Ressource.Nr=aRes) then begin
//debug('A '+cnvad(Rso.R.Plan.StartDat)+' '+cnvat(Rso.R.Plan.StartZeit)+' bis '+cnvad(Rso.R.Plan.EndDat)+' '+cnvat(Rso.R.Plan.EndZeit));
    vCT # NewCT(aDat1, aTim1);
    if (vCT>=NewCT(Rso.R.Plan.Startdat, Rso.R.Plan.StartZeit)) then begin
      if (vCT<NewCT(Rso.R.Plan.Enddat, Rso.R.Plan.EndZeit)) then begin
//debugx('Kolli A!');
        aDat1 # Rso.R.Plan.StartDat;
        aTim1 # Rso.R.Plan.StartZeit;
        aDat2 # Rso.R.Plan.EndDat;
        aTim2 # Rso.R.Plan.EndZeit;
        RETURN true;
      end;
    end
    else begin
      vCT # NewCT(aDat2, aTim2);
      if (vCT>NewCT(Rso.R.Plan.Startdat, Rso.R.Plan.StartZeit)) then begin
//debugx('Kollib B!');
        aDat1 # Rso.R.Plan.StartDat;
        aTim1 # Rso.R.Plan.StartZeit;
        aDat2 # Rso.R.Plan.EndDat;
        aTim2 # Rso.R.Plan.EndZeit;
        RETURN true;
      end;
    end;
  end;

  Erx # RecRead(170,2,_recPrev); // vorherige Reservierung holen
  if (Erx<=_rLastRec) and (Rso.R.Ressource.Grp=aGrp) and (Rso.R.Ressource.Nr=aRes) then begin
    vCT # NewCT(Rso.R.Plan.Enddat, Rso.R.Plan.EndZeit);
    if (NewCT(aDat1, aTim1)<vCT) then begin
//debug('C '+cnvad(Rso.R.Plan.StartDat)+' '+cnvat(Rso.R.Plan.StartZeit)+' bis '+cnvad(Rso.R.Plan.EndDat)+' '+cnvat(Rso.R.Plan.EndZeit));
//debugx('Kolli C!');
        aDat1 # Rso.R.Plan.StartDat;
        aTim1 # Rso.R.Plan.StartZeit;
        aDat2 # Rso.R.Plan.EndDat;
        aTim2 # Rso.R.Plan.EndZeit;
        RETURN true;
//      end;
    end;
  end;

  RETURN false;
end;


//========================================================================
// _GibtsInnerKollision
//          TRUE, dann aDat1, aTim1, aDat2, aTim2 mit Kollisionszeit gefüllt
//========================================================================
sub _GibtsInnerKollision(
  aTree     : int;
  aGrp      : int;
  aRes      : int;
  var aDat1 : date;
  var aTim1 : time;
  var aDat2 : date;
  var aTim2 : time;
) : logic;
local begin
  vItem     : int;
  vC1, vC2  : caltime;
  vC3, vC4  : caltime;
  vBuf      : int;
  vKoll     : logic;
end;
begin

//debugx('checke inner Kollission '+cnvad(aDat1)+' '+cnvat(aTim1)+' bis '+cnvad(aDat2)+' '+cnvat(aTim2));

  vBuf # VarInfo(Struct_Rso_Plan);

  vC1   # NewCT(aDat1, aTim1);
  vC2   # NewCT(aDat2, aTim2);


  FOR vItem # CteRead(aTree, _CteFirst)
  LOOP vItem  # aTree->CteRead(_CteNext, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));
    // bisher ungeplante ignorieren
    if (s_Rso_Plan_StartDat=0.0.0) then CYCLE;
    // auf anderes Ressource ignorieren
    if (S_Rso_Plan_Res1<>aGrp) or (s_Rso_Plan_Res2<>aRes) then CYCLE;

    vC3  # NewCT(s_Rso_Plan_StartDat, s_Rso_Plan_StartZeit);
    vC4  # NewCT(s_Rso_Plan_EndDat, s_Rso_Plan_EndZeit);
    if (vC1<vC4) and (vC2>vC3) then BREAK;
  END;
  // Kollision??
  if (vItem<>0) then begin
//debugx('INNER Kolli!');
    Lib_Berechnungen:NewDateTime(vC3, var aDat1, var aTim1);
    Lib_Berechnungen:NewDateTime(vC4, var aDat2, var aTim2);
    VarInstance(Struct_Rso_Plan, vBuf);
    RETURN true;
  end;

  VarInstance(Struct_Rso_Plan, vBuf);

  RETURN false; // KEINE Kollision

end;


//========================================================================
// _PlanLinks
//      +ERR
//========================================================================
sub _PlanLinks(aTree : int) : logic;
local begin
  vItem   : int;
  vItem2  : int;
  vCT     : caltime;
  vCT2    : caltime;
  vList   : int;
  vCount  : int;
  vDat1   : date;
  vTim1   : time;
  vDat2   : date;
  vTim2   : time;
  vL      : int;
end;
begin

  // Rückwärts durch Level loopen...
  FOR vItem # aTree->CteRead(_CteLast);
  LOOP vItem # aTree->CteRead(_CtePrev, vItem);
  WHILE (vItem<>0) do begin
    VarInstance(Struct_Rso_Plan,HdlLink(vItem));

    if (s_Rso_Plan_MaxDat1=0.0.0) or (s_Rso_Plan_MaxDat2=0.0.0) then CYCLE;

    vCT2->vpDate # s_Rso_Plan_MaxDat2;    // aktuelles maximales Ende
    vCT2->vpTime # s_Rso_Plan_MaxZeit2;

    // ggf. Planzeit der Nachfolger prüfen, wenn diese kleiner ist...
    if (s_Rso_Plan_ListOut<>0) then begin
      // Nachfolger loopen...
      vList # s_Rso_Plan_ListOut;
      FOR vItem2  # vList->CteRead(_CteFirst);
      LOOP vItem2 # vList->CteRead(_CteNext, vItem2);
      WHILE (vItem2<>0) do begin
        if (_GetStruct(aTree, vItem2->spID)=false) then CYCLE;
        // Minimum suchen
        if (s_Rso_Plan_StartDat<>0.0.0) then begin
          vCT   # NewCT(s_Rso_Plan_StartDat, s_Rso_Plan_StartZeit);
          vCT2  # Min(vCT, vCT2);
        end;
      END;
      VarInstance(Struct_Rso_Plan,HdlLink(vItem));
    end;

    vCount # 0;
    // vCT2 = Maximales Ende
    Lib_Berechnungen:NewDateTime(vCT2, var vDat2, var vTim2);
    REPEAT
/*
      inc(vCount);
      if (vCount>5) then begin
debugx('Planungsfehler A bei '+aint(s_rso_Plan_ResNr));
        RETURN false;
      end;
*/

      if (vDat2<s_Rso_Plan_MaxDat1) or
        ((vDat2=s_Rso_Plan_MaxDat1) and (vTim2<s_Rso_Plan_MaxZeit1)) then begin
        Error(999999, 'Zeitfenster nicht einhaltbar bei Rsrv.'+aint(s_rso_Plan_ResNr));
        RETURN false;
      end;
      vL # s_Rso_Plan_Dauer;
      // Anfang ermitteln
      if (Rso_Kal_Data:PasstLinksInKalender(s_Rso_Plan_Res1, var vDat1, var vTim1, var vL, var vDat2, var vTim2)=false) then begin
        Error(999999, 'Kein Kalender (mehr) bei Rsrv.'+aint(s_rso_Plan_ResNr));
        RETURN false;
      end;

      // externe Kollissionen prüfen
      if (_GibtsReservierungsKollision(s_rso_Plan_Res1, s_Rso_Plan_Res2, var vDat1, var vTim1, var vDat2, var vTim2)) then begin
        // wenn belegt, dann Kollisionstart als Ende nehmen...
        vDat2 # vDat1;
        vTim2 # vTim1;
//debug('BELEGT! neues Ende:'+cnvad(vDat2)+' '+cnvat(vTim2));
        CYCLE;
      end;
      // interne Kollissionen prüfen
      if (_GibtsInnerKollision(aTree, s_rso_Plan_Res1, s_Rso_Plan_Res2, var vDat1, var vTim1, var vDat2, var vTim2)) then begin
        // wenn belegt, dann Kollisionstart als Ende nehmen...
        vDat2 # vDat1;
        vTim2 # vTim1;
//debug('BELEGT! neues Ende:'+cnvad(vDat2)+' '+cnvat(vTim2));
        CYCLE;
      end;


    UNTIL (1=1);

    // pasenden Platz gefunden und fixieren...
    s_Rso_Plan_StartDat   # vDat1;
    s_Rso_Plan_StartZeit  # vTim1;
    s_Rso_Plan_EndDat     # vDat2;
    s_Rso_Plan_EndZeit    # vTim2;
  END;

  RETURN true;
end;


//========================================================================
// VerplaneVonHinten
//      +ERR
//========================================================================
Sub VerplaneVonHinten(
  aTyp      : alpha;
) : logic;
local begin
  vTree     : int;
  vOK       : logic;
end;
begin

  if (_BuildTree(aTyp, var vTree)) then begin
    if (_LevelTree(var vTree)) then begin
      if (_RecalcMinDat(vTree)) then begin
        if (_RecalcMaxDat(vTree)) then begin
          if (_PlanLinks(vTree)) then begin
            if (_SaveTree(vTree)) then begin
              vOK # y;
            end;
          end;
        end;
      end;
    end;
  end;

  _CleanTree(vTree);

  RETURN vOK;
end;


//========================================================================
