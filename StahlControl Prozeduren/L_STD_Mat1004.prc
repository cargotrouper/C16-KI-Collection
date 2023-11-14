@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Mat1004
//                    OHNE E_R_G
//  Info
//
//
//  21.05.2021 SR SQL-Umänderung (Kopie von L_STD_Mat0004)
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

  Sel.Mat.ObfNr2        # 999;
  Sel.Mat.bis.WGr       # 59999;
  Sel.Mat.bis.Dicke     # 999999.00;
  Sel.Mat.bis.Breite    # 999999.00;
  "Sel.Mat.bis.Länge"   # 999999.00;
  Sel.Mat.von.Obfzusat  # 'zzzzz';
  "Sel.Mat.bis.ZugFest" # 9999.0;
  "Sel.Art.bis.ArtNr"   # 'zzzzz';
  Sel.von.Datum         # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Mat1004',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Abmessung',             'Abmessung');
  Sel_Main:AddSort(gMDI, 'Bestellnummer',         'Bestellnr');
  Sel_Main:AddSort(gMDI, 'Chargennummer',         'Chargennr');
  Sel_Main:AddSort(gMDI, 'Coilnummer',            'Coilnr');
  Sel_Main:AddSort(gMDI, 'Kommissionsnr.',        'Auftragsnr');
  Sel_Main:AddSort(gMDI, 'Kunden-Stichwort',      'Kunde');
  Sel_Main:AddSort(gMDI, 'Lagerort-Stichwort',    'Lageradresse');
  Sel_Main:AddSort(gMDI, 'Lieferanten-Stichwort', 'Lieferant');
  Sel_Main:AddSort(gMDI, 'Materialnummer',        'Nummer', true);
  Sel_Main:AddSort(gMDI, 'Qualität * Abmessung',  'Guete,Abmessung');
  Sel_Main:AddSort(gMDI, 'Ringnummer',            'Ringnr');
  Sel_Main:AddSort(gMDI, 'Werksnummer',           'Werksnr');
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
  if (Sel.Von.Datum=0.0.0) then RETURN;

  StartList(Sel.Sortierung);
end;


//========================================================================
//  StartList
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
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONAlpha(vJSON, 'VonStrukturnr', Sel.Art.von.ArtNr);
  AddJSONAlpha(vJSON, 'BisStrukturnr', Sel.Art.bis.ArtNr);
  AddJSONAlpha(vJSON, 'VonIntrastatnr', '');
  AddJSONAlpha(vJSON, 'BisIntrastatnr', 'zzz');
  AddJSONInt(vJSON, 'VonWarengruppe', Sel.Mat.Von.WGR);
  AddJSONInt(vJSON, 'BisWarengruppe', Sel.Mat.Bis.WGR);
  AddJSONInt(vJSON, 'VonStatus', Sel.Mat.Von.Status);
  AddJSONInt(vJSON, 'BisStatus', Sel.Mat.Bis.Status);
  AddJSONAlpha(vJSON, 'Guete', "Sel.Mat.Güte");
  AddJSONInt(vJSON, 'VonOberflaeche', Sel.Mat.ObfNr);
  AddJSONInt(vJSON, 'BisOberflaeche', Sel.Mat.ObfNr2);
  AddJSONInt(vJSON, 'Kunde', Sel.Auf.Kundennr);
  AddJSONInt(vJSON, 'Lieferant', Sel.Mat.Lieferant);
  AddJSONInt(vJSON, 'Lageradresse', Sel.Mat.Lagerort);
  AddJSONInt(vJSON, 'Lageranschrift', Sel.Mat.Lageranschri);
  AddJSONInt(vJSON, 'Bestellung', Sel.Auf.Von.Nummer);
  AddJSONInt(vJSON, 'Projekt', Sel.Auf.Von.Projekt);
  AddJSONFloat(vJSON, 'VonDicke', Sel.Mat.Von.Dicke);
  AddJSONFloat(vJSON, 'BisDicke', Sel.Mat.Bis.Dicke);
  AddJSONFloat(vJSON, 'VonBreite', Sel.Mat.Von.Breite);
  AddJSONFloat(vJSON, 'BisBreite', Sel.Mat.Bis.Breite);
  AddJSONFloat(vJSON, 'VonLaenge', "Sel.Mat.Von.LÄnge");
  AddJSONFloat(vJSON, 'BisLaenge', "Sel.Mat.Bis.Länge");

  AddJSONDate(vJSON, 'Stichtag', Sel.von.Datum);

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================