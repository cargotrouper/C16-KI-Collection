@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_Mat0005
//                    OHNE E_R_G
//  Info
//
//
//  20.10.2015  AH  Erstellung der Prozedur
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
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.STD.Mat0005',here+':AusSel');
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
end
begin
  vForm   # 'Mat0005';
  vDesign # 'Reports\'+Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha(vJSON,'Sortname', aSort);
  AddJSONAlpha(vJSON,'Titel', Lfm.Name);

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

  FinishList(vForm, vDesign, var vJSON);

end;

//========================================================================