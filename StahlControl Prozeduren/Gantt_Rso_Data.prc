@A+
//===== Business-Control =================================================
//
//  Prozedur    Gantt_Rso_Data
//                OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  24.07.2012  ST  Farbänderung Walzen (Prj. 1326/269)
//  26.06.2013  AH  auf Viertelstunden-Raster gestellt
//  31.03.2022  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_BAG
@I:Def_aktionen

define begin
  cMAXGants : 5
  cAtomSize : 1
end

global Struct_Gantt_Rso begin
  s_Gt_Rso_DatVon     : date;
  s_Gt_Rso_DatBis     : date;
  s_Gt_Rso_Gantt      : int[cMAXGAnts];
  s_Gt_Rso_Label      : int[cMAXGAnts];
  s_Gt_Rso_ResList    : int;
  s_Gt_Rso_ResFirst   : int;
  s_Gt_Rso_ResLast    : int;
  s_Gt_Rso_Changed    : logic;
end;

declare RefreshAll();

//========================================================================
//  InsertLvl
//
//========================================================================
sub InsertIvl();
begin
end;


//========================================================================
//  RemoveallIvl
//
//========================================================================
sub RemoveAllIvl(
  aGanttGraph   : int;  // GanttGraph
  aObjType      : int;  // Objekttyp
)

// Alle Box-, Intervall- oder
// Linien-Objekte aus einem
// GanttGraph entfernen
local begin
  vObj          : int;  // Objekt
  vTemp         : int;  // Zwischenspeicher
end;
begin
  // Falls Objekt kein GanttGraph-Unterobjekt
  if ((aObjType != _WinTypeIvlBox) AND (aObjType != _WinTypeInterval) AND (aObjType != _WinTypeIvlLine)) then begin
    // Funktion abbrechen
    RETURN;
  end;

  // Objektaktualisierung deaktivieren
  WinUpdate(aGanttGraph,_WinUpdOff);

  // Erstes Unterobjekt vom Typ aObjType ermitteln
  vObj # aGanttGraph -> WinInfo(_WinFirst, 1, aObjType);
  // Solange Unterobjekte vom Typ aObjType vorhanden
  WHILE (vObj != 0) do begin
    // Nächstes Unterobjekt vom Typ aObjType ermitteln
    vTemp  # vObj -> WinInfo(_WinNext, 1, aObjType);

    // Objekt entfernen
    vObj -> WinGanttIvlRemove();

    vObj   # vTemp;
  END

  // Objektaktualisierung aktivieren
  WinUpdate(aGanttGraph,_WinUpdOn);
end;


//========================================================================
//  Init
//
//========================================================================
sub Init() : int;
local begin
  vTmp : int;
end;
begin
  vTmp # VarInfo(Struct_Gantt_Rso);
  if (vTmp=0) then
    vTmp # VarAllocate(Struct_Gantt_Rso);   // Struktur instanzieren

  RETURN vTmp;
end;


//========================================================================
//  Term
//
//========================================================================
sub Term();
local begin
  vTmp : int;
end;
begin

  vTmp # VarInfo(Struct_Gantt_Rso);
  if (vTmp<>0) then begin
    if (s_gt_Rso_ResList<>0) then begin
      s_gt_Rso_ResList->CteClear(true);
      s_gt_Rso_ResList->CteClose();
    end;
    VarFree(Struct_Gantt_Rso);
  end;

end;


//========================================================================
//  SetStruct
//
//========================================================================
sub SetStruct(
  aFeld       : alpha;
  aWert       : alpha;
  opt aWert2  : alpha
) : logic;
begin
  case aFeld of
    'DatVon'      : s_Gt_Rso_DatVon # cnvda(aWert);
    'DatBis'      : s_Gt_Rso_DatBis # cnvda(aWert);
    'Gantt'       : s_Gt_Rso_Gantt[cnvia(aWert)] # cnvia(aWert2);
    'Label'       : s_Gt_Rso_Label[cnvia(aWert)] # cnvia(aWert2);
    'Changed'     : s_Gt_Rso_Changed # (aWert<>'');
    'ResList'     : s_Gt_Rso_ResList # cnvia(aWert);
  end;
  RETURN true;
end;


//========================================================================
//  GetStruct
//
//========================================================================
sub GetStruct(
  aFeld   : alpha;
  opt aWert   : alpha;
) : alpha;
begin
  case aFeld of
    'DatVon'  : RETURN cnvad(s_Gt_Rso_DatVon);
    'DatBis'  : RETURN cnvad(s_Gt_Rso_DatBis);
    'Gantt'   : RETURN cnvai(S_Gt_Rso_Gantt[cnvia(aWert)]);
    'Changed' : if (s_Gt_Rso_Changed) then RETURN 'X' else RETURN '';
  end;

  RETURN '';
end;


//========================================================================
//  MoveTime
//
//========================================================================
sub MoveTime(aWert : int);
local begin
  vItem : int;
  vI    : int;
end;
begin

  vItem # s_gt_Rso_ResFirst;
  FOR vI # 1 loop inc(vI) WHILE (vI<cMAXGants) do begin

    if (s_Gt_Rso_Gantt[vI]<>0) then begin
      s_Gt_Rso_Gantt[vI]->wpCellOfsHorz # s_Gt_Rso_Gantt[vI]->wpCellOfsHorz + aWert;
    end;

    vItem # s_gt_Rso_ResList->CteRead(_CteNext,vItem);
  END;

end;


//========================================================================
//  MoveRes
//
//========================================================================
sub MoveRes(aWert : int);
local begin
  vItem   : int;
  vItem2  : int;
  vI      : int;
end;
begin

  if (aWert>0) then begin
    if (s_Gt_Rso_ResLast=0) then RETURN;

    vItem  # s_Gt_Rso_resFirst;
    vItem2 # s_Gt_Rso_resLast;
    WHILE (aWert>0) and (vItem2<>0) do begin
      Dec(aWert);
      vItem2 # s_gt_Rso_ResList->CteRead(_CteNext,vItem2);
      if (vItem2<>0) then
        vItem # s_gt_Rso_ResList->CteRead(_CteNext,vItem);
    END;
    if (vItem<>0) then s_Gt_Rso_resFirst # vItem;
    if (vItem2<>0) then s_Gt_Rso_resLast # vItem2;
  end;

  if (aWert<0) then begin
    if (s_Gt_Rso_ResFirst=0) then RETURN;

    vItem  # s_Gt_Rso_resFirst;
    vItem2 # s_Gt_Rso_resLast;
    WHILE (aWert<0) and (vItem<>0) do begin
      Inc(aWert);
      vItem # s_gt_Rso_ResList->CteRead(_CtePrev,vItem);
      if (vItem<>0) then
        vItem2 # s_gt_Rso_ResList->CteRead(_CtePrev,vItem2);
    END;
    if (vItem<>0) then s_Gt_Rso_resFirst # vItem;
    if (vItem2<>0) then s_Gt_Rso_resLast # vItem2;
  end;

  RefreshAll();
end;


//========================================================================
//  BuildStamp
//
//========================================================================
sub BuildStamp(
  aDat  : date;
  aTim  : time) : int;
local begin
  vI,vJ : int;
end;
begin
  vI # (CnvID(aDat) - CnvID(s_gt_Rso_DatVon)) * 24 * 4;
  vI # vI + cnvit(aTim) / (3600000/4);
  RETURN vI;
end;


//========================================================================
//  RefreshSpace
//
//========================================================================
sub RefreshSpace(aGantt : int);
local begin
  Erx     : int;
  vRect   : rect;
  vI1,vI2 : int;
  vI      : int;
  vAnf    : int;
  vEnd    : int;
  vBox    : int;
  vString : alpha(100);
end;
begin
  vRect:top     # 0;
  vRect:bottom  # vRect:Top + 91;

  Rso.Kal.Gruppe  # Rso.Gruppe;
  Rso.Kal.Datum   # s_gt_Rso_DatVon;
  Erx # RecRead(163,1,0)
  WHILE (Erx<=_rnokey) and (Rso.Kal.Gruppe=Rso.Gruppe) and
    (Rso.Kal.Datum>=s_gt_Rso_Datvon) and (Rso.Kal.Datum<=s_gt_Rso_Datbis) do begin

    RecLink(164,163,1,_recFirst);   // Tag holen

    vString # Rso_Kal_Data:CalcString();

    vAnf # 0;
    vEnd # 0;
    vI # 1;
    WHILE (vI<24*4) do begin
      vAnf # StrFind(vString,'+',vI);
      if (vAnf<>0) then begin
        vEnd # StrFind(vString,'-',vAnf);
        if (vEnd=0) then vEnd # (24 * 4)+1;
        vI1 # vAnf-1;
        vRect:Left    # ((CnvID(Rso.Kal.Datum) - CnvID(s_gt_Rso_datVon))*24*4 + vI1) *cAtomSize;
        vI2 # vEnd-1;
        vI2 # vI2 - vI1;
        vRect:Right   # vRect:Left + (vI2 * cAtomSize) - 1;
        vBox # aGantt->WinGanttBoxAdd(vRect,RGB(250,250,250),'Arbeitszeit');
        vBox->wphelptip # 'Arbeitszeit';
        vI # vEnd;
        end
      else begin
        vI # (24*4) + 1;
      end;
    END;

    Erx # RecRead(163,1,_recNext)
  END;

end;


//========================================================================
//  RefreshIvl_BAG
//
//========================================================================
sub RefreshIvl_BAG(aGantt : int);
local begin
  Erx   : int;
  vTop  : int;
  vLeft : int;
  vLen  : int;
  vIvl  : int;
end;
begin


/*
    BAG.P.Plan.StartDat   # 10.3.2008;
    BAG.P.Plan.StartZeit  # 12:00;
    BAG.P.Plan.EndDat     # 11.3.2008;
    BAG.P.Plan.EndZeit    # 9:00;
*/
    RecBufClear(702);
    BAG.P.Ressource.Grp # Rso.Gruppe;
    BAG.P.Ressource     # Rso.Nummer;
    BAG.P.Plan.StartDat # s_gt_rso_DatVon;
    Erx # RecRead(702,3,0);
    Erx # RecRead(702,3,0);


    // Fehler: Mit REFRESH Button werden BA Positionen doppelt angezeigt!!

    WHILE (Erx<=_rNoKey) and (BAG.P.Ressource.Grp=Rso.Gruppe) and (BAG.P.Ressource=Rso.Nummer) and
      (BAG.P.Plan.StartDat>=s_gt_rso_DatVon) and (BAG.P.Plan.StartDat<=s_gt_rso_DatBis) do begin

      vTop  # 0;
      vLeft # BuildStamp(BAG.p.Plan.StartDat, BAG.P.PLan.StartZeit) * cAtomSize;
// 10.07.2017 AH
      if (BAG.P.Plan.EndDat=0.0.0) and (BAG.p.Plan.StartDat<>0.0.0) then begin
        BAG.P.Plan.EndDat   # BAG.p.Plan.StartDat;
        BAG.P.Plan.EndZeit  # BAG.p.Plan.StartZeit;;
        Lib_Berechnungen:TerminModify(var BAG.p.Plan.EndDat, var BAG.P.PLan.EndZeit, BAG.P.Plan.Dauer);
      end;
      vLen  # BuildStamp(BAG.p.Plan.EndDat, BAG.P.PLan.EndZeit) * cAtomSize;
      vLen # vLen - vLeft;
      if (vLen<=0) then vLen # 1;
      vIvl # aGantt->WinGanttIvlAdd(vLeft,vTop,vLen,'',AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position));

      WHILE (vIvl=0) and (vTop<100) do begin
        vTop # vTop + 1;
        if (vTop>aGantt->wpCellCOuntVert) then aGantt->wpcellcountVert # vTop;
        vIvl # aGantt->WinGanttIvlAdd(vLeft,vTop,vLen,'',AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position));
      END;
      //debug('Start:' + cnvai(bag.p.nummer) + '/' + cnvai(bag.p.position) + cnvai(vIvl)+ '  ' + cnvai(vTop));

      If (vIvl <> 0) then begin
  //      vIvl->wpArea    # realtime(vIvl->wpArea,CnvIF(Rso.Rso.Dauer)/(60/gApS),y);
//        vIvl->wpHelpTip # 'BA '+cnvai(Bag.P.nummer)+'/'+cnvai(bag.p.position);
//        vIvl->wpID      # 1;
//        vIvl->wpCustom  # '999';
  //        vIvl->wpStyleIvl # _WinStyleIvlStandard;
        vIvl->wpHelpTip           # 'BA '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
        vIvl->wpID                # RecInfo(702,_RecId);
   //      vIvl->wpArea    # realtime(vIvl->wpArea,CnvIF(Rso.Rso.Dauer)/(60/gApS),y);
//        vIvl->wpID      # vX;

        vIvl->wpColBkg  # _WinColLightCyan;
        vIvl->wpColFg   # _WinColBlack;
        vIvl->wpCustom  # c_AKt_BA;
//        vIvl->wpStyleIvl # _WinStyleIvlStandard;
        case BAG.P.Aktion of
          c_BAG_Spalt : begin
            vIvl->wpColBkg  # _WinColLightYellow;
            vIvl->wpColFg   # _WinColBlack;
          end;
          c_BAG_Tafel, c_BAG_ABCOIL : begin
            vIvl->wpColBkg  # RGB(  0,255, 64);
            vIvl->wpColFg   # _WinColBlack;
          end;
          c_BAG_Kant : begin
            vIvl->wpColBkg  # _WinColMagenta;
            vIvl->wpColFg   # _WinColBlack;
          end;
          c_BAG_Obf,c_BAG_Gluehen : begin
            vIvl->wpColBkg  # RGB(255, 128,0);
            vIvl->wpColFg   # _WinColBlack;
          end;
          c_BAG_Walz : begin
            vIvl->wpColBkg  # _WinColLightBlue;
            //vIvl->wpColFg   # _WinColBlack;       // ST 2012-07-24
            vIvl->wpColFg   # _WinColWhite;
          end;
          c_BAG_QTeil : begin
            vIvl->wpColBkg  # RGB(254,109,243);
            vIvl->wpColFg   # _WinColBlack;
          end;
          //c_BAG_Ronden : begin
          //  vIvl->wpColBkg  # _WinColLightCyan;
          //  vIvl->wpColFg   # _WinColBlack;
          //end;
        end;
      end;

      Erx # RecRead(702,3,_RecNext);
    END;

  //

end;


//========================================================================
//  RefreshIvl_Wartung
//
//========================================================================
sub RefreshIvl_Wartung(aGantt : int);
local begin
  Erx   : int;
  vTop  : int;
  vLeft : int;
  vLen  : int;
  vIvl  : int;
end;
begin

  RecBufClear(165);
  Rso.IHA.Gruppe    # Rso.Gruppe;
  Rso.IHA.Ressource # Rso.Nummer;
  Rso.IHA.WartungYN # y;
  Rso.IHA.Termin    # s_GT_Rso_datVon;

  Erx # RecRead(165,2,0);   // Instandhaltungen loopen
  WHILE (Erx<=_rNoKey) and (Rso.IHA.Gruppe=Rso.Gruppe) and (RSO.IHA.Ressource=Rso.Nummer) and
    (Rso.IHA.WartungYN) and
    (Rso.IHA.Termin>=s_gt_rso_DatVon) and (Rso.IHA.Termin<=s_gt_rso_DatBis) do begin

    vTop  # 0;
    vLeft # BuildStamp(Rso.IHA.Termin, 0:0) * cAtomSize;
    vLen  # BuildStamp(Rso.IHA.DatumEnde, 24:00) * cAtomSize;
    vLen # vLen - vLeft;
    if (vLen<=0) then vLen # 1;
    vIvl # aGantt->WinGanttIvlAdd(vLeft,vTop,vLen,'',Translate('Wartung'));
    WHILE (vIvl=0) and (vTop<100) do begin
      vTop # vTop + 1;
      if (vTop>aGantt->wpCellCOuntVert) then aGantt->wpcellcountVert # vTop;
      vIvl # aGantt->WinGanttIvlAdd(vLeft,vTop,vLen,'',Translate('Wartung'));
    END;

    If (vIvl <> 0) then begin
      //vIvl->wpHelpTip           # 'BA '+AInt(BAG.P.Nummer)+'/'+AInt(BAG.P.Position);
      vIvl->wpID                # RecInfo(165,_RecId);
      vIvl->wpColBkg  # _WinColLightCyan;
      vIvl->wpColFg   # _WinColBlack;
      vIvl->wpCustom  # '165';
    end;

    Erx # RecRead(165,2,_RecNext);
  END;

  //

end;


//========================================================================
//  RefreshAll
//
//========================================================================
sub RefreshAll();
local begin
  vI    : int;
  vHdl  : int;
  vItem : int;
end;
begin

  // bisherige Elemente löschen...
  FOR vI # 1 loop inc(vI) WHILE (vI<cMAXGants) do begin
    if (s_Gt_Rso_Gantt[vI]<>0) then begin
      RemoveAllIvl( s_Gt_Rso_Gantt[vI],_WinTypeIvlBox);
      RemoveAllIvl( s_Gt_Rso_Gantt[vI],_WinTypeInterval);
      RemoveAllIvl( s_Gt_Rso_Gantt[vI],_WinTypeIvlLine);
    end;
  END;


  if (s_gt_Rso_ResFirst=0) then begin
    s_gt_Rso_ResFirst # s_gt_Rso_ResList->CteRead(_CteFirst);
  end;

  vItem # s_Gt_Rso_ResFirst;
  FOR vI # 1 loop inc(vI) WHILE (vI<cMAXGants) do begin

    // Ressource holen
    RecBufClear(160);
    if (vItem<>0) then
      if (vItem->spID<>0) then
        RecRead(160, 0,0, vItem->spID);

    // Gantts setzen...
    if (s_Gt_Rso_Gantt[vI]<>0) then begin
      vHdl # s_Gt_Rso_Gantt[vI]->WinSearch('Datum');
      if (vHdl<>0) then
        vHdl->wpScalaLabels # '$(DATE,'+CnvAD(s_gt_Rso_Datvon,_FmtDateLongYear)+','+CnvAD(s_gt_Rso_DatBis,_FmtDateLongYear)+',1,dd:MM:yyyy)';

      s_Gt_rso_Gantt[vI]->wpCellCountHorz # (CnvID(s_gt_Rso_DatBis) - CnvID(s_gt_Rso_DatVon)+1) * 24 * cAtomSize;
      s_Gt_rso_Gantt[vI]->wpColBkg # _WinColLightGray;
      s_Gt_rso_Gantt[vI]->winupdate(_WinUpdState, _WinGntRefresh);

      RefreshSpace(s_Gt_Rso_Gantt[vI]);
      RefreshIvl_Wartung(s_Gt_Rso_Gantt[vI]);
      RefreshIvl_BAG(s_Gt_Rso_Gantt[vI]);
    end;


    // Labels setzen...
    if (s_Gt_Rso_Label[vI]<>0) then begin
      s_Gt_Rso_Label[vI]->wpcaption # Rso.Stichwort;
      s_Gt_Rso_ResLast # vItem;
      if (vItem<>0) then
        vItem # s_gt_Rso_ResList->CteRead(_CteNext,vItem);
    end;

  END;

end;

//========================================================================