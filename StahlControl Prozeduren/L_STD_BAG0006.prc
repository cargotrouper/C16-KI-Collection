@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_BAG0006
//                    OHNE E_R_G
//  Info
//      BA-Fertigungsliste z.B. für BSP
//
//  23.10.2018  AH  Erstellung der Prozedur
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

  Sel.Mat.bis.WGr   # 59999;
  Sel.BAG.Nummer    # 0;
  Sel.Auf.Kundennr  # 0;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.BAG0006',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Kunde',            'Kunde', true);

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
  vForm   # 'BAG0005';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------

  AddJSONInt(vJSON,   'VonWarengruppe', "Sel.Mat.von.WGr");
  AddJSONInt(vJSON,   'BisWarengruppe', "Sel.Mat.bis.WGr");
  AddJSONInt(vJSON,   'NurBagNummer', Sel.BAG.Nummer);
  AddJSONInt(vJSON,   'NurKundenNr', Sel.Auf.Kundennr);

  // ----------------------------------------------------------
  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================