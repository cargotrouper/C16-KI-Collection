@A+
//===== Business-Control =================================================
//
//  Prozedur    Lfs_Subs
//                    OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  20.02.2014  AH  Erweiterungen für LFE
//  28.04.2014  AH  Neu: Zielort ändern
//  16.04.2021  AH  "KLimit.Freigabe"
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//
//  SUB CheckLfE() : logic
//  SUB Druck_LfE() : logic
//  SUB Calc_Stk(aObj : int);
//  SUB Calc_Gew(aObj : int; var aGew : float);
//  SUB ChangeZiel();
//  SUB AusZieladresse()
//  SUB AusZieladresse2()
//  SUB KLimit.Freigabe()
//
//========================================================================
@I:Def_Global
@I:Def_Aktionen
@I:Def_BAG
@I:Def_Rights


//========================================================================
// CheckLfE
//
//========================================================================
sub CheckLfE() : logic
local begin
  Erx   : int;
  vA    : alpha(4000);
end;
begin

  // LFE
  if (StrFind(Set.Module,'L',0)=0) then RETURN true;

  vA # '';
  FOR erx # RecLink( 441, 440, 4, _recFirst)
  LOOP erx # RecLink( 441, 440, 4, _recNext)
  WHILE (erx<=_rLocked) do begin

    if (Lfs.P.Auftragsnr=0) then CYCLE;
    if (Lfs.P.Materialnr=0) then CYCLE;

    erx # Auf_Data:Read(Lfs.P.Auftragsnr, Lfs.P.Auftragspos, n);
    if (erx<400) then CYCLE;

    erx # Mat_Data:Read(Lfs.P.Materialnr);
    if (erx<200) then CYCLE;

    // NICHT gültig?
    if (Auf.P.MitLfEYN) and (Mat.LfENr=0) then begin
      if (vA='') then vA # aint(Mat.Nummer)
      else vA # StrCut(vA + ', ' + aint(Mat.Nummer), 1, 3000);
    end;
  END;

  if (vA<>'') then begin

    if (gUsergroup  <> 'SOA_SERVER') then
      RETURN (Msg(130441,vA,_WinIcoWarning,_WinDialogYesNo,2)=_winidyes);
    else
      ERROR(130441,vA);
  end;

  RETURN true;
end;


//========================================================================
// Druck_LfE
//      Drucke die Lieferantenerklärungen
//========================================================================
sub Druck_LfE() : logic
local begin
  Erx   : int;
  vKLim : float;
  vA    : alpha(4000);
  v441  : int;
end;
begin

  if (StrFind(Set.Module,'L',0)=0) then RETURN false;

  If (CheckLfE()=false) then RETURN false;

  RecLink(100,440,2,_RecFirsT);   // Zieladresse holen
  Lib_Dokumente:Printform(440,'Lieferantenerklaerung',true);

  vA # '';
  FOR erx # RekLinkB( v441, 440, 4, _recFirst)
  LOOP erx # RekLinkB( v441, 440, 4, _recNext)
  WHILE (erx<=_rLocked) do begin

    if (v441->Lfs.P.Auftragsnr=0) then CYCLE;
    if (v441->Lfs.P.Materialnr=0) then CYCLE;

    erx # Auf_Data:Read(v441->Lfs.P.Auftragsnr, v441->Lfs.P.Auftragspos, n);
    if (erx<400) then CYCLE;

    erx # Mat_Data:Read(v441->Lfs.P.Materialnr);
    if (erx<200) then CYCLE;

    // LFE sollte gedruckt werden? -> dann Merken
    if (Auf.P.MitLfEYN) and (Mat.LfENr<>0) then begin
      RecBufClear(204);
      Mat.A.Materialnr    # Mat.Nummer;
      Mat.A.Aktionsmat    # Mat.Nummer;
      Mat.A.Aktionstyp    # c_akt_LFE;
      Mat.A.Aktionsdatum  # today;
      Mat.A.Aktion        # 0;
      Erx # Mat_A_data:Insert(0,'AUTO')
    end;

  END;
  RecBufDestroy(v441);

  Msg(130002,'',0,0,0);

  RETURN true;
end;


//========================================================================
//  Calc_Stk
//
//========================================================================
sub Calc_Stk(aObj : int);
local begin
  Erx : int;
end;
begin
  if (Lfs.P.Materialtyp=c_IO_Mat) then begin
    erx # RecLink(200,441,4,_recFirst);   // Material holen
    if (erx>_rLocked) then RecBufClear(200);
    erx # RecLink(819,200,1,_RecFirst);   // Warengruppe holen
    if (erx>_rlocked) then RecBufClear(819);
    "Lfs.P.Stück" # Lib_Berechnungen:Stk_aus_kgDBLDichte2(Lfs.P.Gewicht.Netto, Mat.Dicke, Mat.Breite, "Mat.LÄnge", Wgr_Data:GetDichte(Wgr.Nummer, 200), "Wgr.TränenKgProQM")
    end
  else begin
    erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
    if (erx>_rLocked) then RecbufClear(250);
    erx # RecLink(819,250,10,_RecFirst);  // Warengruppe holen
    if (erx>_rlocked) then RecBufClear(819);
    if ("Art.GewichtProStk"<>0.0) then
      "Lfs.P.Stück" # cnvif(Lfs.P.Gewicht.Netto / "Art.GewichtProStk");
  end;
  aObj->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  Calc_Gew
//
//========================================================================
sub Calc_Gew(
  aObj      : int;
  var aGew  : float);
local begin
  Erx : int;
end;
begin
  if (Lfs.P.Materialtyp=c_IO_Mat) then begin
    erx # RecLink(200,441,4,_recFirst);   // Material holen
    if (erx>_rLocked) then RecBufClear(200);
    erx # RecLink(819,200,1,_RecFirst);   // Warengruppe holen
    if (erx>_rlocked) then RecBufClear(819);
    aGew # Lib_Berechnungen:KG_aus_StkDBLDichte2("Lfs.P.Stück", Mat.Dicke, Mat.Breite, "Mat.LÄnge", Wgr_Data:GetDichte(Wgr.Nummer, 200), "Wgr.TränenKgProQM");
    end
//    SUB kg_aus_StkDBLDichte2(aStk : int; aD : float; aB : float; aL : float; aDichte : float; aTraene : float) : float;
  else begin
    erx # RecLink(250,401,2,_RecFirst);   // Artikel holen
    if (erx>_rLocked) then RecbufClear(250);
    erx # RecLink(819,250,10,_RecFirst);  // Warengruppe holen
    if (erx>_rlocked) then RecBufClear(819);
    aGew # cnvfi("Lfs.P.Stück") * "Art.GewichtProStk";
  end;
  aObj->winupdate(_WinUpdFld2Obj);
end;


//========================================================================
//  ChangeZiel
//
//========================================================================
SUB ChangeZiel();
begin

  if (Rechte[Rgt_Lfs_Change_Ziel]=false) then RETURN;

  if (Lfs_Data:Check_ChangeZiel(false)=false) then RETURN;

  RecBufClear(100);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.Verwaltung',here+':AusZieladresse');
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusZieladresse
//
//========================================================================
sub AusZieladresse()
local begin
  Erx   : int;
  vTmp  : int;
  vQ    : alpha;
  vHdl  : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(100,0,_RecId,gSelected);
  gSelected # 0;

  vTmp # RecLinkInfo(101,100,12,_recCount); // Mehr als eine Anschrift vorhanden?
  if (vTmp = 1) then begin
    if (Lfs_Data:ChangeZiel(Adr.Nummer,1)=false) then Msg(999999,'',0,0,0)
    else Msg(999998,'',0,0,0);
    RETURN;
  end;


  RecBufClear(101);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Adr.A.Verwaltung',here+':AusZieladresse2');

  VarInstance(WindowBonus,cnvIA(gMDI->wpcustom));
  vQ # '';
  Lib_Sel:QInt(var vQ, 'Adr.A.Adressnr', '=', Adr.Nummer);
  vHdl # SelCreate(101, 1);
  erx # vHdl->SelDefQuery('', vQ);
  if (erx <> 0) then
    Lib_Sel:QError(vHdl);
  // speichern, starten und Name merken...
  w_SelName # Lib_Sel:SaveRun(var vHdl, 0, n);
  // Liste selektieren...
  gZLList->wpDbSelection # vHdl;
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  AusZieladresse2
//
//========================================================================
sub AusZieladresse2()
local begin
  vTmp  : int;
  vQ    : alpha;
  vHdl  : int;
end;
begin
  if (gSelected=0) then RETURN;

  RecRead(101,0,_RecId,gSelected);
  gselected#  0;

  if (Lfs_Data:ChangeZiel(Adr.A.Adressnr, Adr.A.Nummer)=false) then Msg(999999,'',0,0,0)
  else Msg(999998,'',0,0,0);
end;


//========================================================================
//  KLimit.Freigabe
//========================================================================
sub KLimit.Freigabe()
local begin
  Erx   : int;
  vOK   : Logic;
end;
begin

  erx # RecLink( 441, 440, 4, _recFirst ); // erste Position holen
  if (erx>_rLocked) then RETURN;

  if (Lfs.P.Auftragsnr <> 0) and (Lfs.P.AuftragsPos <> 0) then begin
    erx # RecLink(401,441,5,_RecFirst);     // Auftragspos holen
    if (erx>_rLocked) then RETURN;
    erx # RecLink(400,401,3,0);             // Auftragskopf holen
    if (erx>_rLocked) then RETURN;
    erx # RecLink(100,400,1,_RecFirst);     // Kunde holen
    if (Adr.SperrKundeYN) then begin
      Msg(100005,Adr.Stichwort,0,0,0);
      RETURN;
    end;
    erx # RecLink(100,400,4,_recFirst);     // Rechnungsempfänger holen
    if (Adr.SperrKundeYN) then begin
      Msg(100005,Adr.Stichwort,0,0,0);
      RETURN;
    end;

    vOK # Adr_K_Data:GibtsLfsFreigabe(Lfs.Nummer, Auf.Nummer);
    if (vOK) then begin
      Msg(440008,'',0,0,0);
      RETURN;
    end;
    if (Msg(440009,'',_WinIcoQuestion,_Windialogyesno, 1)<>_Winidyes) then RETURN;
    if (Adr_K_Data:SetLfsFreigabe(Lfs.Nummer, Auf.Nummer, Lfs.Gesamtgewicht)) then
      Msg(999998,'',0,0,0)
    else
      Msg(999999,'',0,0,0);
  end;
    
end;


//========================================================================
