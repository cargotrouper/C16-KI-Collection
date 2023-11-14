@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_HuB0001
//                    OHNE E_R_G
//  Info
//
//
//  16.03.2017  AH  Erstellung der Prozedur
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
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.Wgr         # 59999;
  Sel.Art.bis.Stichwor    # 'zzz';
  "Sel.Art.-VerfügbarYN"  # Y;
  "Sel.Art.+VerfügbarYN"  # Y;
  Sel.Art.OutOfSollYN     # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.HuB0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',             'Artikelnr', true);
  Sel_Main:AddSort(gMdi, 'Stichwort',                 'Stichwort');
  Sel_Main:AddSort(gMdi, 'Warengruppe * Stichwort',   'Warengruppe*Stichwort');
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
  vForm   # 'HuB0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONAlpha(vJSON, 'VonArtikelnr', Sel.Art.Von.ArtNr);
  AddJSONAlpha(vJSON, 'BisArtikelnr', Sel.Art.bis.ArtNr);
  AddJSONAlpha(vJSON, 'VonStichwort', Sel.Art.von.Stichwor);
  AddJSONAlpha(vJSON, 'BisStichwort', Sel.Art.bis.Stichwor);
  AddJSONInt(vJSON, 'VonWarengruppe', Sel.Art.von.Wgr);
  AddJSONInt(vJSON, 'BisWarengruppe', Sel.Art.bis.Wgr);
  AddJSONInt(vJSON, 'NurLieferant', Sel.Adr.von.LiNr);

  AddJSONBool(vJSON, 'MitUnterNull', "Sel.Art.-VerfügbarYN");
  AddJSONBool(vJSON, 'MitUeberNull', "Sel.Art.+VerfügbarYN");
  AddJSONBool(vJSON, 'NurUnterdeckung', Sel.Art.OutOfSollYN);

  AddJSONBool(vJSON, 'MitPreisen', Sel.HuB.EK.Auswahl);

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================