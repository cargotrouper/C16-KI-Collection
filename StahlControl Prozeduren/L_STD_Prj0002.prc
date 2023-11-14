@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Prj0001
//                    OHNE E_R_G
//  Info
//
//
//  18.04.2017  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  OpenJSON      : Lib_JSON:OpenJson
  AddJSONInt    : Lib_JSON:AddJSONInt
  AddJSONAlpha  : Lib_JSON:AddJSONAlpha
  AddJSONDate   : Lib_JSON:AddJSONDate
  AddJSONFloat  : Lib_JSON:AddJSONFloat
  AddJSONBool   : Lib_JSON:AddJSONBool
  SaveXLS       : F_SQL:SaveXLS
  Print         : F_SQL:Print
  FinishList    : F_SQL:FinishList

  AddSort(a,b,c)  : a->WinLstDatLineAdd(Translate(b)); vHdl2->WinLstCellSet(c,2);

end;

declare StartList(aSort : alpha);

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Prj.BisStichwort    # 'ZZZ';
  Sel.Prj.BisTermin1      # 13.12.2099;
  Sel.Prj.BisTermin2      # 13.12.2099;
  Sel.Prj.Pos.BisDat1     # 13.12.2099;
  Sel.Prj.Pos.BisDat2     # 13.12.2099;
  Sel.Prj.Zeit.BisDat1    # 13.12.2099;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.PRJ0002',here+':AusSel');

  Sel_Main:AddSort(gMdi, 'Nummer',                'Nummer', true);
  Sel_Main:AddSort(gMdi, 'Starttermin',           'Termin');
  Sel_Main:AddSort(gMdi, 'Adresse',               'Adresse');
  Sel_Main:AddSort(gMdi, 'Stichwort',             'Stichwort');

  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort       : alpha;
end;
begin
  gSelected # 0;
  // StartList(Sel.Sortierung);
  StartList(vSort);
end;


//========================================================================
//
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'Prj0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONInt(vJSON, 'NurAdressnr', Sel.Prj.Adressnr);
  AddJSONAlpha(vJSON, 'VonStichwort', Sel.Prj.vonStichwort);
  AddJSONAlpha(vJSON, 'BisStichwort', Sel.Prj.bisStichwort);

  AddJSONAlpha(vJSON, 'NurBemerkung', Sel.Prj.Bemerkung);
  AddJSONAlpha(vJSON, 'NurProjektleiter', Sel.Prj.Leitung);
  AddJSONAlpha(vJSON, 'NurTeam', Sel.Prj.Team);

  AddJSONDate(vJSON, 'VonTerminStart', Sel.Prj.VonTermin1);
  AddJSONDate(vJSON, 'BisTerminStart', Sel.Prj.BisTermin1);
  AddJSONDate(vJSON, 'VonTerminEnde', Sel.Prj.VonTermin2);
  AddJSONDate(vJSON, 'BisTerminEnde', Sel.Prj.BisTermin2);

  AddJSONAlpha(vJSON, 'NurPosBezeichnung', Sel.Prj.Pos.Bezeichn);
  AddJSONAlpha(vJSON, 'NurPosWiedervorlage', Sel.Prj.Pos.Wiedervo);
  AddJSONInt(vJSON, 'NurPosStatus', Sel.Prj.Pos.Status);

  AddJSONDate(vJSON, 'VonPosDatumStart', Sel.Prj.Pos.VonDat1);
  AddJSONDate(vJSON, 'BisPosDatumStart', Sel.Prj.Pos.BisDat1);
  AddJSONDate(vJSON, 'VonPosDatumEnde', Sel.Prj.Pos.VonDat2);
  AddJSONDate(vJSON, 'BisPosDatumEnde', Sel.Prj.Pos.BisDat2);

  AddJSONAlpha(vJSON, 'NurZeitUser', Sel.Prj.Zeit.User);
  AddJSONDate(vJSON, 'VonZeitDatumStart', Sel.Prj.Zeit.VonDat1);
  AddJSONDate(vJSON, 'BisZeitDatumStart', Sel.Prj.Zeit.BisDat1);
//		public List<int> NurProjektnummern { get; set; }

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================