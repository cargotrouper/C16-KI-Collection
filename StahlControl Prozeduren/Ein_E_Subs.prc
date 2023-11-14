@A+
//==== Business-Control ==================================================
//
//  Prozedur    Ein_E_Subs
//                    OHNE E_R_G
//  Info
//
//
//  07.08.2009  AI  Erstellung der Prozedur
//  09.04.2010  AI  Versand
//  18.12.2014  AH  "LfE" achtet auf Bestellnummer der LfE für Selektion
//  15.02.2016  AH  LFE-Selektionsabfrage erweitert (laut HB)
//  10.05.2022  AH  ERX
//
//  Subprozeduren
//    SUB LfE() : logic;
//    SUB AusLFE();
//    SUB CopyAnalyse() : logic
//    SUB Versand();
//    SUB AusVersand();
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_Rights


//========================================================================
//  LfE
//
//========================================================================
sub LfE() : logic;
local begin
  Erx   : int;
  vHdl  : int;
  vQ    : alpha(4000);
  vQ2   : alpha(4000);
  vNr   : int;
end;
begin

  if (Rechte[Rgt_LfErklaerungen]=false) or
    (StrFind(Set.Module,'L',0)=0) or (Ein.E.Materialnr=0) then RETURN false;

  // nur echte Eingaänge dürfen!
  if (Ein.E.Eingang_Datum=0.0.0) then RETURN false;

  Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
  if (Erx<>_rOK) then begin
    Msg(200026,aint(Ein.E.Materialnr), 0,0,0);
    RETURN false;
  end;
  if (Mat.LfENr>0) then begin
    if (Msg(130000,aint(Mat.Nummer)+'|'+aint(Mat.LfENr), _WinIcoQuestion, _WinDialogYesNo, 1)<>_Winidyes) then RETURN false;

    if (Ein.P.MitLfEYN) then vNr # -1
    else vNr # 0;

    if (Mat_Subs:SetLFE(vNr)=false) then RETURN false;

    Msg(999998,'',0,0,0);
    RETURN true;
  end;


  if (Ein.P.MitLfEYN=false) then
    if (Msg(130001,'', _WinIcoQuestion, _WinDialogYesNo, 1)<>_Winidyes) then RETURN false;


  RecBufClear(130);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI, 'LfE.Verwaltung',here+':AusLfE');
  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ  # ''; vQ2 # '';
  Lib_Sel:QInt(var vQ, 'LfE.Lieferantennr', '=', Ein.E.Lieferantennr);
/***
  Lib_Sel:QDate(var vQ, 'LfE.Gültig.Ab',   '<=', Ein.E.Eingang_Datum);
  Lib_Sel:QDate(var vQ, 'LfE.Gültig.Bis',  '>=', Ein.E.Eingang_Datum);

  Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.E.Nummer);
  Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',   '=', Ein.E.Position);
  Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.E.Nummer, ') OR (');
  Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',  '=', 0);
  Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', 0,') OR (');
  vQ # vQ + ' AND (('+vQ2+'))';
***/
  // 22.01.2015
  Lib_Sel:QDate(var vQ2, 'LfE.Gültig.Ab',   '<=', Ein.E.Eingang_Datum);
  Lib_Sel:QDate(var vQ2, 'LfE.Gültig.Bis',  '>=', Ein.E.Eingang_Datum);
  Lib_Sel:Qint(var  vQ2, 'LfE.Einkaufsnr',   '=', 0);
  vQ # vQ + ' AND (('+vQ2+'';
  vQ2 # '';
  Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.E.Nummer);
  Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',   '=', Ein.E.Position);
  Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.E.Nummer, ') OR (');
  Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',  '=', 0);

  // Alternativ über den Liefervertrag suchen... 15.02.2016
  if (Ein.P.AbrufAufNr <> 0) then begin
    Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.P.AbrufAufNr, ') OR (');
    Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',  '=', Ein.P.AbrufAufPos);
    Lib_Sel:Qint(var vQ2, 'LfE.Einkaufsnr',   '=', Ein.P.AbrufAufNr, ') OR (');
    Lib_Sel:Qint(var vQ2, 'LfE.EinkaufsPos',  '=', 0);
  end;

  vQ # vQ + ') OR ('+vQ2+'))';

//debugx(vQ);

  vHdl # SelCreate(130, gkey);
  Erx # vHdl->SelDefQuery('', vQ);
  if (Erx != 0) then Lib_Sel:QError(vHdl);
  w_SelName # Lib_Sel:SaveRun(var vHdl,0,n);

  // loopen und alle ohne passende Struktur löschen
  Erx # RecRead(130,vHdl,_recfirst);
  WHILE (Erx<=_rMultikey) do begin

    FOR Erx # RecLink(131,130,1,_recFirst)
    LOOP Erx # RecLink(131,130,1,_recNext)
    WHILe (Erx<=_rLocked) do begin
      if (StrAdj(Ein.E.Intrastatnr,_strAll) =* StrAdj(LfE.S.Intrastatnr,_strAll)) then BREAK;
/**
      LfE.S.Intrastatnr # StrAdj(LfE.S.Intrastatnr, _StrAll);     // Alle LeerZeichen entfernen
      if (StrAdj(Ein.E.Intrastatnr, _StrAll) =* LfE.S.Intrastatnr) then BREAK;
      // Nur die ersten vier Zeichen prüfen...
      if (StrLen(LfE.S.Intrastatnr) = 4) then
        if (StrCut( StrAdj(Ein.E.Intrastatnr, _StrAll), 1, 4) = LfE.S.Intrastatnr) then BREAK;
**/

    END;
    if (Erx>_rLocked) then begin
      SelRecDelete(vHdl,130);
      Erx # RecRead(130,vHdl,0);
      Erx # RecRead(130,vHdl,0);
      CYCLE;
    end;

    Erx # RecRead(130,vHdl,_recNext);
  END;

  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;

  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusLFE
//========================================================================
sub AusLFE();
local begin
  Erx     : int;
  vHdl    : int;
end;
begin

  if (gSelected<>0) then begin
    RecRead(130,0,_RecId,gSelected);
    gSelected # 0;

    Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
    if (Erx<>_rOK) then begin
      Msg(999999,aint(__LINE__),0,0,0);
    end
    else begin
      if Mat_Subs:SetLFE(LfE.Nummer) then Msg(999998,'',0,0,0);
    end;

    vHdl # WinFocusget();   // LastFocus-Feld refreshen
    if (vHdl<>0) then vHdl->Winupdate(_WinUpdFld2Obj);
  end;

end;


//========================================================================
//  CopyAnalyse
//
//========================================================================
sub CopyAnalyse() : logic;
local begin
  Erx         : int;
  vItem       : handle;
  vMfile,vMid : int;
  vCount      : int;
  vBuf506     : int;
end;
begin

  // Ankerfunktion?
  if (RunAFX('Ein.E.Mat.Analyse.Copy','')<>0) then RETURN (AfxRes=_rOK);


  vBuf506 # RekSave(506);

  // Prüfung..................
  vCount # 0;
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>506) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(506,0,0,vMID);          // Satz holen
    if (Erx>_rLocked) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;
/***
    if (Ein.E.Nummer<>vBuf506->Ein.E.Nummer) or (Ein.E.Position<>vBuf506->Ein.E.Position) then begin
      RekRestore(vBuf506);
      Msg(506009,'',0,0,0);
      RETURN false;
    end;
***/
    if (Ein.E.EingangsNr=vBuf506->Ein.E.Eingangsnr) then begin
      RekRestore(vBuf506);
      Msg(506010,'',0,0,0);
      RETURN false;
    end;

    if (Ein.E.lieferantennr<>vBuf506->Ein.E.Lieferantennr) then begin
      RekRestore(vBuf506);
      Msg(506009,Translate('Lieferantennummer'),0,0,0);
      RETURN false;
    end;
    if (Ein.E.Coilnummer<>vBuf506->Ein.E.Coilnummer) then begin
      RekRestore(vBuf506);
      Msg(506009,Translate('Coilnummer'),0,0,0);
      RETURN false;
    end;
    if (Ein.E.Chargennummer<>vBuf506->Ein.E.Chargennummer) then begin
      RekRestore(vBuf506);
      Msg(506009,Translate('Chargennummer'),0,0,0);
      RETURN false;
    end;

    Inc(vCount)

    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;
  RekRestore(vBuf506);

  if (vCount=0) then RETURN true;
  if (Msg(506008,aInt(vCount),_WinIcoQuestion, _WinDialogYesNo,2)<>_winidYes) then RETURN true;


  // Kopieren........................
  TRANSON;
  vBuf506 # RekSave(506);
  vItem # gMarkList->CteRead(_CteFirst);
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>506) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    Erx # RecRead(506,0,0,vMID);          // Satz holen
    if (Erx>_rLocked) then begin
      vItem # gMarkList->CteRead(_CteNext,vItem);
      CYCLE;
    end;

    PtD_Main:Memorize(506);     // Protokolldaten merken

    Erx # RecRead(506,1,_recLock);
    if (Erx=_rLocked) then begin
      PtD_Main:Forget(506);
      RekRestore(vBuf506);
      TRANSBRK;
      Msg(506011,AInt(Ein.E.Eingangsnr),0,0,0);
      RETURN false;
    end;
    SbrCopy(vBuf506,5, 506,5);    // Analyse kopieren
    Erx # RekReplace(506,0,'AUTO');
    if (Erx<>_rOK) then begin
      PtD_Main:Forget(506);
      RekRestore(vBuf506);
      TRANSBRK;
      Msg(506011,AInt(Ein.E.Eingangsnr),0,0,0);
      RETURN false;
    end;

    // Vorgang buchen...
    if (Ein_E_Data:Verbuchen(n)=false) then begin
      PtD_Main:Forget(506);
      RekRestore(vBuf506);
      TRANSBRK;
      Error(506001,'');
      ErrorOutput;
      RETURN false;
    end;
    PtD_Main:Compare(506);    // Protokolliren


    vItem # gMarkList->CteRead(_CteNext,vItem);
  END;  // ...Marklist loopen

  RekRestore(vBuf506);
  TRANSOFF;

  Msg(999998,'',0,0,0);   // Erfolg !


  // Markierungen entfernen?
  if (Msg(998013,'',_WinIcoQuestion,_WinDialogYesNo,1)=_winIdYes) then begin
    vBuf506 # RekSave(506);
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
      if (vMFile<>506) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;

      Erx # RecRead(506,0,0,vMID);          // Satz holen
      if (Erx>_rLocked) then begin
        vItem # gMarkList->CteRead(_CteNext,vItem);
        CYCLE;
      end;

      vItem # gMarkList->CteRead(_CteNext,vItem);

      // Marker entfernen
      Lib_Mark:MarkAdd(506,n,y);
    END;
    RekRestore(vBuf506);
  end;


  RETURN true;
end;


//========================================================================
// Versand
//
//========================================================================
sub Versand();
local begin
  Erx : int;
end;
begin

  if (Ein.E.Materialnr=0) then RETURN;
  if (Ein.E.VSBYN=false) then RETURN;
  if ("Ein.E.Löschmarker"<>'') then RETURN;

  Erx # RecLink(200,506,8,_RecFirst); // Eingangsmaterial holen
  if (Erx<>_rOK) then RETURN;

  RecBufClear(655);
  VsP.Vorgangstyp       # c_VSPTyp_Ein;
  VsP.Vorgangsnr        # Ein.P.Nummer;
  VsP.VorgangsPos1      # Ein.P.Position;
  VsP.VorgangsPos2      # 0;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Dlg.Versandpool',here+':AusVersand');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusVersand
//
//========================================================================
sub AusVersand();
local begin
  vPool : int;
end;
begin

  if (gSelected<>0) then begin
    gSelected # 0;
    if (VsP_Data:SavePool()<>0) then begin
      Msg(999998,'',0,0,0);
      end
    else begin
      ErrorOutput;
    end;

  end;
end;

//========================================================================