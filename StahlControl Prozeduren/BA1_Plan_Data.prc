@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_Plan_Data
//                    OHNE E_R_G
//  Info
//
//
//  18.02.2008  AI  Erstellung der Prozedur
//  05.04.2022  AH  ERX
//  11.07.2022  ST  "sub Autoplanung_R" ignoriert "Check-Arbeitsgänge" für die Terminplanung
//  2022-07-14  AH  AFX "BAG.Plan.Data.SetTermin.Post"
//
//  Subprozeduren
//  SUB HoleTreeDaten(aTreeObj  : int);
//  SUB GetMaxInput(aTree : int; aList : int; var aDat : date; var aZeit : time);
//  SUB GetMinOutput(aTree : int; aList : int; var aDat : date; var aZeit : time);
//  SUB RecalcMaxDat(aTree : int);
//  SUB RecalcMinDat(aTree : int);
//  SUB BAGNachTree(aBAG : int;aTree : int);
//  SUB RecSave(aTreeObj  : int) : logic;
//  SUB PlanTerminOK() : int;
//
//  SUB AutoPlanung_R(): int;
//  SUB CheckBelegung(aDate1  : date; aTime1  : time; var aDate2  : date; var aTime2  : time) : logic;
//  SUB SetTermin(aDate1  : date; aTime1  : time; aDate2  : date; aTime2  : time);
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG

declare SetTermin(aDate1 : date; aTime1 : time; aDate2 : date; aTime2 : time) : int
declare CheckBelegung(aDate1  : date; aTime1  : time; var aDate2  : date; var aTime2  : time) : logic;

global Struct_BA_Plan begin
  s_BA_Plan_BAG         : int;
  s_BA_Plan_Pos         : int;
  s_BA_Plan_StartDat    : date;
  s_BA_Plan_StartZeit   : time;
  s_BA_Plan_EndDat      : date;
  s_BA_Plan_EndZeit     : time;
  s_BA_Plan_Reihenfolge : int; // Reihenfolge [07.01.2010/PW]

  s_BA_Plan_Res1        : int;
  s_BA_Plan_Res2        : int;
  s_BA_Plan_Dauer       : float;
  s_BA_Plan_MinDat      : date;
  s_BA_Plan_MinZeit     : time;
  s_BA_Plan_MaxDat      : date;
  s_BA_Plan_MaxZeit     : time;

  s_BA_Plan_ListOut     : int;
  s_BA_Plan_ListIn      : int;
end;


//========================================================================
// HoleTreeDaten
//
//========================================================================
sub HoleTreeDaten(
  aTreeObj  : int
);
local begin
  vTree   : int;
  vItem   : int;
  vSort   : alpha;
  vVorherDat    : date;
  vVorherDauer  : float;
end;
begin
/*
  cPlanDat    # 0.0.0;
  cPlanZeit   # 0:0;
  cPlanDauer  # 0.0;
  cPlanRes1   # 0;
  cPlanRes2   # 0;
*/

//  vTree # cnvia($lb.BA1.P.Plantree->wpcustom);
  vTree # cnvia(aTreeObj->wpcustom);
  if (vTree=0) then RETURN;

  vSort # cnvai(BAG.P.Nummer)+'|'+AInt(BAG.P.Position);
//    vItem # vTree->CteRead(_CteFirst | _CteSearch, 0, vSort);
  vItem # vTree->CteRead(_CteFirst | _cteCustom | _CteSearch, 0, vSort);
  if (vItem<>0) then begin
    VarInstance(Struct_BA_Plan,HdlLink(vItem));
/*
    cPlanDat    # s_BA_Plan_Startdat;
    cPlanZeit   # s_BA_Plan_StartZeit;
    cPlanDauer  # s_BA_Plan_Dauer;
    cPlanRes1   # s_BA_Plan_Res1;
    cPlanRes2   # s_BA_Plan_Res2;
*/
vVorherDat    # BAG.P.Plan.StartDat;
vVorherDauer  # BAG.P.Plan.Dauer;
    BAG.P.Plan.StartDat   # s_BA_Plan_Startdat;
    BAG.P.Plan.StartZeit  # s_BA_Plan_StartZeit;
    BAG.P.Plan.Dauer      # s_BA_Plan_Dauer;
    BAG.P.Plan.EndDat     # s_BA_Plan_EndDat;
    BAG.P.Plan.EndZeit    # s_BA_Plan_EndZeit;
    BAG.P.Reihenfolge     # s_BA_Plan_Reihenfolge // Reihenfolge [07.01.2010/PW]
    BAG.P.Ressource.Grp   # s_BA_Plan_Res1;
    BAG.P.Ressource       # s_BA_Plan_Res2;
    BAG.P.Fenster.MinDat  # s_BA_Plan_MinDat;
    BAG.P.Fenster.MinZei  # s_BA_Plan_MinZeit;
    BAG.P.Fenster.MaxDat  # s_BA_Plan_MaxDat;
    BAG.P.Fenster.MaxZei  # s_BA_Plan_MaxZeit;
if (Set.Installname='BSP') and ((vVorherDat<>BAG.P.Plan.StartDat) or (vVorherDauer<>BAG.P.Plan.Dauer)) then begin   // 2022-11-14 AH    Proj. 2329/63
Lib_Debug:Protokoll('!BSP_Log_Komisch', 'BA '+aint(BAG.P.Nummer)+'/'+aint(BAG.P.Position)+' : '+cnvad(BAG.P.Plan.StartDat)+' '+anum(BAG.P.Plan.Dauer,0)+' ['+__PROC__+':'+aint(__LINE__)+','+gUsername+']')
end;
  end;

end;


//========================================================================
// GetMaxInput
//
//========================================================================
sub GetMaxInput(
  aTree     : int;
  aList     : int;
  var aDat  : date;
  var aZeit : time;
);
local begin
  vA        : alpha;
  vBAG,vPos : int;
  vItem     : int;
  vItem2    : int;
  vBuf      : int;
  vDat      : date;
  vZeit     : time;
  vDat2     : date;
  vZeit2    : time;
  vDatEnde  : date;
  vTimEnde  : time;
end
begin

  vDat  # 0.0.0;
  vZeit # 0:0;

  vBuf # VarInfo(Struct_BA_Plan);

  vItem # aList->CteRead(_CteFirst);
  WHILE (vItem<>0) do begin
    vA # Str_Token(vItem->spname,'|',1);
    vBAG # cnvia(vA);
    vA # Str_Token(vItem->spname,'|',2);
    vPos # cnvia(vA);

    vA      # cnvai(vBAG)+'|'+cnvai(vPos);
    vItem2  # aTree->CteRead(_CteFirst | _cteCustom | _CteSearch, 0, vA);
    if (vItem2<>0) then begin
      VarInstance(Struct_BA_Plan,HdlLink(vItem2));
//debug('guck '+cnvai(s_BA_PLan_bag)+'/'+cnvai(s_BA_PLan_pos));

      if (s_BA_Plan_Enddat<>0.0.0) then begin
        if (s_BA_Plan_EndDat>vDat) then begin
          vDat  # s_BA_Plan_EndDat;
          vZeit # s_BA_Plan_EndZeit;
          end
        else if (s_BA_Plan_EndDat=vDat) and (s_BA_Plan_EndZeit>vZeit) then begin
          vZeit # s_BA_Plan_EndZeit;
        end;
        end
      else begin
        if (s_BA_Plan_MinDat<>0.0.0) then begin
          vDat2   # s_BA_Plan_MinDat;
          vZeit2  # s_BA_Plan_MinZeit;
//          TerminModify(var vDat2, var vZeit2, s_BA_Plan_Dauer);
          Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var vDat2, var vZeit2, cnvif(s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);
          if (vDat2>vDat) then begin
            vDat  # vDat2;
            vZeit # vZeit2;
            end
          else if (vDat2=vDat) and (vZeit2>vZeit) then begin
            vZeit # vZeit2;
          end;
        end;
      end;  // MinFenster
    end;

    vItem # aList->CteRead(_CteNext, vItem);
  END;

  if (vDat=0.0.0) then begin
    vDat  # 0.0.0;
    vZeit # 0:0;
  end;

  VarInstance(Struct_BA_Plan, vBuf);

  aDat  # vDat;
  aZeit # vZeit;
end;


//========================================================================
// GetMinOutput
//
//========================================================================
sub GetMinOutput(
  aTree     : int;
  aList     : int;
  var aDat  : date;
  var aZeit : time);
local begin
  vA        : alpha;
  vBAG,vPos : int;
  vItem     : int;
  vItem2    : int;
  vBuf      : int;
  vDat      : date;
  vZeit     : time;
end
begin

  vDat  # 31.12.2099;
  vZeit # 0:0;

  vBuf # VarInfo(Struct_BA_Plan);

  vItem # aList->CteRead(_CteFirst);
  WHILE (vItem<>0) do begin
    vA # Str_Token(vItem->spname,'|',1);
    vBAG # cnvia(vA);
    vA # Str_Token(vItem->spname,'|',2);
    vPos # cnvia(vA);

    vA      # cnvai(vBAG)+'|'+cnvai(vPos);
    vItem2  # aTree->CteRead(_CteFirst | _cteCustom | _CteSearch, 0, vA);
    if (vItem2<>0) then begin
      VarInstance(Struct_BA_Plan,HdlLink(vItem2));
//debug('guck '+cnvai(s_BA_PLan_bag)+'/'+cnvai(s_BA_PLan_pos)+ ' '+cnvad(s_BA_Plan_EndDat)+' : '+cnvad(vDat));

      if (s_BA_Plan_StartDat<>0.0.0) then begin
        if (s_BA_Plan_StartDat<vDat) then begin
          vDat  # s_BA_Plan_StartDat;
          vZeit # s_BA_Plan_STartZeit;
          end
        else if (s_BA_Plan_StartDat=vDat) and (s_BA_Plan_StartZeit<vZeit) then begin
          vZeit # s_BA_Plan_StartZeit;
        end;
        end
      else begin
        if (s_BA_Plan_MaxDat<>0.0.0) then begin
          if (s_BA_Plan_MaxDat<vDat) then begin
            vDat  # s_BA_Plan_MaxDat;
            vZeit # s_BA_Plan_MaxZeit;
            end
          else if (s_BA_Plan_MaxDat=vDat) and (s_BA_Plan_MaxZeit<vZeit) then begin
            vZeit # s_BA_Plan_MaxZeit;
          end;
        end;
      end;

    end;

    vItem # aList->CteRead(_CteNext, vItem);
  END;

  if (vDat=31.12.2099) then begin
    vDat  # 0.0.0;
    vZeit # 0:0;
  end;

  VarInstance(Struct_BA_Plan, vBuf);

  aDat  # vDat;
  aZeit # vZeit;
end;


//========================================================================
// RecalcMaxDat
//
//========================================================================
sub RecalcMaxDat(aTree : int);
local begin
  vItem     : int;
  vItem2    : int;
  vDatEnde  : date;
  vTimEnde  : time;
end;
begin

  vItem # aTree->CteRead(_CteLast);
  if (vItem=0) then RETURN;

  WHILE (vItem<>0) do begin
    VarInstance(Struct_BA_Plan,HdlLink(vItem));
//debug('------------CHECKPOS:'+cnvai(s_BA_PLan_BAG)+'/'+cnvai(s_BA_Plan_Pos));
    // Output loopen...
    if (s_BA_Plan_ListOut<>0) then begin
      GetMinOutput(aTree, s_BA_Plan_ListOut, var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit);
      if (s_BA_Plan_MaxDat<>0.0.0) then begin
//        TerminModify(var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit, -s_BA_Plan_Dauer);
        Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit, cnvif(-s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);

//debug('set:'+cnvai(s_BA_Plan_Pos)+' pos auf '+cnvad(s_BA_PLan_MaxDat));
      end;
    end;

    vItem # aTree->CteRead(_CtePrev, vItem);
  END;
end;


//========================================================================
// RecalcMinDat
//
//========================================================================
sub RecalcMinDat(aTree : int);
local begin
  vItem     : int;
  vItem2    : int;
end;
begin

  vItem # aTree->CteRead(_CteFirst);
  if (vItem=0) then RETURN;

  WHILE (vItem<>0) do begin
    VarInstance(Struct_BA_Plan,HdlLink(vItem));
//debug('------------CHECKPOS:'+cnvai(s_BA_PLan_BAG)+'/'+cnvai(s_BA_Plan_Pos));
    // Input loopen...
    if (s_BA_Plan_ListIn<>0) then begin
      GetMaxInput(aTree, s_BA_Plan_ListIn, var s_BA_Plan_MinDat, var s_BA_Plan_MinZeit);
//debug('set:'+cnvai(s_BA_Plan_Pos)+' pos auf '+cnvad(s_BA_PLan_MinDat)+' '+cnvat(s_BA_Plan_MinZeit));
/*
      if (s_BA_Plan_MinDat<>0.0.0) then begin
        TerminModify(var s_BA_Plan_MinDat, var s_BA_Plan_MinZeit, vDauer);
      end;
*/
    end;

    vItem # aTree->CteRead(_CteNext, vItem);
  END;
end;


//========================================================================
// BAGNachTree
//
//========================================================================
sub BAGNachTree(
  aBAG  : int;
  aTree : int);
local begin
  Erx     : int;
  vItem   : int;
  vItem2  : int;
  vSort   : alpha;
  vStruct : int;
  vBuf702 : int;
  vDatEnde  : date;
  vTimEnde  : time;
end;
begin

  BAG.Nummer # aBAG;
  Erx # RecRead(700,1,0);   // BAG holen
  if (Erx>_rLocked) then RETURN;

  // existiert von dem BA schon irgendwas???
  vSort # cnvai(BAG.P.Nummer)+'|*';
//  vItem # aTree->CteRead(_CteFirst | _CteSearch, 0, vSort);
  vItem # aTree->CteRead(_CteFirst | _CteCustom | _CteSearch, 0, vSort);
  if (vItem<>0) then RETURN;  // JA -> ENDE

  vBuf702 # RekSave(702);

  Erx # RecLink(702,700,1,_recFirst);   // Positionen loopen...
  WHILE (Erx<=_rLocked) do begin

    vSort # cnvai(BAG.P.Nummer)+'|'+cnvai(BAG.P.Position);
    vItem # CteOpen(_CteItem);
    if (vItem<>0) then begin
      vItem->spID     # RecInfo(702,_RecID);
      vItem->spCustom # vSort;
      vItem->spName   # cnvai(BAG.P.Level,_fmtnumnogroup,0,3)+'|'+vSort;
      vStruct # VarAllocate(Struct_BA_Plan);
      if (vStruct<>0) then begin

      if (BAG.P.Typ.VSBYN) then BAG.P.Plan.Dauer # 0.0
      else if (BAG.P.Plan.Dauer=0.0) then BAG.P.Plan.Dauer # 24.0*60.0;
//if (BAG.p.position=6) then BAG.P.Fenster.MaxDat # 30.10.2008;
//if (BAG.p.position=8) then BAG.P.Fenster.MaxDat # 20.10.2008;
//if (BAG.p.position=7) then BAG.P.Fenster.MinDat # 10.10.2008;
//if (BAG.p.position=1) then BAG.P.Plan.StartDat # 10.10.2008;

        s_BA_PLan_BAG       # BAG.P.Nummer;
        s_BA_PLan_Pos       # BAG.P.Position;
        s_BA_Plan_StartDat  # BAG.P.Plan.StartDat;
        s_BA_Plan_StartZeit # BAG.P.Plan.StartZeit;
//        s_BA_Plan_EndDat    # BAG.P.Plan.EndDat;
//        s_BA_Plan_EndZeit   # BAG.P.Plan.EndZeit;
        s_BA_Plan_Reihenfolge # BAG.P.Reihenfolge; // Reihenfolge [07.01.2010/PW]
        s_BA_Plan_EndDat    # s_BA_Plan_StartDat;
        s_BA_Plan_EndZeit   # s_BA_Plan_StartZeit;
        s_BA_Plan_Dauer     # BAG.P.Plan.Dauer;
        s_BA_Plan_Res1      # BAG.P.Ressource.Grp;
        s_BA_Plan_Res2      # BAG.P.Ressource;

        s_BA_Plan_MinDat  # BAG.P.Fenster.MinDat;
        s_BA_Plan_MinZeit # BAG.P.Fenster.MinZei;
        s_BA_Plan_MaxDat  # BAG.P.Fenster.MaxDat;
        s_BA_Plan_MaxZeit # BAG.P.Fenster.MaxZei;
//        TerminModify(var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit, (-1.0) * s_BA_Plan_Dauer);
        Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_MaxDat, var s_BA_Plan_MaxZeit, cnvif(-s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);

        // Endtermin ausrechnen
//        TerminModify(var s_BA_Plan_EndDat, var s_BA_Plan_EndZeit, s_BA_Plan_Dauer);
        Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_EndDat, var s_BA_Plan_EndZeit, cnvif(s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);

        // Verknüpfung von Datenbereich mit dem Item Element
        HdlLink(vItem,vStruct);

        CteInsert(aTree,vItem); // in Baum einbinden


        // Input-Liste füllen...
        Erx # RecLink(701,702,2,_recFirst);
        WHILE (Erx<=_rLocked) do begin

          if (BAG.IO.MAterialtyp=c_IO_BAG) and (BAG.IO.VonBAG<>0) then begin

            if (s_BA_Plan_ListIn=0) then s_BA_Plan_ListIn  # CteOpen(_CteList);

            vItem2 # CteOpen(_CteItem);
            if (vItem2<>0) then begin
              vItem2->spID     # RecInfo(701,_RecID);
              vItem2->spName   # cnvai(BAG.IO.VonBAG)+'|'+cnvai(BAG.IO.VonPosition)+'|'+cnvai(BAG.IO.VonFertigung)+cnvai(BAG.IO.VonID);
//debug('ins IN:'+vItem2->spname+' -> '+cnvai(bag.p.position));
              CteInsert(s_BA_Plan_ListIn,vItem2); // in Liste einbinden
            end;
          end;

          Erx # RecLink(701,702,2,_recNext);
        END;


        // Output-Liste füllen...
        Erx # RecLink(701,702,3,_recFirst);
        WHILE (Erx<=_rLocked) do begin

          if (BAG.IO.MAterialtyp=c_IO_BAG) and (BAG.IO.NachBAG<>0) then begin

            if (s_BA_Plan_ListOut=0) then s_BA_Plan_ListOut  # CteOpen(_CteList);

            vItem2 # CteOpen(_CteItem);
            if (vItem2<>0) then begin
              vItem2->spID     # RecInfo(701,_RecID);
              vItem2->spName   # cnvai(BAG.IO.NachBAG)+'|'+cnvai(BAG.IO.NachPosition)+'|'+cnvai(BAG.IO.NachFertigung)+cnvai(BAG.IO.NachID);
//debug('ins OUT:'+cnvai(bag.p.position)+' -> '+ vItem2->spname);
              CteInsert(s_BA_Plan_ListOut,vItem2); // in Liste einbinden
            end;
          end;

          Erx # RecLink(701,702,3,_recNext);
        END;

      end;

    end;

    Erx # RecLink(702,700,1,_recNext);
  END;

  RekRestore(vBuf702);

  RecalcMinDat(aTree);
  RecalcMaxDat(aTree);
end;


//========================================================================
//  RecSave
//          vor Speicherung
//========================================================================
sub RecSave(
  aTreeObj  : int;
) : logic;
local begin
  vTmp      : int;
  vDatEnde  : date;
  vTimEnde  : time;
end;
begin
/*
  s_BA_Plan_StartDat  # cPlanDat;
  s_BA_Plan_StartZeit # cPlanZeit;
  s_BA_Plan_Dauer     # cPlanDauer;
  s_BA_Plan_Res1      # cPlanRes1;
  s_BA_Plan_Res2      # cPlanRes2;
*/
  s_BA_Plan_StartDat  # BAG.P.Plan.StartDat;
  s_BA_Plan_StartZeit # BAG.P.Plan.StartZeit;
  s_BA_Plan_Dauer     # BAG.P.Plan.Dauer;
  s_BA_Plan_Res1      # BAG.P.Ressource.Grp;
  s_BA_Plan_Res2      # BAG.P.Ressource;
  s_BA_Plan_Reihenfolge # BAG.P.Reihenfolge; // Reihenfolge [07.01.2010/PW]

  s_BA_Plan_EndDat    # s_BA_Plan_StartDat
  s_BA_Plan_EndZeit   # s_BA_Plan_StartZeit;

//  TerminModify(var s_BA_Plan_EndDat, var s_BA_Plan_EndZeit, s_BA_Plan_Dauer);
  Rso_Kal_Data:GetPlantermin(s_BA_Plan_Res1, var s_BA_Plan_EndDat, var s_BA_Plan_EndZeit, cnvif(s_BA_Plan_Dauer), var vDatEnde, var vTimEnde);

//  vTmp # cnvia($lb.BA1.P.Plantree->wpcustom);
  vTmp # cnvia(aTreeObj->wpcustom);
  if (vTmp<>0) then begin
    RecalcMinDat(vTmp);
    RecalcMaxDat(vTmp);
  end;

  RETURN true;
end;


//========================================================================
// CleanUp
//
//========================================================================
sub CleanUp(
  aTreeObj : int);
local begin
  vTree : int;
  vItem : int;
end;
begin

  if (aTreeObj->wpcustom<>'') then begin
    vTree # cnvia(aTreeObj->wpcustom);

    vItem # vTree->CteRead(_CteFirst);
    WHILE (vItem<>0) do begin
      VarInstance(Struct_BA_Plan,HdlLink(vItem));

      // ggf. Input-Liste löschen
      if (s_BA_Plan_ListIn<>0) then begin
        s_BA_Plan_ListIn->CteClear(true);
        s_BA_Plan_ListIn->CteClose();
      end;
      // ggf. Output-Liste löschen
      if (s_BA_Plan_ListOut<>0) then begin
        s_BA_Plan_ListOut->CteClear(true);
        s_BA_Plan_ListOut->CteClose();
      end;

      HdlLink(vItem,0);
      VarFree(Struct_BA_Plan);
      vItem # vTree->CteRead(_CteNext,vItem);
    END;

    vTree->CteClear(true);
    vTree->CteClose();
  end;
end;


//========================================================================
// PlanTerminOK
//
//========================================================================
sub PlanTerminOK() : int;
local begin
  Erx   : int;
end;
begin

  Erx # 0;
/*
  if (s_BA_Plan_StartDat<BAG.P.Fenster.MinDat) or
    ((s_BA_Plan_StartDat=BAG.P.Fenster.MinDat) and (s_BA_Plan_StartZeit<BAG.P.Fenster.MinZei)) then vOK # n;

  if (BAG.P.Fenster.MaxDat<>0.0.0) and
    ((s_BA_Plan_EndDat>BAG.P.Fenster.MaxDat) or
     ((s_BA_Plan_EndDat=BAG.P.Fenster.MaxDat) and (s_BA_Plan_EndZeit>BAG.P.Fenster.MaxZei))) then vOK # n;
*/

  if (BAG.P.Plan.StartDat<BAG.P.Fenster.MinDat) or
    ((BAG.P.Plan.StartDat=BAG.P.Fenster.MinDat) and (BAG.P.Plan.StartZeit<BAG.P.Fenster.MinZei)) then Erx # Erx + 1;

  if (BAG.P.Fenster.MaxDat<>0.0.0) and
    ((BAG.P.Plan.StartDat>BAG.P.Fenster.MaxDat) or
     ((BAG.P.Plan.StartDat=BAG.P.Fenster.MaxDat) and (BAG.P.Plan.StartZeit>BAG.P.Fenster.MaxZei))) then Erx # Erx + 2;

  RETURN Erx;
end;


//========================================================================
//  AutoPlanung_R
//
//========================================================================
sub AutoPlanung_R(
  opt aOhneKal : logic;    // 2022-08-31 AH
  ) : int;
local begin
  Erx       : int;
  vSel      : int;
  vSelName  : alpha;
  vDate1    : date;
  vTime1    : time;
  vDate2    : date;
  vTime2    : time;
  vCount    : int;
  vDT1      : caltime;
  vDT2      : caltime;
end;
begin

  // TERMINE LEER **********************************************************
  FOR Erx # RecLink(702,700,1,_RecFirst)  // Positionen loopen
  LOOP Erx # RecLink(702,700,1,_RecNext)
  WHILE (Erx<=_rLocked) do begin

    // VSB in Ruhe lassen !!!
    if (Bag.P.Aktion=c_Akt_VSB) and (BAG.P.Auftragsnr<>0) then begin
      Erx # Auf_data:Read(BAG.P.Auftragsnr, BAG.P.Auftragspos, n);
      if (Erx>=400) then begin
        Erx # RecRead(702,1,_recLock);
        if (Erx<>_rOK) then RETURN Erx;
        if (Auf.P.TerminZusage<>0.0.0) then
          BAG.P.Fenster.MaxDat  # Auf.P.TerminZusage
        else
          BAG.P.Fenster.MaxDat  # Auf.P.Termin1Wunsch;
        BAG.P.Plan.StartDat # BAG.P.Fenster.MaxDat;
        BAG.P.Plan.EndDat   # BAG.P.Fenster.MaxDat;
        Erx # BA1_P_Data:Replace(_recUnlock,'AUTO');
        if (Erx<>_rOK) then RETURN Erx;
      end;
      CYCLE;
    end;

    Erx # RecRead(702,1,_recLock);
    if (Erx<>_rOK) then RETURN Erx;
    BAG.P.Plan.StartDat   # 0.0.0;
    BAG.P.Plan.StartZeit  # 0:0;
    BAG.P.Plan.EndDat     # 0.0.0;
    BAG.P.Plan.EndZeit    # 0:0;
    Erx # BA1_P_Data:Replace(_recUnlock,'AUTO');
    if (Erx<>_rOK) then RETURN Erx;
  END;



  // ALLE Fenster updaten...
  Erx # BA1_P_Data:UpdateFenster();
  if (Erx<>_rOK) then RETURN Erx;

//  if (Msg(019999,'Automatisch rückwärt planen?',_WinIcoQuestion, _WinDialogYesNo,1)<>_WinidYes) then RETURN;


  // EINPLANEN *********************************************************
  FOR Erx # RecLink(702,700,4,_RecLast)     // Positionen RÜCKWÄRTS loopen
  LOOP Erx # RecLink(702,700,4,_recPrev)
  WHILE (Erx<=_rLocked) do begin

    // VSB in Ruhe lassen !!!
    if (Bag.P.Aktion=c_Akt_VSB) then CYCLE;

    if (BAG.P.Fenster.MaxDat=0.0.0) then CYCLE;
//debug('plane:'+cnvai(bag.p.position));

    vCount # 0;
    vDate2 # BAG.P.Fenster.MaxDat;
    vTime2 # BAG.P.Fenster.MaxZei;
    REPEAT

      Inc(vCount);

      vDate1 # vDate2;
      vTime1 # vTime2;

      // 2022-08-31 AH
      if (aOhneKal=false) then begin
        // ST 2022-07-11: Check Arbeitsgänge nicht einplanen
        if (Bag.P.Aktion <> c_BAG_Check) and
          (BAG.P.Aktion <> c_BAG_Versand) then begin    // 2022-07-14 AH
          if (Rso_Kal_Data:GetPlantermin(BAG.P.Ressource.Grp, var vDate1, var vTime1, cnvif((-1.0) * BAG.P.Plan.Dauer), var vDate2, var vTime2) =false) then
            RETURN -BAG.P.Position;
          if (CheckBelegung(vDate1, vTime1, var vDate2, var vTime2)=false) then
            CYCLE;
        end;
      end
      else begin
        vDT2->vpdate # vDate2;
        if (vTime2=24:00) then begin
          vDT2->vmDayModify(1);
          vTime2 # 0:0;
        end;
        vDT2->vptime # vTime2;

        vDT1 # vDT2;
        vDT1->vmSecondsModify(-60 * (cnvif(BAG.P.Plan.Dauer) + cnvif(Max(BAG.P.Plan.DauerPost, BAG.P.Plan.DauerPst2))));
        vDate1 # vDT1->vpdate;
        vTime1 # vDT1->vptime;
        vDate2 # vDT2->vpdate;
        vTime2 # vDT2->vptime;
      //debugx(cnvac(vDT1,_FmtCaltimeISO | _FmtCaltimeDate | _FmtCaltimeTimeHM | _FmtCaltimeUTC)+' bis '+cnvac(vDT2,_FmtCaltimeISO | _FmtCaltimeDate | _FmtCaltimeTimeHM | _FmtCaltimeUTC));
      //debugx(cnvad(vDate1)+'@'+cnvat(vTime1)+' bis '+cnvad(vDate2)+'@'+cnvat(vTime2));
      end;

      Erx # SetTermin(vDate1, vTime1, vDate2, vTime2);
      if (Erx<>_rOK) then RETURN Erx;
      BREAK;

    UNTIL (vCount>1000);
    if (vCount>1000) then begin
//        Msg(700006,cnvai(bag.p.position),0,0,0);
      RETURN -BAG.P.Position;
    end;

  END;

//  Msg(700005,'',0,0,0);

  RETURN _rOK; // alles OK
end;


//========================================================================
//  CheckBelegung
//
//========================================================================
sub CheckBelegung(
  aDate1  : date;
  aTime1  : time;
  var aDate2  : date;
  var aTime2  : time;
) : logic;
local begin
  Erx       : int;
  vBuf702   : int;
  vSel      : int;
  vSelName  : alpha;
  vOK       : logic;
  vQ        : alpha(4000);
  tErx      : int;
end;
begin

  vBuf702 # RekSave(702);

  RecBufClear(998);
  Sel.BAG.Res.Gruppe  # BAG.P.Ressource.Grp;
  Sel.BAG.Res.Nummer  # BAG.P.Ressource;
  Sel.Von.Datum       # aDate1;
  Sel.Von.Zeit        # aTime1;
  Sel.Bis.Datum       # aDate2;
  Sel.Bis.Zeit        # aTime2;

//debug('bumscheck: '+cnvad(aDate1)+' '+cnvat(aTime1)+' - '+cnvad(aDate2)+' '+cnvat(aTime2));
  vOK # Y;

  // ehemals Selektion 702 BA1_SCHNITTE
  vQ # '';
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );
  vQ # vQ + ' AND ( BAG.P.Plan.StartDat < Sel.bis.Datum OR ( BAG.P.Plan.StartDat = Sel.bis.Datum AND BAG.P.Plan.StartZeit < Sel.bis.Zeit ) ) ';
  vQ # vQ + ' AND ( BAG.P.Plan.EndDat > Sel.von.Datum OR ( BAG.P.Plan.EndDat = Sel.von.Datum AND BAG.P.Plan.EndZeit > Sel.von.Zeit ) ) ';

  // Selektion bauen, speichern und öffnen
  vSel # SelCreate( 702, 1 );
  tErx # vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0 );

  Erx # RecRead(702,vSel,_recfirst);
  if (Erx<>_rNoRec) then begin
    aDate2 # BAG.P.Plan.StartDat;
    aTime2 # BAG.P.Plan.StartZeit;
    vOK # n;
//debug('---bums bis '+cnvad(aDate2)+' '+cnvat(aTime2));
  end;

  SelClose(vSel);             // Selektion schliessen
  SelDelete(702,vSelName);    // temp. Selektion löschen
  vSel  # 0;

  RekRestore(vBuf702);

  RETURN vOK;
end;


//========================================================================
//  SetTermin
//
//========================================================================
sub SetTermin(
  aDate1  : date;
  aTime1  : time;
  aDate2  : date;
  aTime2  : time;
) : int;
local begin
  Erx       : int;
  vBuf701   : int;
  vBuf702   : int;
  vDat      : date;
  vZeit     : time;
  vRefTree  : int;
  vItem     : int;
end;
begin

//aDate # cnvdi(cnvid(aDate) - 1);

  if (BAG.P.Plan.StartDat=aDate1) and (BAG.P.Plan.StartZeit=aTime1) and
    (BAG.P.Plan.EndDat=aDate2) and (BAG.P.Plan.EndZeit=aTime2) then RETURN _rOK;

  Erx # RecRead(702,1,_recLock);
  if (Erx<>_rOK) then RETURN Erx;
  BAG.P.Plan.StartDat   # aDate1;
  BAG.P.Plan.StartZeit  # aTime1;
  BAG.P.Plan.EndDat     # aDate2;
  BAG.P.Plan.EndZeit    # aTime2;

  RunAFX('BAG.Plan.Data.SetTermin.Post','');    // 2022-07-14 AH

  Erx # BA1_P_Data:Replace(_recUnlock,'AUTO');
  if (Erx<>_rOK) then RETURN Erx;

  // ALLE Fenster updaten...
  Erx # BA1_P_Data:UpdateFenster();

  RETURN Erx;
end;


//========================================================================