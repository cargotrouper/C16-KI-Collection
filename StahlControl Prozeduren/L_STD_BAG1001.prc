@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_BAG1001
//                    OHNE E_R_G
//  Info
//
//
//  29.06.2021 SR SQL-Umänderung (Kopie von L_STD_BAG0001)
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
  "Sel.bis.Datum" # today;
  Sel.Auf.Bis.Nummer   #  999999;


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.BAG1001',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Startzeit',        'Startzeitpunkt', true);

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
  StartList(sel.Sortierung);
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
  AddJSONInt(vJSON, 'VonBagNummer', Sel.Auf.von.Nummer);
  AddJSONInt(vJSON, 'BisBagNummer', Sel.Auf.bis.Nummer);
  AddJSONInt(vJSON, 'NurRessourcengruppe', Sel.BAG.Res.Gruppe);
  AddJSONInt(vJSON, 'NurRessource', Sel.BAG.Res.Nummer);
  AddJSONDate(vJSON, 'VonStartdatum', Sel.Von.Datum);
  AddJSONDate(vJSON, 'BisStartdatum', Sel.Bis.Datum);
  // ----------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================
