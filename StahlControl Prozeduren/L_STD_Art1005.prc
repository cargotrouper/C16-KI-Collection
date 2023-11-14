@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Art1005
//                    OHNE E_R_G
//  Info  Startet den Druck der Artikelliste Lagerwert pr Charge
//
//
//  09.06.2021  SR  SQL-Umänderung (Kopie von L_STD_Adr0005)
//  2022-06-28  AH  ERX
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
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.SachNr      # 'zzz';
  Sel.Art.bis.Wgr         # 59999;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Art.bis.Stichwor    # 'zzz';
  "Sel.Art.-VerfügbarYN"  # Y;
  "Sel.Art.+VerfügbarYN"  # Y;
  Sel.Art.OutOfSollYN     # n;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Art1005',here+':AusSel');
  Sel_Main:AddSort(gMdi, 'Artikelnummer',             'Artikelnr', true);
  Sel_Main:AddSort(gMdi, 'Stichwort',                 'Stichwort');
  Sel_Main:AddSort(gMdi, 'Sachnummer',                'Sachnr');
  Sel_Main:AddSort(gMdi, 'Artikelgruppe',             'Artikelgruppe');
  Sel_Main:AddSort(gMdi, 'Warengruppe * Stichwort',   'Warengruppe*Stichwort');
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
//  StartList
//========================================================================
sub StartList(aSort : alpha);
local begin
  Erx         : int;
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
  vMatStatus  : alpha(1000);
end
begin
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONAlpha(vJSON, 'VonArtikelnr', Sel.Art.Von.ArtNr);
  AddJSONAlpha(vJSON, 'BisArtikelnr', Sel.Art.bis.ArtNr);
  AddJSONAlpha(vJSON, 'VonStichwort', Sel.Art.von.Stichwor);
  AddJSONAlpha(vJSON, 'BisStichwort', Sel.Art.bis.Stichwor);
  AddJSONAlpha(vJSON, 'VonSachnummer', Sel.Art.Von.SachNr);
  AddJSONAlpha(vJSON, 'BisSachnummer', Sel.Art.bis.SachNr);
  AddJSONInt(vJSON, 'VonArtikelgruppe', Sel.Art.von.ArtGr);
  AddJSONInt(vJSON, 'BisArtikelgruppe', Sel.Art.bis.ArtGr);
  AddJSONInt(vJSON, 'VonWarengruppe', Sel.Art.von.Wgr);
  AddJSONInt(vJSON, 'BisWarengruppe', Sel.Art.bis.Wgr);
  AddJSONAlpha(vJSON, 'NurArtikeltyp', Sel.Art.von.Typ);

  AddJSONBool(vJSON, 'MitUnterNull', "Sel.Art.-VerfügbarYN");
  AddJSONBool(vJSON, 'MitUeberNull', "Sel.Art.+VerfügbarYN");
  AddJSONBool(vJSON, 'NurUnterdeckung', Sel.Art.OutOfSollYN);

  AddJSONBool(vJSON, 'MitEkPreisen', true);
  AddJSONBool(vJSON, 'MitMaterialChargen', true);


  vMatStatus # ',';
  FOR   Erx # RecRead(820,1,_RecFirst)
  LOOP  Erx # RecRead(820,1,_RecNext)
  WHILE Erx = _rOK DO BEGIN
    Case (Mat.Sta.Nummer) of
      // Bestellungen sind nicht im Lager
      500,501,502,503,597,598,599 : begin CYCLE end

      otherwise
        vMatStatus # vMatStatus + Aint(Mat.Sta.Nummer) + ',';
    end;


  END;
  AddJSONAlpha(vJSON, 'NurMaterialChargenStatus', vMatStatus);


  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================
