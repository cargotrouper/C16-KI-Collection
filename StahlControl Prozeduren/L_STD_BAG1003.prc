@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_BAG1003
//                    OHNE E_R_G
//  Info
//      Startet den Druck der BA Liste 3: Fertigmeldungen
//
//  01.07.2021 SR SQL-Umänderung (Kopie von L_STD_BAG0003)
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
  "Sel.Auf.Bis.Nummer"  # 9999999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.BAG1003',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Nummer',             'Nummer', true);
  Sel_Main:AddSort(gMDI, 'Produktionsdatum',   'Produktionsdatum');

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
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------

  AddJSONInt(vJSON,   'VonBagNummer', "Sel.Auf.Von.Nummer");
  AddJSONInt(vJSON,   'BisBagNummer', "Sel.Auf.Bis.Nummer");
  AddJSONDate(vJSON,  'VonProduktionsdatum', Sel.Von.Datum);
  AddJSONDate(vJSON,  'BisProduktionsdatum', Sel.Bis.Datum);
	AddJSONInt(vJSON,   'NurRessourcengruppe', Sel.BAG.Res.Gruppe);
	AddJSONInt(vJSON,   'NurRessource', Sel.BAG.Res.Nummer);

  // ----------------------------------------------------------
  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================