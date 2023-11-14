@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Kos0001
//                    OHNE E_R_G
//  Info
//
//
//  15.03.2016  AH  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

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
  Sel.bis.Datum           # today;
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.Fin.Bis.Kostenst    # 99999999;
  Sel.Fin.Bis.Gegenkto    # 99999999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Kos0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Gegenkonto*Kostenstelle*Datum',   'GKD', true);
  Sel_Main:AddSort(gMdi, 'Gegenkonto*Kostenstelle*Adresse', 'GKA');
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
  vForm   # 'Kos0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonDate(  vJSON,  'VonDatum',             "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisDatum',             "Sel.bis.Datum");
  AddJsonInt(   vJSON,  'VonKostenkopf',        "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisKostenkopf',        "Sel.Fin.bis.Rechnung");
  AddJsonInt(   vJSON,  'VonGegenkonto',        "Sel.Fin.von.Gegenkto");
  AddJsonInt(   vJSON,  'BisGegenkonto',        "Sel.Fin.bis.Gegenkto");
  AddJsonInt(   vJSON,  'VonKostenstelle',      "Sel.Fin.von.Kostenst");
  AddJsonInt(   vJSON,  'BisKostenstelle',      "Sel.Fin.bis.Kostenst");

  // ---------------------------------------------------------
//  AddJsonBool(  vJSON,  'MitGeloeschten',       "Sel.Fin.StornosYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================