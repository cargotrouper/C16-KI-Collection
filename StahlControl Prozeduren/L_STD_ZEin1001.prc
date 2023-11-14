@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ZEin1001
//                    OHNE E_R_G
//  Info
//
//  17.09.2021 SR SQL-Umänderung (Kopie von L_STD_ZEin0001)
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.ZEin1001',here+':AusSel');
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
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
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