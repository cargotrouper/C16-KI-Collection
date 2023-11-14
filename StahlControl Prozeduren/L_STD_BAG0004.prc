@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_BAG0004
//                    OHNE E_R_G
//  Info
//      Startet den Druck der BA Liste 4: Auswertung nach Coils
//      Projekt 1326/509
//
//  31.10.2016  ST  Erstellung der Prozedur
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

  Sel.bis.Datum   # today;
  Sel.Mat.bis.WGr # 59999;
  Sel.Mat.ObfNr2  # 999;


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.BAG0004',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Abmessung',        'Abmessung', true);
  Sel_Main:AddSort(gMDI, 'Materialnummer',   'Materialnummer');

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
  vForm   # 'BAG0004';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJSONDate(vJSON,  'VonProduktionsdatum', Sel.Von.Datum);
  AddJSONDate(vJSON,  'BisProduktionsdatum', Sel.Bis.Datum);
	AddJSONInt(vJSON,   'NurRessourcengruppe', Sel.BAG.Res.Gruppe);
	AddJSONInt(vJSON,   'NurRessource', Sel.BAG.Res.Nummer);

  AddJSONInt(vJSON,   'VonWarengruppe', "Sel.Mat.von.WGr");
  AddJSONInt(vJSON,   'BisWarengruppe', "Sel.Mat.bis.WGr");

  AddJSONInt(vJSON,   'VonOberflaeche', "Sel.Mat.ObfNr");
  AddJSONInt(vJSON,   'BisOberflaeche', "Sel.Mat.ObfNr2");



  // ----------------------------------------------------------
  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================