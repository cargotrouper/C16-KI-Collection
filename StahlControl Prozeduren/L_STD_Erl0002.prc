@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Erl0002
//                    OHNE E_R_G
//  Info      für STATISTIKDATEI (899)
//
//  23.07.2015  AH  Erstellung der Prozedur
//  13.12.2016  ST  Erweiterung Um LKZ und PLZ
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
  Sel.Auf.bis.Nummer      # 99999999;
  Sel.Auf.bis.Datum       # today;
  Sel.Auf.bis.LiefDat     # today;
  Sel.Auf.bis.AufArt      # 9999;
  Sel.bis.Datum           # today;
  Sel.Auf.bis.WGr         # 59999;
  Sel.Auf.bis.Dicke       # 9999999.00;
  Sel.Auf.bis.Breite      # 9999999.00;
  "Sel.Auf.bis.Länge"     # 9999999.00;
  Sel.Adr.Bis.LKZ         # 'ZZZ';
  Sel.Adr.Bis.PLZ         # 'ZZZZZ';
  //Sel.Fin.StornosYN
  //Sel.Fin.GutschriftYN

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Erl0002',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Auftragsnummer',        'Auftragsnr');
  Sel_Main:AddSort(gMdi, 'Güte * Abmessung',      'Guete,Abemssung');
  Sel_Main:AddSort(gMdi, 'Kunden-LKZ',            'KundenLKZ');
  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr');
  Sel_Main:AddSort(gMdi, 'Kundenstichwort',       'KundenSW');
  Sel_Main:AddSort(gMdi, 'Land * PLZ',            'LKZ,PLZ');
  Sel_Main:AddSort(gMDI, 'Rechnungsnr.',          'Rechnungsnr', true);
  Sel_Main:AddSort(gMdi, 'Rechnungsdatum',        'Rechnungsdatum');
  Sel_Main:AddSort(gMdi, 'Sachbearbeiter',        'Sachbearbeiter');
  Sel_Main:AddSort(gMdi, 'Vertreternummer',       'Vertreternr');

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
  vForm   # 'Erl0002';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------

  AddJsonInt(   vJSON,  'VonRechnungsnummer',   "Sel.Fin.von.Rechnung");
  AddJsonInt(   vJSON,  'BisRechnungsnummer',   "Sel.Fin.bis.Rechnung");
  AddJsonDate(  vJSON,  'VonRechnungsdatum',    "Sel.von.Datum");
  AddJsonDate(  vJSON,  'BisRechnungsdatum',    "Sel.bis.Datum");

  AddJsonInt(   vJSON,  'VonAuftragsnummer',    "Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisAuftragsnummer',    "Sel.Auf.bis.Nummer");
  AddJsonDate(  vJSON,  'VonAuftragsdatum',     "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisAuftragsdatum',     "Sel.Auf.bis.Datum");
  AddJsonDate(  vJSON,  'VonLieferdatum',       "Sel.Auf.von.LiefDat");
  AddJsonDate(  vJSON,  'BisLieferdatum',       "Sel.Auf.bis.LiefDat");
  AddJsonInt(   vJSON,  'VonVorgangsart',       "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'BisVorgangsart',       "Sel.Auf.bis.AufArt");
  AddJsonInt(   vJSON,  'VonWarengruppe',       "Sel.Auf.von.Wgr");
  AddJsonInt(   vJSON,  'BisWarengruppe',       "Sel.Auf.bis.Wgr");
  AddJsonInt(   vJSON,  'NurKundenNr',          "Sel.Auf.Kundennr");
  AddJsonAlpha( vJSON,  'NurKundenLKZ',         '');    // Muss für die Kompatibilität drin sein
  AddJsonAlpha( vJSON,  'VonLKZ',               "Sel.Adr.von.LKZ");
  AddJsonAlpha( vJSON,  'BisLKZ',               "Sel.Adr.bis.LKZ");
  AddJsonAlpha( vJSON,  'VonPLZ',               "Sel.Adr.von.PLZ");
  AddJsonAlpha( vJSON,  'BisPLZ',               "Sel.Adr.bis.PLZ");

  AddJsonInt(   vJSON,  'NurVertreterNr',       "Sel.Auf.Vertreternr");
  AddJsonInt(   vJSON,  'NurVerbandNr',         "Sel.Adr.von.Verband");
  AddJsonAlpha( vJSON,  'NurSachbearbeiter',    "Sel.Auf.Sachbearbeit");
  AddJsonInt(   vJSON,  'NurProjektnummer',     "Sel.Auf.Von.Projekt");

  AddJsonAlpha( vJSON,  'NurArtikelnummer',     "Sel.Auf.Artikelnr");
  AddJsonAlpha( vJSON,  'NurGuete',             "Sel.Auf.Güte");
  AddJsonFloat( vJSON,  'VonDicke',             "Sel.Auf.von.Dicke");
  AddJsonFloat( vJSON,  'BisDicke',             "Sel.Auf.bis.Dicke");
  AddJsonFloat( vJSON,  'VonBreite',            "Sel.Auf.von.Breite");
  AddJsonFloat( vJSON,  'BisBreite',            "Sel.Auf.bis.Breite");
  AddJsonFloat( vJSON,  'VonLaenge',            "Sel.Auf.von.Länge");
  AddJsonFloat( vJSON,  'BisLaenge',            "Sel.Auf.bis.Länge");

  // ---------------------------------------------------------

  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================