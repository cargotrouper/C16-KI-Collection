@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_VwA1001
//                    OHNE E_R_G
//  Info
//      Gibt eine Liste aller Datensätze
//
//
//  06.10.2021  SR  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global
@I:Def_PrintServer

declare StartList(aSort : alpha);

//========================================================================
//
//
//========================================================================
MAIN
begin
  StartList('');
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
  vDesign # 'Reports\' + Lfm.Listenformat;

  vJSON # OpenJSON(TRUE);
  AddJSONAlpha( vJSON,'Bereich', StrCnv(Lfm.Bereich,_StrUmlaut));
  AddJSONAlpha( vJSON,'Titel', Lfm.Name);

  FinishList(vForm, vDesign, var vJSON);

  Erg # _rOK;     // TODOERX
  ErrSet(0);
end;

//========================================================================