@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Ein0009
//                    OHNE E_R_G
//  Info
//    Gibt die Auftragsliste für Hesse aus
//
//  2023-03-14  SR  Erstellung der Prozedur
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
  Sel.Auf.bis.ZTermin    # 31.12.2099;
  Sel.Auf.bis.AufArt     # 999;
  Sel.Auf.bis.WGr        # 59999;
  Sel.Auf.bis.KostenSt   # 9999;

  Sel.Auf.RahmenYN       # y;
  Sel.Auf.AbrufYN        # y;
  Sel.Auf.NormalYN       # y;
  Sel.Auf.OffeneYN       # n;
  Sel.Mat.EigenYN        # y;
  Sel.Mat.BestelltYN     # y;
  Sel.BAG.MitOffenYN     # y;
  Sel.BAG.MitAbgeschYN   # y;

  // ----------------------------------------------------------
  Sel.Auf.ObfNr2         # 999;
  Sel.Auf.bis.Dicke      # 999999.00;
  Sel.Auf.bis.Breite     # 999999.00;
  "Sel.Auf.bis.Länge"    # 999999.00;
  Sel.Mat.bis.Dicke     # 999999.00;
  Sel.Mat.bis.Breite    # 999999.00;
  // ----------------------------------------------------------
  // nur Artikelnummer
  Sel.Auf.Artikelnr # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Ein0009',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Abmessung',             'Abmessung');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Bestellnr.',            'Bestellnr');
  Sel_Main:AddSort(gMdi, 'Lieferanten-Stichwort', 'Lieferant', true);
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
  vForm   # 'Ein0009';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  
  AddJsonInt(   vJSON,  'VonBestellnummer', "Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisBestellnummer', "Sel.Auf.bis.Nummer");
  AddJsonDate(  vJSON,  'VonBestelldatum',  "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisBestelldatum',  "Sel.Auf.bis.Datum");
  AddJsonDate(  vJSON,  'VonWunschtermin',  "Sel.Auf.von.WTermin");
  AddJsonDate(  vJSON,  'BisWunschtermin',  "Sel.Auf.bis.WTermin");
  AddJsonDate(  vJSON,  'VonZusagetermin',  "Sel.Auf.von.ZTermin");
  AddJsonDate(  vJSON,  'BisZusagetermin',  "Sel.Auf.bis.ZTermin");
  AddJsonInt(   vJSON,  'VonVorgangsart',   "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisVorgangsart',   "Sel.Auf.bis.AufArt");
  AddJsonInt(   vJSON,  'VonWarengruppe',   "Sel.Auf.von.Wgr");
  AddJsonInt(   vJSON,  'BisWarengruppe',   "Sel.Auf.bis.Wgr");
  AddJsonInt(   vJSON,  'VonKostenstelle',  "Sel.Auf.von.Kostenst");
  AddJsonInt(   vJSON,  'BisKostenstelle',  "Sel.Auf.bis.Kostenst");
  AddJsonInt(   vJSON,  'NurLieferantenNr', "Sel.Auf.Lieferantnr");
  AddJsonAlpha( vJSON,  'NurSachbearbeiter',"Sel.Auf.Sachbearbeit");
  AddJsonInt(   vJSON,  'NurProjektnummer', "Sel.Auf.Von.Projekt");
  AddJsonInt(   vJSON,  'NurAuftragsnummer',"Sel.Mat.von.MatNr");
  // ---------------------------------------------------------
  AddJsonBool(  vJSON,  'MitLiefervertrag',   "Sel.Auf.RahmenYN");
  AddJsonBool(  vJSON,  'MitAbruf',           "Sel.Auf.AbrufYN");
  AddJsonBool(  vJSON,  'MitNormal',          "Sel.Auf.NormalYN");
  AddJsonBool(  vJSON,  'MitGeloeschten',     "Sel.Auf.OffeneYN");
  AddJsonBool( vJSON,  'MitAnfragen',         "Sel.Mat.EigenYN");
  AddJsonBool( vJSON,  'MitBestellungen',     "Sel.Mat.BestelltYN");
  AddJsonBool( vJSON,  'MitKommissionierten', "Sel.BAG.MitOffenYN");
  AddJsonBool( vJSON,  'MitKommissionslosen', "Sel.BAG.MitAbgeschYN");
  // ---------------------------------------------------------
  AddJsonAlpha( vJSON,  'NurArtikelnummer',  "Sel.Auf.Artikelnr");
  AddJsonAlpha( vJSON,  'NurGuetenstufe',   "Sel.Auf.Gütenstufe");
  AddJsonAlpha( vJSON,  'NurGuete',         "Sel.Auf.Güte");
  AddJsonFloat( vJSON,  'VonDicke',         "Sel.Auf.von.Dicke");
  AddJsonFloat( vJSON,  'BisDicke',         "Sel.Auf.bis.Dicke");
  AddJsonFloat( vJSON,  'VonBreite',        "Sel.Auf.von.Breite");
  AddJsonFloat( vJSON,  'BisBreite',         "Sel.Auf.bis.Breite");
  AddJsonFloat( vJSON,  'VonLaenge',         "Sel.Auf.von.Länge");
  AddJsonFloat( vJSON,  'BisLaenge',         "Sel.Auf.bis.Länge");
  AddJsonFloat( vJSON,  'VonRID',         "Sel.Mat.von.Dicke");
  AddJsonFloat( vJSON,  'BisRID',         "Sel.Mat.bis.Dicke");
  AddJsonFloat( vJSON,  'VonRAD',         "Sel.Mat.von.Breite");
  AddJsonFloat( vJSON,  'BisRAD',         "Sel.Mat.bis.Breite");
  // ----------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================