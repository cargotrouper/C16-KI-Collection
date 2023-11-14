@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ERe1002
//                    OHNE E_R_G
//  Info
//
//
//  21.09.2021 SR SQL-Umänderung (Kopie von L_STD_ERe0001)
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_PrintServer

declare StartList(aSort : alpha);

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  Sel.bis.Datum           # 13.12.2099;
  Sel.bis.Datum2          # 13.12.2099;
  Sel.Auf.Bis.AufArt      # 999;
  "Sel.Fin.!GelöschteYN"  # y;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Std.ERe1002',here+':AusSel');
  // Sel_Main:AddSort(gMdi, 'Artikelnummer',             'Artikelnr');

  // Sel_Main:AddSort(gMDI, 'Lieferant',          'Lieferant', true); //alt -vor 18.01.2017

  Sel_Main:AddSort(gMDI, 'Fälligkeit',         'Faelligkeit',true);
  Sel_Main:AddSort(gMDI, 'Lief.Stichwort',     'LieferSW');
  Sel_Main:AddSort(gMDI, 'Lieferant',          'Lieferant');
  Sel_Main:AddSort(gMDI, 'Rechnungsdatum',     'Rechnungsdatum');
  Sel_Main:AddSort(gMDI, 'Rechnungsnr',        'Rechnungsnr');
  Sel_Main:AddSort(gMDI, 'Skontodatum',        'Skontodatum');

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

 
  AddJsonInt(   vJSON,  'NurLieferantenNr',   "Sel.Adr.von.LiNr");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',  "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',  "Sel.bis.Datum");
  AddJsonDate(  vJSON,  'VonFaelligdatum',    "Sel.von.Datum2");
  AddJsonDate(  vJSON,  'BisFaelligdatum',    "Sel.bis.Datum2");
  AddJsonInt(   vJSON,  'VonRechnungsTyp',    "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisRechnungsTyp',    "Sel.Auf.bis.AufArt");
  
  // ---------------------------------------------------------
  
  AddJsonBool(  vJSON,  'MitAktiven',         "Sel.Fin.!GelöschteYN");
  AddJsonBool(  vJSON,  'MitGeloeschten',     "Sel.Fin.GelöschteYN");

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================