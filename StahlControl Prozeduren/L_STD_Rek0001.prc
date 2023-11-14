@A+
/*===== Business-Control =================================================

Prozedur:   L_STD_Rek0001
OHNE E_R_G

Info:
Startet Liste Rek0001

Historie:
2022-12-13  AH  Erstellung

Subprozeduren

========================================================================*/
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

/*========================================================================
2022-12-13  AH
========================================================================*/
MAIN
begin
  Sel.bis.Datum   # 13.12.2099;
  GV.Int.13       # 0;
  GV.Int.14       # 99999999;
  Sel.Mat.von.Status  # 0;
  Sel.Mat.bis.Status  # 999;
  "Sel.Mat.EigenYN"       # y;
  "Sel.Mat.ReservYN"      # y;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Rek0001',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Nummer',             'Nummer');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


/*========================================================================
2022-12-13  AH
========================================================================*/
sub StartList(aSort : alpha);
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin
  vForm   # 'Rek0001';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);
  AddJSONInt(vJSON, 'VonNummer', GV.Int.13);
  AddJSONInt(vJSON, 'BisNummer', GV.Int.14);
  AddJSONInt(vJSON, 'VonStatus', Sel.Mat.von.Status);
  AddJSONInt(vJSON, 'BisStatus', Sel.Mat.Bis.Status);
  AddJsonDate(vJSON, 'VonDatum'  , "Sel.von.Datum");
  AddJsonDate(vJSON, 'BisDatum'  , "Sel.bis.Datum");
  AddJSONBool(vJSON, 'MitKunde'  , Sel.Mat.ReservYN);
  AddJSONBool(vJSON, 'MitLieferant'  , Sel.Mat.EigenYN);
  


  FinishList(vForm, vDesign, var vJSON);

end;


/*========================================================================
2022-12-13  AH
========================================================================*/
sub AusSel();
begin
  gSelected # 0;
  StartList(Sel.Sortierung);
end;

//========================================================================