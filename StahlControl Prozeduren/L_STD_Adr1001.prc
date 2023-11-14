@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Adr1001
//                    OHNE E_R_G
//  Info
//
//
//  27.05.2021 SR SQL-Umänderung (Kopie von L_STD_Adr0001)
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
  Sel.Adr.von.KdNr      # 0;        // Kundennummer von
  Sel.Adr.bis.KdNr      # 9999999;  // Kundennummer bis
  Sel.Adr.von.LiNr      # 0;        // Lieferantennummer von
  Sel.Adr.bis.LiNr      # 9999999;  // Lieferantennummer bis
  Sel.Adr.von.FibuKd    # '';       // Fibu-Kunden-Nr von
  Sel.Adr.bis.FibuKd    # 'ZZZ';    // Fibu-Kunden-Nr bis
  Sel.Adr.von.FibuLi    # '';       // Fibu-Lieferanten-Nr von
  Sel.Adr.bis.FibuLi    # 'ZZZ';    // Fibu-Lieferanten-Nr bis
  Sel.Adr.von.Gruppe    # '';       // Gruppe von
  Sel.Adr.bis.Gruppe    # 'ZZZ';    // Gruppe bis
  Sel.Adr.von.Stichw    # '';       // Stichwort von
  Sel.Adr.bis.Stichw    # 'ZZZ';    // Stichwort bis
  Sel.Adr.von.ABC       # '';       // ABC von
  Sel.Adr.bis.ABC       # 'Z';      // ABC bis
  Sel.Adr.von.LKZ       # '';       // LKZ von
  Sel.Adr.bis.LKZ       # 'ZZZ';    // LKZ bis
  Sel.Adr.von.PLZ       # '';       // PLZ von
  Sel.Adr.bis.PLZ       # 'ZZZ';    // PLZ bis
  Sel.Adr.von.Vertret   # 0;        // nur Vertreter
  Sel.Adr.von.Sachbear  # '';       // nur Sachbearbeiter
  Sel.Adr.Briefgruppe   # '';       // Briefgruppe enthält
  Sel.Adr.nurMarkeYN    # false;    // nur markierte

  "Sel.Adr.SperrKdYN"   # true;    // nur gesperrte Kunden
  "Sel.Adr.!SperrKdYN"  # true;    // ohne gesperrte Kunden
  "Sel.Adr.SperrLiYN"   # true;    // nur gesperrte Lieferanten
  "Sel.Adr.!SperrLiYN"  # true;    // ohne gesperrte Lieferanten


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Adr1001',here+':AusSel');

  Sel_Main:AddSort(gMdi, 'Kundennummer',          'Kundennr', true);
  Sel_Main:AddSort(gMdi, 'Lieferantennummer',     'Lieferantennr');
  Sel_Main:AddSort(gMdi, 'Name',                  'Name');
  Sel_Main:AddSort(gMdi, 'Stichwort',             'Stichwort');

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
end;
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
  debugx(aSort);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

  AddJSONInt(vJSON, 'VonKundennr', Sel.Adr.von.KdNr);
  AddJSONInt(vJSON, 'BisKundennr', Sel.Adr.bis.KdNr);
  
  AddJSONInt(vJSON, 'VonLieferantennr', Sel.Adr.von.LiNr);
  AddJSONInt(vJSON, 'BisLieferantennr', Sel.Adr.bis.LiNr);
  AddJSONAlpha(vJSON, 'VonFibuKundennr', Sel.Adr.von.FibuKd);
  AddJSONAlpha(vJSON, 'BisFibuKundennr', Sel.Adr.bis.FibuKd);
  AddJSONAlpha(vJSON, 'VonFibuLieferantennr', Sel.Adr.von.FibuLi);
  AddJSONAlpha(vJSON, 'BisFibuLieferantennr', Sel.Adr.bis.FibuLi);

  AddJSONAlpha(vJSON, 'VonGruppe', Sel.Adr.von.Gruppe);
  AddJSONAlpha(vJSON, 'BisGruppe', Sel.Adr.bis.Gruppe);

  AddJSONAlpha(vJSON, 'VonStichwort', Sel.Adr.von.Stichw);
  AddJSONAlpha(vJSON, 'BisStichwort', Sel.Adr.bis.Stichw);
  AddJSONAlpha(vJSON, 'VonABC', Sel.Adr.Von.ABC);
  AddJSONAlpha(vJSON, 'BisABC', Sel.Adr.Bis.ABC);
  AddJSONAlpha(vJSON, 'VonLKZ', Sel.Adr.Von.LKZ);
  AddJSONAlpha(vJSON, 'BisLKZ', Sel.Adr.Bis.LKZ);
  AddJSONAlpha(vJSON, 'VonPLZ', Sel.Adr.Von.PLZ);
  AddJSONAlpha(vJSON, 'BisPLZ', Sel.Adr.Bis.PLZ);
  AddJSONInt(vJSON, 'NurVertreter', Sel.Adr.von.Vertret);
  AddJSONAlpha(vJSON, 'NurSachbearbeiter', Sel.Adr.von.Sachbear);
  AddJSONAlpha(vJSON, 'Briefgruppe', Sel.Adr.Briefgruppe);

  AddJSONBool(vJSON, 'MitGesperrtenKd', "Sel.Adr.!SperrKdYN");
  AddJSONBool(vJSON, 'MitUngesperrtenKd', "Sel.Adr.SperrKdYN");
  AddJSONBool(vJSON, 'MitGesperrtenLf', "Sel.Adr.!SperrLiYN");
  AddJSONBool(vJSON, 'MitUngesperrtenLf', "Sel.Adr.SperrLiYN");

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================