@A+
//===== Business-Control =================================================
//
//  Prozedur  L_STD_ApL0001
//                    OHNE E_R_G
//  Info
//      Gibt eine Liste aller Datensätze der Aufpreisliste aus
//
//
//  05.01.2014  ST  Erstellung der Prozedur
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
  vForm   # 'ApL0001';
  vDesign # 'Reports\' + Lfm.Listenformat;

  vJSON # OpenJSON();
  AddJSONAlpha( vJSON,'Bereich', StrCnv(Lfm.Bereich,_StrUmlaut));
  AddJSONAlpha( vJSON,'Titel', Lfm.Name);

  FinishList(vForm, vDesign, var vJSON);

  Erg # _rOK;
  ErrSet(0);
end;

//========================================================================