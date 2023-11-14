@A+
//===== Business-Control =================================================
//
//  Prozedur    BA1_FM_Subs
//                  OHNE E_R_G
//  Info
//
//
//  13.12.2007  AI  Erstellung der Prozedur
//  11.10.2021  AH  ERX
//
//  Subprozeduren
//  SUB Entfernen() : logic;
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights

//========================================================================
//  Entfernen
//
//========================================================================
sub Entfernen() : logic;
local begin
  Erx         : int;
  vBeistell   : logic;
end;
begin

//  Erx # RecLink(200,707,7,_recFirst);   // Material holen
//  if (erx>_rLocked) then begin
  Erx # Mat_data:Read(BAG.FM.Materialnr); // Material holen
  if (erx<200) then begin
    Msg(707015,aint(BAG.FM.Materialnr),0,0,0);
    RETURN false;
  end;


  FOR Erx # RecLink(204,200,14,_recFirst)     // Aktionen loopen
  LOOP Erx # RecLink(204,200,14,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (Mat.A.Aktionstyp=c_Akt_BA_Beistell) then begin
      vBeistell # y;
      BREAK;
    end;
  END;

  if (vBeistell) then begin
    if (Msg(707016,'',_WinIcoWarning,_WinDialogYesNo,0)=_winidNo) then begin
      RETURN false;
    end;
  end;

  if (BA1_FM_Data:Entfernen(false, (Set.Wie.BaRestore='S'))=false) then begin
    Error(707004,'');
    ErrorOutput;
    RETURN false;
  end;
  Msg(707003,'',0,0,0); // Erfolg

  RETURN true;
end;

/*** >>> BA1_FM_Main:Start
//========================================================================
//  ShowAlleFMs
//
//========================================================================
sub ShowAllFMs(
  aBAG      : int;
  aPos      : int;
  aProc     : alpha;
  aMuendig  : logic) : logic;
local begin
  vQ        : alpha(4000);
  vHdl      : int;
end;
begin
  if (Rechte[Rgt_BAG_FM]=false) then RETURN false;

  BAG.P.Nummer    # aBAG;
  BAG.P.Position  # aPos;
  Erx # RecRead(702,1,0);     // BA-Position holen
  BAG.Nummer      # aBAG;
  Erx # RecRead(700,1,0);

  RecBufClear(707);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'BA1.FM.Verwaltung',aProc,y);

  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));

  $ZL.BA1.FM->wpDbFileNo      # 707;
  $ZL.BA1.FM->wpDbKeyNo       # 1;
  gKey # 1;
  $ZL.BA1.FM->wpDbLinkFileNo  # 0;

  // Selektion aufbauen...
  vQ # '';
  vQ # vQ + 'BAG.FM.Nummer = '+AInt(aBAG)+' AND BAG.FM.Position = '+aint(aPos);

  vHdl # SelCreate(707, gKey);
  Erx # vHdl->SelDefQuery('', vQ);
  if (Exg != 0) then Lib_Sel:QError(vHdl);
  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

  // Liste selektieren...
  $ZL.BA1.FM->wpDbSelection # vHdl;

  $lb.BAG->wpCaption # AInt(aBAG) + '/' + aInt(aPos);
  Lib_GuiCom:RunChildWindow(gMDI);

  RETURN true;
end;
***/

//========================================================================