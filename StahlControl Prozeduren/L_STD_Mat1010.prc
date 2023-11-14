@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Mat1010
//                    OHNE E_R_G
//  Info      Inventur-Soll
//
//
//  25.05.2021 SR SQL-Umänderung (Kopie von L_STD_Mat0010)
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
  StartList(Sel.Sortierung);

/***
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Std.Mat0001',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Lagerort-Stichwort',    'Lageradresse');
  Sel_Main:AddSort(gMDI, 'Materialnummer',        'Nummer', true);
  Sel_Main:AddSort(gMDI, 'Qualität * Abmessung',  'Guete,Abmessung');
  Sel_Main:AddSort(gMDI, 'Ringnummer',            'Ringnr');
  Sel_Main:AddSort(gMDI, 'Werksnummer',           'Werksnr');
  Sel_Main:AddSort(gMDI, 'Artikelnr.',            'Strukturnr');

  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
***/
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
  StartList(Sel.Sortierung);
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

  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);
//  AddJSONInt(vJSON, 'Lageradresse', Sel.Mat.Lagerort);
//  AddJSONInt(vJSON, 'Lageranschrift', Sel.Mat.Lageranschri);
  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================