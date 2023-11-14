@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Mat1005
//                    OHNE E_R_G
//  Info
//
//
//  21.05.2021 SR SQL-Umänderung (Kopie von L_STD_MAT0005)
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
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Mat1005',here+':AusSel');
  Sel_Main:AddSort(gMDI, 'Materialnummer',        'Nummer', true);
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
  Erx         : int;
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
  vNode       : int;
  vItem       : int;
  vMFile      : Int;
  vMID        : Int;
  vA          : alpha(4096);
end
begin
  vForm   # 'SQL';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);
/***
  // Array
  vNode # vJSON->CteInsertNode('MarkierteMaterialnummern', _JsonNodeArray, NULL);

  FOR   vItem # gMarkList->CteRead(_CteFirst);      // erste Element holen
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then CYCLE;
    Erx # RecRead(200,0,_RecID, vMID);
    if (Erx<=_rLocked) then begin
      vNode->CteInsertNode('', _JsonNodeNumber, Mat.Nummer);
    end;
  END;
***/

  vA # ';';
  FOR   vItem # gMarkList->CteRead(_CteFirst);      // erste Element holen
  LOOP  vItem # gMarkList->CteRead(_CteNext,vItem); // nächstes Element
  WHILE (vItem > 0) DO BEGIN
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<>200) then CYCLE;
    Erx # RecRead(200,0,_RecID, vMID);
    if (Erx<=_rLocked) then begin
      vA # StrCut(vA + aint(Mat.Nummer) + ';',1,4000);
    end;
  END;

  AddJSONAlpha(vJSON,'MarkierteMaterialnummern', vA);

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================