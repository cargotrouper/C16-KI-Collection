@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_OfP1002
//                    OHNE E_R_G
//  Info
//
//  14.09.2021 SR SQL-Umänderung (Kopie von L_STD_OfP0001)
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
  Sel.Adr.von.KdNr          # 0;
  Sel.von.Datum             # 0.0.0;
  Sel.bis.Datum             # today;
  Sel.von.Datum2            # 0.0.0;
  Sel.bis.Datum2            # 31.12.2020;
  "Sel.Fin.!GelöschteYN"    # y;
  "Sel.Fin.GelöschteYN"     # n;
  Sel.Fin.nurMarkeYN        # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.OfP1002',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Fälligkeit',            'Faelligkeit');
  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort',       'KundenSW', true);
  Sel_Main:AddSort(gMDI, 'Rechnungsnr.',          'Rechnungsnr');;
  Sel_Main:AddSort(gMdi, 'Rechnungsdatum',        'Rechnungsdatum');
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
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");
  AddJsonDate(  vJSON,  'VonFaelligkeitsdatum',  "Sel.von.Datum2");
  AddJsonDate(  vJSON,  'BisFaelligkeitsdatum',  "Sel.bis.Datum2");
  AddJsonInt(   vJSON,  'NurVertreterNr',       "Sel.Adr.von.Vertret");
  AddJsonInt(   vJSON,  'NurVerbandNr',         "Sel.Adr.von.Verband");
  AddJsonAlpha( vJSON,  'NurSachbearbeiter',    "Sel.Adr.Von.Sachbear");
  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitGeloeschten',       "Sel.Fin.GelöschteYN");
  AddJsonBool(  vJSON,  'MitAktiven',           "Sel.Fin.!GelöschteYN");
  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================