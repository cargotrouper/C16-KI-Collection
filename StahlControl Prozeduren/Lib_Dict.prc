@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Dict
//                OHNE E_R_G
//  Info
//
//
//  24.03.2017  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//
//
//========================================================================
sub _Init(var aDict : int);
begin
  aDict # Cteopen(_CteTreeCI);
end;

//========================================================================
//========================================================================
sub Clear(var aDict : int);
begin
  if (aDict=0) then RETURN;
  CteClear(aDict, true);
end;

//========================================================================
//========================================================================
sub Close(var aDict : int);
begin
  if (aDict=0) then RETURN;
  Clear(var aDict);
  CteClose(aDict);
  aDict # 0;
end;

//========================================================================
//========================================================================
sub Read(
  var aDict   : int;
  aName       : alpha;
  var aInhalt : alpha) : logic;
local begin
  vItem     : int;
end;
begin
  if (aDict=0) then _Init(var aDict);

  aInhalt # '';

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;

  aInhalt # vItem->spCustom;
  RETURN true;
end;

//========================================================================
sub ReadExt(
  var aDict   : int;
  aName       : alpha;
  var aInhalt : alpha;
  var aID     : bigint) : logic;
local begin
  vItem     : int;
end;
begin
  if (aDict=0) then _Init(var aDict);

  aInhalt # '';

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;

  aInhalt # vItem->spCustom;
  aID     # vITem->spID;
  RETURN true;
end;

//========================================================================
sub ReadItem(
  var aDict   : int;
  aName       : alpha;
  var aItem   : int) : logic;
local begin
  vItem     : int;
end;
begin
  if (aDict=0) then _Init(var aDict);

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;
  aItem # vItem;
  RETURN true;
end;

//========================================================================
//========================================================================
sub Exists(
  var aDict   : int;
  aName       : alpha) : logic;
local begin
  vItem     : int;
end;
begin
  if (aDict=0) then _Init(var aDict);

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;

  RETURN true;
end;

//========================================================================
//========================================================================
sub Add(
  var aDict   : int;
  aName       : alpha;
  opt aInhalt : alpha;
  opt aID     : BigInt) : logic;
local begin
  vItem       : int;
  vInhalt     : alpha;
end;
begin
  if (aDict=0) then _Init(var aDict);

  if (Read(var aDict, aName, var vInhalt)=true) then RETURN false;

  if (aDict->CteInsertItem(aName, aID, aInhalt)<0) then RETURN false;

  RETURN true;
end;

//========================================================================
//========================================================================
sub Replace(
  var aDict   : int;
  aName       : alpha;
  opt aInhalt : alpha) : logic;
local begin
  vItem       : int;
  vInhalt     : alpha;
end;
begin
  if (aDict=0) then _Init(var aDict);

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;
  vItem->spcustom # aInhalt;

  RETURN true;
end;

//========================================================================
//========================================================================
sub ReplaceExt(
  var aDict   : int;
  aName       : alpha;
  opt aInhalt : alpha;
  opt aID     : bigInt) : logic;
local begin
  vItem       : int;
  vInhalt     : alpha;
end;
begin
  if (aDict=0) then _Init(var aDict);

  vItem # aDict->CteRead(_CteFirst | _CteSearch, 0, aName);
  if (vItem=0) then RETURN false;
  vItem->spcustom # aInhalt;
  vItem->spID     # aID;

  RETURN true;
end;

//========================================================================


//========================================================================