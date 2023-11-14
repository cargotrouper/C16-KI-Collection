@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Art1008
//                    OHNE E_R_G
//  Info
//
//
//  27.07.2021 SR SQL-Umänderung (Kopie von L_STD_Art0003)
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

  Sel.Bis.Datum           # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Art1008',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Datum',         'Datum');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',             'Artikelnr', true);
 
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
//  StartList
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
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // Selektion Lagerjournal innerhalb Datumsbereich
  AddJSONAlpha(vJSON,'NurArtikelnr', Sel.Art.Von.ArtNr);
  AddJSONDate(vJSON, 'VonDatum', Sel.von.Datum);
  AddJSONDate(vJSON, 'BisDatum', Sel.bis.Datum);

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================