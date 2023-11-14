@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Mat0001
//                    OHNE E_R_G
//  Info
//
//
//  02.12.2014  AH  Erstellung der Prozedur
//  02.04.2015  ST  Übernahme von KUZ in STd
//  07.12.2022  ST  Übernahmedatum wieder aktiviert
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
  Sel.Mat.Bis.MatNr       # 999999999;
  Sel.Mat.ObfNr2          # 999;
  Sel.Mat.von.Wgr         # 0;
  Sel.Mat.bis.WGr         # 59999;
  Sel.Mat.bis.Status      # 999;
  Sel.Mat.bis.Dicke       # 9999999.00;
  Sel.Mat.bis.Breite      # 9999999.00;
  "Sel.Mat.bis.Länge"     # 9999999.00;
  "Sel.Mat.bis.ÜDatum"    # today;
  "Sel.Mat.bis.EDatum"    # today;
  "Sel.Mat.bis.ADatum"    # today;
  "Sel.Mat.bis.InvDatum"  # today;
  "Sel.Mat.EigenYN"       # y;
  "Sel.Mat.ReservYN"      # y;
  "Sel.Mat.BestelltYN"    # y;
  "Sel.Mat.!EigenYN"      # y;
  "Sel.Mat.!ReservYN"     # y;
  "Sel.Mat.!BestelltYN"   # y;
  "sel.Mat.KommissionYN"  # y;
  "sel.Mat.!KommissioYN"  # y;
  Sel.Mat.von.Obfzusat    # 'zzzzz';
  "Sel.Mat.bis.ZugFest"   # 9999.0;
  "Sel.Art.bis.ArtNr"     # 'zzzzz';
  Sel.Mat.ObfNr           # 0;
  Sel.Mat.ObfNr2          # 999;
  // gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200001',here+':AusSel');
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Std.Mat0001',here+':AusSel');

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
  Sel_Main:AddSort(gMDI, 'Artikelnr.',            'Strukturnr');

  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort       : alpha;
end;
begin

  // gSelected # 0;
  // vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  // vHdl2 # vHdl->WinSearch('Dl.Sort');
  //
  // AddSort(vHdl2, 'Abmessung',             'Abmessung');
  // AddSort(vHdl2, 'Bestellnummer',         'Bestellnr');
  // AddSort(vHdl2, 'Chargennummer',         'Chargennr');
  // AddSort(vHdl2, 'Coilnummer',            'Coilnr');
  // AddSort(vHdl2, 'Kommissionsnr.',        'Auftragsnr');
  // AddSort(vHdl2, 'Kunden-Stichwort',      'Kunde');
  // AddSort(vHdl2, 'Lagerort-Stichwort',    'Lageradresse');
  // AddSort(vHdl2, 'Lieferanten-Stichwort', 'Lieferant');
  // AddSort(vHdl2, 'Materialnummer',        'Nummer');
  // AddSort(vHdl2, 'Qualität * Abmessung',  'Guete,Abemssung');
  // AddSort(vHdl2, 'Ringnummer',            'Ringnr');
  // AddSort(vHdl2, 'Werksnummer',           'Werksnr');
  // AddSort(vHdl2, 'Artikelnr.',            'Strukturnr');
  //
  // vHdl2->wpcurrentint # 1;
  // vHdl->WinDialogRun(_WindialogCenter,gMdi);
  // if (gSelected<>0) then begin
  //   vHdl2->WinLstCellGet(vSort, 2, gSelected);
  //   if (vSort='') then
  //     vHdl2->WinLstCellGet(vSort, 1, gSelected);
  // end;
  // vHdl->WinClose();
  // if (gSelected=0) then RETURN;
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

  vNode, vNode2 : int;
end
begin

  vForm   # 'Mat0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
//  AddJSONInt(vJSON,'StellenDicke', gTMP);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONInt(vJSON, 'VonMaterialnr', Sel.Mat.Von.MatNr);
  AddJSONInt(vJSON, 'BisMaterialnr', Sel.Mat.Bis.MatNr);
  AddJSONAlpha(vJSON, 'VonStrukturnr', Sel.Art.von.ArtNr);
  AddJSONAlpha(vJSON, 'BisStrukturnr', Sel.Art.bis.ArtNr);

  AddJSONAlpha(vJSON, 'VonIntrastatnr', '');
  AddJSONAlpha(vJSON, 'BisIntrastatnr', 'zzz');

  AddJSONInt(vJSON, 'VonWarengruppe', Sel.Mat.Von.WGR);
  AddJSONInt(vJSON, 'BisWarengruppe', Sel.Mat.Bis.WGR);
  AddJSONInt(vJSON, 'VonStatus', Sel.Mat.Von.Status);
  AddJSONInt(vJSON, 'BisStatus', Sel.Mat.Bis.Status);
  AddJSONAlpha(vJSON, 'Guete', "Sel.Mat.Güte");
  AddJSONAlpha(vJSON, 'Guetenstufe', "Sel.Mat.Gütenstufe");
  AddJSONInt(vJSON, 'VonOberflaeche', Sel.Mat.ObfNr);
  AddJSONInt(vJSON, 'BisOberflaeche', Sel.Mat.ObfNr2);
  AddJSONInt(vJSON, 'Kunde', Sel.Auf.Kundennr);
  AddJSONInt(vJSON, 'Lieferant', Sel.Mat.Lieferant);
  AddJSONInt(vJSON, 'Lageradresse', Sel.Mat.Lagerort);
  AddJSONInt(vJSON, 'Lageranschrift', Sel.Mat.Lageranschri);
  AddJSONInt(vJSON, 'Bestellung', Sel.Auf.Von.Nummer);
  AddJSONInt(vJSON, 'Projekt', Sel.Auf.Von.Projekt);
  
  AddJSONFloat(vJSON, 'VonZugfestigkeit', "Sel.Mat.von.ZugFest");
  AddJSONFloat(vJSON, 'BisZugfestigkeit', "Sel.Mat.bis.ZugFest");
  
  AddJSONFloat(vJSON, 'VonDicke', Sel.Mat.Von.Dicke);
  AddJSONFloat(vJSON, 'BisDicke', Sel.Mat.Bis.Dicke);
  AddJSONFloat(vJSON, 'VonBreite', Sel.Mat.Von.Breite);
  AddJSONFloat(vJSON, 'BisBreite', Sel.Mat.Bis.Breite);
  AddJSONFloat(vJSON, 'VonLaenge', "Sel.Mat.Von.LÄnge");
  AddJSONFloat(vJSON, 'BisLaenge', "Sel.Mat.Bis.Länge");
  AddJSONDate(vJSON, 'VonUebernahmedatum',  "Sel.Mat.von.ÜDatum");
  AddJSONDate(vJSON, 'BisUebernahmedatum', "Sel.Mat.bis.ÜDatum");
  AddJSONDate(vJSON, 'VonEingangsdatum', Sel.Mat.Von.EDatum);
  AddJSONDate(vJSON, 'BisEingangsdatum', Sel.Mat.Bis.EDatum);
  AddJSONDate(vJSON, 'VonAusgangsdatum', Sel.Mat.Von.ADatum);
  AddJSONDate(vJSON, 'BisAusgangsdatum', Sel.Mat.Bis.ADatum);
  AddJSONDate(vJSON, 'VonInventurdatum', Sel.Mat.Von.InvDatum);
  AddJSONDate(vJSON, 'BisInventurdatum', Sel.Mat.Bis.InvDatum);
  AddJSONBool(vJSON, 'MitGeloeschten', "Sel.Mat.Mit.Gelöscht");
  AddJSONBool(vJSON, 'MitEigenmaterial', Sel.Mat.EigenYN);
  AddJSONBool(vJSON, 'MitFremdmaterial',"Sel.Mat.!EigenYN");
  AddJSONBool(vJSON, 'MitBestellt', Sel.Mat.BestelltYN);
  AddJSONBool(vJSON, 'MitBestand', "Sel.Mat.!BestelltYN");

  AddJSONBool(vJSON, 'MitKommissioniert', "Sel.Mat.KommissionYN");
  AddJSONBool(vJSON, 'MitUnkommissioniert', "Sel.Mat.!KommissioYN");
  AddJSONBool(vJSON, 'MitReserviert', "Sel.Mat.ReservYN");
  AddJSONBool(vJSON, 'MitFrei', "Sel.Mat.!ReservYN");

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================