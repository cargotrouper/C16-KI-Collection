@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Art0008
//                    OHNE E_R_G
//  Info
//
//
//  09.05.2017  TM  Erstellung der Prozedur
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Art0008',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Datum',         'Datum', true);

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
  vForm   # 'Art0008';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // Selektion Lagerjournal innerhalb Datumsbereich
  AddJSONAlpha(vJSON,'NurArtikelnr', Sel.Art.Von.ArtNr);
  AddJSONDate(vJSON, 'VonDatum', Sel.von.Datum);
  AddJSONDate(vJSON, 'BisDatum', Sel.bis.Datum);

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================