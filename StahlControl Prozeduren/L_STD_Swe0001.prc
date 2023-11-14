@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_SWE0001
//                    OHNE E_R_G
//  Info
//    Gibt eine Sammelwareneingangsliste aus
//
//  15.06.2015  ST  Erstellung der Prozedur, Work in Progress:
//      Fehlt noch: Selektionsdialog, Verknüpfung Selektonsfelder an Übergabe
//  13.12.2018  ST
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

  Sel.Auf.bis.ZTermin    # 31.12.2099;
  Sel.Auf.bis.WTermin    # 31.12.2099;
  Sel.Auf.bis.LiefDat    # 31.12.2099;

  Sel.Auf.bis.WGr        # 59999;
  Sel.Auf.bis.Dicke      # 999999.00;
  Sel.Auf.bis.Breite     # 999999.00;
  "Sel.Auf.bis.Länge"    # 999999.00;

/*
  Sel.Auf.RahmenYN       # n;
  Sel.Auf.AbrufYN        # y;
  Sel.Auf.NormalYN       # n;
  Sel.Auf.OffeneYN       # n;
*/
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.SWE0001',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Nummer',                'Nummer');    // SWE.Nummer
  Sel_Main:AddSort(gMDI, 'Abmessung',             'Abmessung');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',         'Artikelnr');
  Sel_Main:AddSort(gMdi, 'Lieferantennr',         'Lieferantnr', true);
  Sel_Main:AddSort(gMdi, 'Avisierungsdatum',      'Avisdatum');
  Sel_Main:AddSort(gMdi, 'Eingangsdatum',         'Eingangsdatum');
  Sel_Main:AddSort(gMdi, 'Qualität * Abmessung',  'Guete,Abmessung');

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
  vForm   # 'SWe0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  // ----------------------------------------------------------
  AddJsonInt(   vJSON,  'VonNummer',        "Sel.Auf.von.Nummer");
  AddJsonInt(   vJSON,  'BisNummer',        "Sel.Auf.bis.Nummer");
  AddJsonInt(   vJSON,  'NurLieferantenNr', "Sel.Auf.Lieferantnr");
  AddJsonDate(  vJSON,  'VonTermin',        "Sel.Auf.von.Datum");
  AddJsonDate(  vJSON,  'BisTermin',        "Sel.Auf.bis.Datum");
  AddJsonInt(   vJSON,  'NurVersandard',    "Sel.Auf.von.AufArt");
  AddJsonInt(   vJSON,  'NurSpediteur',     "Sel.Auf.Kundennr");
  AddJsonAlpha( vJSON,  'NurUrsprungsland', "Sel.Adr.von.LKZ");

  AddJsonDate(  vJSON,  'VonDatumAvisiert',  Sel.Auf.von.ZTermin);
  AddJsonDate(  vJSON,  'BisDatumAvisiert',  Sel.Auf.bis.ZTermin);
  AddJsonDate(  vJSON,  'VonDatumEingang',   Sel.Auf.von.WTermin);
  AddJsonDate(  vJSON,  'BisDatumEingang',   Sel.Auf.bis.WTermin);
  AddJsonDate(  vJSON,  'VonDatumAusfall',   Sel.Auf.von.LiefDat);
  AddJsonDate(  vJSON,  'BisDatumAusfall',   Sel.Auf.bis.LiefDat);
  AddJsonInt(   vJSON,  'VonWarengruppe',    Sel.Auf.von.Wgr);
  AddJsonInt(   vJSON,  'BisWarengruppe',    Sel.Auf.bis.Wgr);
  AddJsonAlpha( vJSON,  'NurArtikelnummer',  Sel.Auf.Artikelnr);

  AddJsonAlpha( vJSON,  'NurGuetenstufe',   "Sel.Mat.Gütenstufe");
  AddJsonAlpha( vJSON,  'NurGuete',         "Sel.Auf.Güte");

  AddJsonFloat( vJSON,  'VonDicke',       Sel.Auf.von.Dicke);
  AddJsonFloat( vJSON,  'BisDicke',       Sel.Auf.bis.Dicke);
  AddJsonFloat( vJSON,  'VonBreite',      Sel.Auf.von.Breite);
  AddJsonFloat( vJSON,  'BisBreite',      Sel.Auf.bis.Breite);
  AddJsonFloat( vJSON,  'VonLaenge',      "Sel.Auf.von.Länge");
  AddJsonFloat( vJSON,  'BisLaenge',      "Sel.Auf.bis.Länge");

  /*
  AddJsonBool(  vJSON,  'MitAvisiert',    Sel.Auf.RahmenYN);
  AddJsonBool(  vJSON,  'MitEingang',     Sel.Auf.AbrufYN);
  AddJsonBool(  vJSON,  'MitAusfall',     Sel.Auf.NormalYN);
  AddJsonBool(  vJSON,  'MitGeloeschten', Sel.Auf.OffeneYN);
  */
  FinishList(vForm, vDesign, var vJSON);
end;

//========================================================================
