@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ArtInv0007  (Basis L_BSP_ArtInf5006)
//                    OHNE E_R_G
//  Info  Startet den Druck einer Liste Aller inventurdaten
//
//
//  24.04.2019  ST  Erstellung der Prozedur
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.ArtInv0007',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Materialnummer',    'Materialnr', true);
  Sel_Main:AddSort(gMdi, 'Custom',            'Custom_Sort');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
begin
  gSelected # 0;
  StartList(Sel.Sortierung);
end;


//========================================================================
//  StartList
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
  vMatStatus  : alpha(1000);
end
begin
  vForm   # 'Art0009';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================
