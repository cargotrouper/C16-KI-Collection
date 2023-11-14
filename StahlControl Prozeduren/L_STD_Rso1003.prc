@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Rso1003
//                    OHNE E_R_G
//  Info
//
//
//  21.09.2021 SR SQL-Umänderung (Kopie von L_STD_Rso0001)
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
  //StartList(Sel.Sortierung);

  Sel.bis.Datum   # 13.12.2099;
  GV.Int.12       # 0;
  GV.Int.13       # 0;
  GV.Int.14       # 9999;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Rso1003',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Ressource',             'Ressource');

  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;
//========================================================================
//  StartList
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);
debugx('');
  AddJSONInt(vJSON, 'NurGruppe'   , GV.Int.12);
  AddJSONInt(vJSON, 'VonRessource', GV.Int.13);
  AddJSONInt(vJSON, 'BisRessource', GV.Int.14);
  AddJsonDate(vJSON, 'VonTermin'  , "Sel.von.Datum");
  AddJsonDate(vJSON, 'BisTermin'  , "Sel.bis.Datum");


  FinishList(vForm, vDesign, var vJSON);

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