@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_HuB0002
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
end;

declare StartList(aSort : alpha);

//========================================================================
//
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  Sel.Auf.bis.Nummer     # 99999999;
  Sel.Auf.bis.Datum      # 31.12.2099;
  Sel.Auf.bis.WTermin    # 31.12.2099;
  Sel.Auf.bis.WGr        # 59999;
  Sel.Auf.OffeneYN       # n;

  // ----------------------------------------------------------
  // nur Artikelnummer
  Sel.Auf.Artikelnr # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.HuB0002',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Bestellnr.',            'Bestellnr');
  Sel_Main:AddSort(gMdi, 'Lieferanten-Stichwort', 'Lieferant', true);
  Sel_Main:AddSort(gMdi, 'Wunschtermin',          'Wunschtermin');
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
  vForm   # 'HuB0002';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'VonBestellnummer', "Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisBestellnummer', "Sel.Auf.bis.Nummer");
  AddJsonDate(  vJSON,  'VonBestelldatum',  "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisBestelldatum',  "Sel.Auf.bis.Datum");
  AddJsonDate(  vJSON,  'VonWunschtermin',  "Sel.Auf.von.WTermin");
  AddJsonDate(  vJSON,  'BisWunschtermin',  "Sel.Auf.bis.WTermin");
  AddJsonInt(   vJSON,  'VonWarengruppe',   "Sel.Auf.von.Wgr");
  AddJsonInt(   vJSON,  'BisWarengruppe',   "Sel.Auf.bis.Wgr");
  AddJsonInt(   vJSON,  'NurLieferantenNr', "Sel.Auf.Lieferantnr");
  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitGeloeschten',   "Sel.Auf.OffeneYN");
  // ---------------------------------------------------------
  AddJsonAlpha( vJSON,  'NurArtikelnummer',  "Sel.Auf.Artikelnr");
  AddJsonAlpha( vJSON,  'NurLieferantenArtNr',  "Sel.Auf.Güte");
  // ----------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================