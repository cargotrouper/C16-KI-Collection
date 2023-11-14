@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ArtInv0008 (Basis: L_BSP_ArtInv5010)
//                    OHNE E_R_G
//  Info      Inventurmengen aufgenommen
//
//
//  01.10.2020  ST  Erstellung der Prozedur   Projekt 2042/158/3
//  08.11.2021  ST  Erweiterung Lohn/Fremdmaterial Projekt 2222/86/3
//  15.11.2021  ST  Übernahme in Standard
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


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.ArtInv0008',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Artikelnummer',         'ArtikelCharge');
  Sel_Main:AddSort(gMDI, 'Materialnummer',        'Materialnr');
  Sel_Main:AddSort(gMDI, 'Inventurnummer',        'Nummer',true);
  Sel_Main:AddSort(gMDI, 'Lagerort+Lagerplatz',   'LagerortLagerplatz');


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

  vForm   # 'Art0010';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================
