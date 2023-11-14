@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ZEin0001
//                    OHNE E_R_G
//  Info
//
//  24.05.2017  TM  Erstellung der Prozedur
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

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Adr.von.KdNr          # 0;
  Sel.von.Datum             # 0.0.0;
  Sel.bis.Datum             # today;
  "Sel.Fin.!GelöschteYN"    # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.ZEin0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Eingangsdatum',         'Eingangsdatum');
  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort',       'KundenSW', true);
  Sel_Main:AddSort(gMDI, 'Zahlungseingang',       'Zahlungseingang');;
  Sel_Main:AddSort(gMdi, 'Zahldatum',             'Zahldatum');
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
  vForm   # 'ZEin0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'NurKundenNr',    "Sel.Adr.Von.Kdnr");
  AddJsonDate(  vJSON,  'VonZahldatum',   "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisZahldatum',   "Sel.bis.Datum");

  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'NurOffene',      "Sel.Fin.!GelöschteYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================