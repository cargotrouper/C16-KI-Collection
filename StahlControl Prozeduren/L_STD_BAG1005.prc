@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_BAG1005
//                    OHNE E_R_G
//  Info
//
//
//
//  13.07.2021 SR SQL-Umänderung (Kopie von L_STD_BAG0002)
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
  "Sel.bis.Datum"       # today;
  Sel.BAG.MitOffenYN    # true;
  Sel.BAG.MitAbgeschYN  # true;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.BAG1005',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Nummer',             'Nummer', true);
  Sel_Main:AddSort(gMDI, 'Starttermin',        'Starttermin');

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
  StartList(vSort);
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
  AddJSONInt(vJSON,   'NurBagNummer', 0);
  AddJSONDate(vJSON,  'VonStartdatum', Sel.Von.Datum);
  AddJSONDate(vJSON,  'BisStartdatum', Sel.Bis.Datum);



  AddJSONAlpha(vJSON, 'NurAktion', '');
  AddJSONAlpha(vJSON, 'NurAktion2', '');
	AddJSONInt(vJSON,   'NurRessourcengruppe', 0);
	AddJSONInt(vJSON,   'NurRessource', 0);

  AddJSONBool(vJSON,  'MitEigen', true);
  AddJSONBool(vJSON,  'MitFremd', true);
  AddJSONBool(vJSON,  'MitOffen', Sel.BAG.MitOffenYN);
  AddJSONBool(vJSON,  'MitAbgeschlossen', Sel.BAG.MitAbgeschYN);
  AddJSONBool(vJSON,  'MitNormal', true);
  AddJSONBool(vJSON,  'MitVorlage', false);

  // ST 2016-08-16: Kann in Printserver benutzt werden
/*
  AddJSONDate(vJSON,  'VonFertidatum', 0.0.0);
  AddJSONDate(vJSON,  'BisFertigdatum', 31.12.2100);
*/
  // ----------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================