@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Er1010
//                    OHNE E_R_G
//  Info        KUNDENHITLISTE
//
//  14.09.2021 SR SQL-Umänderung (Kopie von L_STD_Erl0001)
//
//
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
end;

declare StartList(aSort : alpha);


//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
  //Sel.Fin.StornosYN
  //Sel.Fin.GutschriftYN

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl1010',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Kundennummer' , 'Kundennummer');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort' , 'Kundenstichwort');
  Sel_Main:AddSort(gMDI, 'Erlös Summe'  , 'Erl_Summe', true);
  Sel_Main:AddSort(gMdi, 'Dechungsbeitrag'     , 'DB_Summe');
  Sel_Main:AddSort(gMdi, 'Deckungsb. %'   , 'DB_Prozent');


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
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------

  AddJsonInt(   vJSON,  'VonRechnungsnummer',   "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisRechnungsnummer',   "Sel.Fin.bis.Rechnung");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");
  AddJsonInt(   vJSON,  'NurVertreterNr',       "Sel.Adr.von.Vertret");
  AddJsonInt(   vJSON,  'NurVerbandNr',         "Sel.Adr.von.Verband");

  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitGeloeschten',       "Sel.Fin.StornosYN");
  AddJsonBool(  vJSON,  'MitGutBel',            "Sel.Fin.GutschriftYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================