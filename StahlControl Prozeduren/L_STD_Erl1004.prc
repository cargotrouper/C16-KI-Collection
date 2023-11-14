@A+
//===== Business-Control =================================================
//
//                    OHNE E_R_G
//  09.09.2021 SR SQL-Umänderung (Kopie von L_STD_Erl0004)
//
//  Info
//
//
//  13.12.2016  ST  Bugfix: PLZ Übergabe
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
  Sel.Adr.Von.LKZ         # '';
  Sel.Adr.Bis.LKZ         # 'ZZZ';
  Sel.Adr.Von.PLZ         # '';
  Sel.Adr.Bis.PLZ         # '999999';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl1004',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort',       'KundenSW', true);
//  Sel_Main:AddSort(gMdi, 'Rechnungsdatum',        'Rechnungsdatum');
  Sel_Main:AddSort(gMdi, 'Land * PLZ',            'LKZ,PLZ');
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
  AddJsonInt(   vJSON,  'NurKundenNr',          "Sel.Adr.Von.Kdnr");
  AddJsonInt(   vJSON,  'VonRechnungsnummer',   "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisRechnungsnummer',   "Sel.Fin.bis.Rechnung");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");
  AddJsonAlpha( vJSON,  'VonLKZ',               "Sel.Adr.von.LKZ");
  AddJsonAlpha( vJSON,  'BisLKZ',               "Sel.Adr.bis.LKZ");
  AddJsonAlpha( vJSON,  'VonPLZ',               "Sel.Adr.von.PLZ");
  AddJsonAlpha( vJSON,  'BisPLZ',               "Sel.Adr.bis.PLZ");

  AddJsonInt(   vJSON,  'NurVertreterNr',       "Sel.Adr.von.Vertret");
  AddJsonInt(   vJSON,  'NurVerbandNr',         "Sel.Adr.von.Verband");

  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitGeloeschten',       "Sel.Fin.StornosYN");
  AddJsonBool(  vJSON,  'MitGutBel',            "Sel.Fin.GutschriftYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;


//========================================================================