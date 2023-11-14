@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ArtInv0001
//                    OHNE E_R_G
//  Info  Startet den Druck einer Liste Aller inventurdaten
//
//
//  24.04.2019  ST  Erstellung der Prozedur
//  15.11.2021  ST  Übernahme in den Standard
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
/*
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.SachNr      # 'zzz';
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Art.bis.Stichwor    # 'zzz';
  "Sel.Art.-VerfügbarYN"  # Y;
  "Sel.Art.+VerfügbarYN"  # Y;
  Sel.Art.OutOfSollYN     # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Art0006',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',             'Artikelnr', true);
  Sel_Main:AddSort(gMdi, 'Stichwort',                 'Stichwort');
  Sel_Main:AddSort(gMdi, 'Artikelgruppe','Artikelgruppe');
  Sel_Main:AddSort(gMdi, 'Warengruppe * Stichwort',   'Warengruppe*Stichwort');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  */
  StartList(Sel.Sortierung);

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
  vMatStatus  : alpha(1000);
end
begin
  vForm   # 'Art0007';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONAlpha(vJSON, 'VonArtikelnr',       '');
  AddJSONAlpha(vJSON, 'BisArtikelnr',       'ZZZZZZZZZZZZZ');
  AddJSONBool(vJSON, 'MitEKPreisen',        false);
  AddJSONBool(vJSON, 'MitVKPreisen',        false);
  AddJSONBool(vJSON, 'MitSonstigenPreisen', false);


  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================
