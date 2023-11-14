@A+
//===== Business-Control =================================================
//
//  Prozedur  Kos_Subs
//                  OHNE E_R_G
//  Info
//
//
//  17.03.2016  AH  Erstellung der Prozedur
//  09.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB CopyMark()
//    SUB AusCopyDlg()
//
//========================================================================
@I:Def_Global

//========================================================================
//  CopyMark
//
//========================================================================
sub CopyMark()
local begin
  erx   : int;
  v581  : int;
  vAnz  : int;
end;
begin

  v581 # RecBufCreate(581);

  FOR Erx # RecLink(v581,580,1,_recFirst)
  LOOP Erx # RecLink(v581,580,1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    if (Lib_MarK:IstMarkiert(581, RecInfo(v581,_recID))) then
      inc(vAnz);
  END;

  RecBufDestroy(v581);

  if (vAnz=0) then begin
    Msg(580001,'',0,0,0);
    RETURN;
  end;

  If (Msg(580002,aint(vAnz),0,_WinDialogYesNo,_winidNo)<>_Winidyes) then begin
    RETURN;
  end;

  RecBufClear(998);
  Sel.bis.Datum           # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Mdi.Kos.Copy',here+':AusCopyDlg');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusCopyDlg
//
//========================================================================
sub AusCopyDlg();
local begin
  Erx   : int;
  v580  : int;
  v581  : int;
  v581b : int;
  vDat  : date;
  vNr   : int;
  vPos  : int;
end;
begin
  gSelected # 0;

  vNr   # "Sel.Fin.von.Rechnung";
  vDat  # Sel.Von.Datum;

  v580 # RecBufCreate(580);
  v580->Kos.K.Nummer # vNr;
  Erx # RecRead(v580,1,0);
  if (Erx>_rLocked) then begin
    Msg(580004,aint(Sel.Fin.Von.Rechnung),0,0,0);
    RecBufDestroy(v580);
    RETURN;
  end;

  if ((v580->Kos.K.Von.Datum<>0.0.0) and (vDat<v580->Kos.K.Von.Datum)) or
    ((v580->Kos.K.Bis.Datum<>0.0.0) and (vDat>v580->Kos.K.Bis.Datum)) then begin
    Msg(580003,'',0,0,0);
    RecBufDestroy(v580);
    RETURN;
  end;

  APPOFF();

  v581 # RekSave(581);

  Erx # RecLink(581,v580,1,_recLast);    // letzte Buchung holen
  if (Erx>_rLocked) then vPos # 1
  else vPos # Rek.Nummer + 1;

  RecBufDestroy(v580);


  FOR Erx # RecLink(581,580,1,_recFirst)
  LOOP Erx # RecLink(581,580,1,_recNext)
  WHILE (Erx<=_rLocked) do begin

    if (Lib_MarK:IstMarkiert(581, RecInfo(581,_recID))=false) then CYCLE;

    v581b # RekSave(581);

    Kos.Kopfnummer        # vNr;
    Kos.Wertstellungsdat  # vDat;
    REPEAT
      Kos.Nummer # vPos;
      Erx # RekInsert(581,0,'MAN');
      inc(vPos);
      if (Erx<>_rOK) then CYCLE;
    UNTIl (Erx=_rOK);

    RekRestore(v581b);
    RecRead(581,1,0);

  END;

  APPON();

  RekRestore(v581);

  Msg(999998,'',0,0,0);
end;


//========================================================================