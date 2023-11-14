@A+
//==== Business-Control ==================================================
//
//  Prozedur    Sel.EK.HuB
//                    OHNE E_R_G
//  Info        Ruft einen Selektionsdialog für die Adressdatei auf
//              und gibt den Pointer auf die Selektionsmenge zurück
//
//  29.08.2003  ML  Erstellung der Prozedur
//
//
//========================================================================
@I:Def_Global

LOCAL begin
end;

//========================================================================
//
//
//========================================================================

MAIN () : int
local begin
  vID       : int;
  vSel      : int;
  vSelName  : alpha;
  vTmp      : int;
  vTmpName  : alpha;
  vItem     : int;
  vMFile    : int;
  vMID      : int;
end;
begin

  TODO('Selektion 190 STD-Selektion Sel_EK_HuB');

  SbrClear(998,3);
  Sel.HuB.EK.bis.Liefe  # 999999;
  Sel.HuB.EK.bis.Art    # 'ZZZZZZ';
  Sel.HuB.EK.bis.BestD  # 31.12.2099;
  Sel.HuB.EK.bis.WEDat  # 31.12.2099;

  vId # WinDialog('Sel.EK.HuB',_WinDialogCenter);
  If vId <> _WinIdOk then return 0

  vSel  # SelOpen();
  If vSel = 0 then return 0;
  vSelName # '~tmp.'+CnvAI(UserID(_UserCurrent),_FmtNumNoGroup | _FmtNumLeadZero,0,8);
  SelDelete(190,vSelName);
  SelCopy(190,'STD_SELEKTION',vSelName);
  SelRead(vSel,190,_SelLock,vSelName);
  If Sel.HuB.EK.Auswahl then begin
    vTmp  # SelOpen();
    If vTmp = 0 then return 0;
    vTmpName # '~tmp.'+CnvAI(UserID(_UserCurrent),_FmtNumLeadZero | _FmtNumLeadZero,0,8)+'.Base';
    SelDelete(190,vTmpName);
    SelCopy(190,'STD_SELEKTION',vTmpName);
    SelRead(vTmp,190,_SelLock,vTmpName);

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile=190) then begin
        RecRead(190,0,_RecId,vMID);
        SelRecInsert(vTmp,190);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

    SelRun(vSel,_SelDisplay | _SelBase,vTmpName);
    SelClose(vTmp);
    SelDelete(190,vTmpName);
  end else begin
    SelRun(vSel,_SelDisplay);
  end;

  RETURN vSel;

end;

//========================================================================