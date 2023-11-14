@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Erl0011   IntrastarImport
//                    OHNE E_R_G
//  Info
//
//  29.09.2021  AH  Erstellung der Prozedur
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

  AlsLieferant : Sel.Adr.nurMarkeYN
end;

declare StartList(aSort : alpha);


//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
  AlsLieferant            # true;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl0011',here+':AusSel');
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
  vForm   # 'Erl0011';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'VonRechnungsnummer',   "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisRechnungsnummer',   "Sel.Fin.bis.Rechnung");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");
  AddJsonBool(   vJSON,  'AlsLieferant',        alsLieferant);
  AddJsonInt(   vJSON,  'VonStS',               Sel.Fin.Steuerschl1 );
  AddJsonInt(   vJSON,  'NachStS',              Sel.Fin.Steuerschl2 );
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================