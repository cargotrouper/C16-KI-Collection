@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Erl0006
//                    OHNE E_R_G
//  Info  Projektcontrolling ReInOut
//
//  29.11.2016  ST  Erstellung der Prozedur
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
end;

declare StartList(aSort : alpha);

local begin
  vDatVon     : date;
  vDatBis     : date;
  vZukunft    : logic;
  vDetailed   : logic;
  vDauerFrist : int;
  vKontostand : float;
  vUstTag     : int;
end;



//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  Sel.bis.Datum       # today;
  Sel.Auf.bis.Projekt # 999999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl0006',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Datum',          'Datum',true);
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
//
//========================================================================
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'Erl0004';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJsonDate(  vJSON,  'DatumVon',       "Sel.von.Datum");
  AddJsonDate(  vJSON,  'DatumBis',       "Sel.bis.Datum");
  AddJsonInt(   vJSON,  'ProjektVon',     "Sel.Auf.von.Projekt");
  AddJsonInt(   vJSON,  'ProjektBis',     "Sel.Auf.bis.Projekt");
  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================