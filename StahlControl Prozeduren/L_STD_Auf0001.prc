@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Auf0001
//                    OHNE E_R_G
//  Info
//    Gibt die Auftragsliste aus
//
//  16.08.2013  ST  Erstellung der Prozedur
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

  Sel.Auf.bis.Nummer     # 99999999;
  Sel.Auf.bis.Datum      # 13.12.2099;
  Sel.Auf.bis.WTermin    # 13.12.2099;
  Sel.Auf.bis.ZTermin    # 13.12.2099;
  Sel.Auf.bis.AufArt     # 999
  Sel.Auf.bis.WGr        # 59999;

  Sel.Auf.Vorgangstyp    # 'AUF';   // NUR Aufträge

  Sel.Auf.RahmenYN       # y;
  Sel.Auf.AbrufYN        # y;
  Sel.Auf.NormalYN       # y;
  Sel.Auf.BerechenbYN    # y;
  "Sel.Auf.!BerechenbYN" # y;
  Sel.Auf.OffeneYN       # n;

  // ----------------------------------------------------------
  // Nur Gütenstufe
  // Nur Güte
  Sel.Auf.ObfNr2         # 999;
  Sel.Auf.bis.Dicke      # 999999.00;
  Sel.Auf.bis.Breite     # 999999.00;
  "Sel.Auf.bis.Länge"    # 999999.00;
  // ----------------------------------------------------------
  // nur Artikelnummer
  Sel.Auf.Artikelnr # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Auf0001',here+':AusSel');

  Sel_Main:AddSort(gMDI, 'Abmessung',             'Abmessung');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Auftragsnr.',           'Auftragsnr');
  Sel_Main:AddSort(gMdi, 'Bestellnummer',         'Bestellnr');
  Sel_Main:AddSort(gMdi, 'Kunden-Stichwort',      'Kunde', true);
  Sel_Main:AddSort(gMdi, 'Qualität * Abmessung',  'Guete,Abmessung');
  Sel_Main:AddSort(gMdi, 'Wunschtermin',          'Wunschtermin');
  Sel_Main:AddSort(gMdi, 'Zusagetermin',          'Zusagetermin');

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
  vForm   # 'Auf0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'VonAuftragsnummer',"Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisAuftragsnummer',"Sel.Auf.bis.Nummer");
  AddJsonDate(  vJSON,  'VonAuftragsdatum', "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisAuftragsdatum', "Sel.Auf.bis.Datum");
  AddJsonDate(  vJSON,  'VonWunschtermin',  "Sel.Auf.von.WTermin");
  AddJsonDate(  vJSON,  'BisWunschtermin',  "Sel.Auf.bis.WTermin");
  AddJsonDate(  vJSON,  'VonZusagetermin',  "Sel.Auf.von.ZTermin");
  AddJsonDate(  vJSON,  'BisZusagetermin',  "Sel.Auf.bis.ZTermin");
  AddJsonInt(   vJSON,  'VonVorgangsart',   "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisVorgangsart',   "Sel.Auf.bis.AufArt");
  AddJsonInt(   vJSON,  'VonWarengruppe',   "Sel.Auf.von.Wgr");
  AddJsonInt(   vJSON,  'BisWarengruppe',   "Sel.Auf.bis.Wgr");
  AddJsonInt(   vJSON,  'NurKundenNr',      "Sel.Auf.Kundennr");
  AddJsonInt(   vJSON,  'NurVertreterNr',   "Sel.Auf.Vertreternr");
  AddJsonAlpha( vJSON,  'NurSachbearbeiter',"Sel.Auf.Sachbearbeit");
  AddJsonAlpha( vJSON,  'NurVorgangstypen', "Sel.Auf.Vorgangstyp");
  AddJsonInt(   vJSON,  'NurProjektnummer', "Sel.Auf.Von.Projekt");
  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitLiefervertrag', "Sel.Auf.RahmenYN");
  AddJsonBool(  vJSON,  'MitAbruf',         "Sel.Auf.AbrufYN");
  AddJsonBool(  vJSON,  'MitNormal',        "Sel.Auf.NormalYN");
  AddJsonBool(  vJSON,  'MitDollar',        "Sel.Auf.BerechenbYN");
  AddJsonBool(  vJSON,  'OhneDollar',       "Sel.Auf.!BerechenbYN");
  AddJsonBool(  vJSON,  'MitGeloeschten',   "Sel.Auf.OffeneYN");
  // ---------------------------------------------------------
  AddJsonAlpha( vJSON,  'NurArtikelnummer', "Sel.Auf.Artikelnr");
  AddJsonAlpha( vJSON,  'NurGuetenstufe',   "Sel.Auf.Gütenstufe");
  AddJsonAlpha( vJSON,  'NurGuete',         "Sel.Auf.Güte");
//  AddJsonInt(   vJSON,  'VonOberflaeche',   "Sel.Auf.ObfNr");
//  AddJsonInt(   vJSON,  'BisOberflaeche',   "Sel.Auf.ObfNr2");
  AddJsonFloat( vJSON,  'VonDicke',         "Sel.Auf.von.Dicke");
  AddJsonFloat( vJSON,  'BisDicke',         "Sel.Auf.bis.Dicke");
  AddJsonFloat( vJSON,  'VonBreite',        "Sel.Auf.von.Breite");
  AddJsonFloat( vJSON,  'BisBreite',        "Sel.Auf.bis.Breite");
  AddJsonFloat( vJSON,  'VonLaenge',        "Sel.Auf.von.Länge");
  AddJsonFloat( vJSON,  'BisLaenge',        "Sel.Auf.bis.Länge");
  // ----------------------------------------------------------
//  AddJsonFloat( vJSON,  'VonZugfestigkeit',  "Sel.Mat.von.Zugfest");
//  AddJsonFloat( vJSON,  'BisZugfestigkeit',  "Sel.Mat.bis.Zugfest");

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================