@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_OSt1001
//                    OHNE E_R_G
//  Info
//
//  14.09.2021 SR SQL-Umänderung (Kopie von L_STD_Ost0001)
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
  Sel.Von.Jahr  # DateYear(today)+1900;
  Sel.von.Monat # 1;
  Sel.Bis.Monat # 12;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Ost1001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Rang',                  'Rand', true);
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
  AddJsonAlpha(vJSON,   'Name',                 'KU:%');
  AddJsonInt(   vJSON,  'VonMonat',             Sel.Von.Monat);
  AddJsonInt(   vJSON,  'BisMonat',             Sel.Bis.Monat);
  AddJsonInt(   vJSON,  'Jahr',                 Sel.Von.Jahr);

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================