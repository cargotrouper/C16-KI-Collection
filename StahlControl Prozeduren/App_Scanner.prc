@A+
//===== Business-Control =================================================
//
//  Prozedur  App_Scanner
//                  OHNE E_R_G
//  Info
//
//
//  11.09.2008  AI  Erstellung der Prozedur
//  04.04.2022  AH  ERX
//
//  Subprozeduren
//    SIB _LFS_InsertMat(aMat      : int;  var aPos  : int) : logic;
//    SUB LFS();
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen

//========================================================================
//  _LFS_InsertMat
//
//========================================================================
sub _LFS_InsertMat(
  aMat      : int;
  var aPos  : int) : logic;
local begin
  Erx : int;
end;
begin

  Mat.Nummer # aMat;        // Material holen...
  Erx # RecRead(200,1,0);
  if (Erx>_rLocked) then begin
    Msg(001003,Translate('Material')+' '+cnvai(aMat),0,0,0);
    RETURN false;
  end;

  if (Mat.AuftragsNr=0) then begin
    Msg(441007,cnvai(aMat),0,0,0);
    RETURN false;
  end;

  if ("Mat.Löschmarker"='*') then begin
    Msg(200006,'',0,0,0);
    RETURN false;
  end;

  if (Mat.Status>c_Status_bisFrei) and (Mat.Status<>c_STATUS_VSB) and (Mat.Status<>c_STATUS_VSBKonsi) then begin
    Msg(441002,'',0,0,0);
    RETURN false;
  end;

  Erx # RecLink(401,200,16,_RecFirst);      // Auftragspos holen
  if (Erx>_rLocked) then begin
    Msg(401999,Translate('Auftrag')+' '+cnvai(Mat.Auftragsnr)+'/'+cnvai(Mat.auftragspos),0,0,0);
    RETURN false;
  end;
  Erx # RecLink(400,401,3,_RecFirst);       // Kopf holen
  if (Erx>_rLocked) then RETURN false;


  if (Lfs.Kundennummer=0) then begin
    Lfs.Kundennummer    # Auf.P.Kundennr;
    Lfs.Kundenstichwort # Auf.P.KundenSW;
    Lfs.Zieladresse     # Auf.Lieferadresse;
    Lfs.Zielanschrift   # Auf.Lieferanschrift;
  end;

  if((Lfs.Kundennummer<>Auf.P.Kundennr) or
    (Lfs.Zieladresse<>Auf.Lieferadresse) or
    (Lfs.Zielanschrift<>Auf.Lieferanschrift)) then begin
    Msg(441006,'',0,0,0);
    RETURN false;
  end;

  // Position in temp. Lieferschein aufnehmen...
  RETURN Auf_Data:VLDAW_Pos_Einfuegen_Mat(Lfs.Nummer, var aPos, 0);

end;


//========================================================================
//  LFS
//
//========================================================================
sub LFS();
local begin
  vKLim : float;
  vPos  : int;
  vA    : alpha;
  vOK   : logic;
  vNr   : int;
end;
begin

  vPos # 1;

  if (Dlg_Standard:Standard_Small('1. Materialnr.',var vA)=false) then RETURN;

  vNr # cnvia(vA);
  if (vNr=0) then RETURN;

  RecBufClear(440);
  Lfs.Nummer        # myTmpNummer;
  Lfs.Anlage.Datum  # today;
  if (_LFS_InsertMat(vNr,var vPos)=false) then RETURN;

  // Kreditlimit prüfen...
  if ("Set.KLP.LFS-Druck"<>'') then
    if (Adr_K_Data:Kreditlimit(Auf.Rechnungsempf,"Set.KLP.LFS-Druck",n, var vKLim)=false) then RETURN;

  vOK # n;
  vPos # 2;
  REPEAT

    vA # '';
    if (Dlg_Standard:Standard_Small(cnvai(vPos)+'. Materialnr.',var vA)=true) then begin
      vNr # cnvia(vA);
      if (vNr=0) then CYCLE;
      if (_LFS_InsertMat(vNr,var vPos)=false) then begin
        Msg(441008,'',0,0,0);
      end;
      CYCLE;
    end;

    // weitere Positionen erfassen?
    if (Msg(000005,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIDYes ) then CYCLE;

    // Speichern?
    if (Msg(440002,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIdno) then begin

      // Cleanup...
      WHILE (RecLink(441,440,4,_RecFirst)=_rOk) do
        RekDelete(441,_recUnlock, 'AUTO');   // 10.07.2013 AH

      RETURN;
    end;

    vOk # y;
  UNTIL (vOK);

  if (Lfs_Data:SaveLFS()=false) then begin
    ErrorOutput;
    RETURN;
  end;

  // Drucken + Verbuchen?
  if (Msg(440003,'',_WinIcoQuestion, _WinDialogYesNo,0)=_WinIdYes) then begin
    Lfs_Data:Druck_LFS();
    Lfs_Data:Verbuchen(Lfs.Nummer, today, now);
    ErrorOutput;
  end;

end;

//========================================================================