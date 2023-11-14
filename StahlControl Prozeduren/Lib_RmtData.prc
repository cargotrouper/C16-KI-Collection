@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_RmtData
//                    OHNE E_R_G
//  Info      Merkt sich userbezogen Werte am Server
//
//
//  21.03.2018  AH  Erstellung der Prozedur
//  05.07.2022  ST  Erweiterung Länge von "Wert" auf 1000 Zeichen
//
//  Subprozeduren
//    sub UserWrite(aKey : alpha; aWert : alpha)
//    sub UserRead(aKey : alpha; opt aDel : logic) : alpha;
//    sub UserReset(opt aKey : alpha) : alpha;
//
//========================================================================
@I:Def_Global

define begin
end;

//========================================================================
//
//
//========================================================================
sub UserWrite(
  aKey      : alpha;
  aWert     : alpha(1000);
  opt aUser : alpha)
begin
  if (aUser='') then
    aKey # UserInfo(_UserCurrent) + '|' + aKey
  else
    aKey # aUser + '|' + aKey;
  RmtDataWrite(aKey, _recunlock | _RmtDataTemp, aWert);
end;


//========================================================================
//========================================================================
sub UserRead(
  aKey      : alpha;
  opt aDel  : logic;
  opt aUser : alpha) : alpha;
local begin
  vWert : alpha(1000);
end;
begin
  if (aUser='') then
    aKey # UserInfo(_UserCurrent) + '|' + aKey
  else
    aKey # aUser + '|' + aKey;

  if (RmtDataRead(aKey, _recunlock, var vWert)=_rOK) then begin
    if (aDel) then RmtDataWrite(aKey, _RecUnlock, '');
  end;
  RETURN vWert;
end;


//========================================================================
//========================================================================
sub UserReset(opt aKey : alpha) : alpha;
local begin
  vKey  : alpha;
end;
begin

  aKey # UserInfo(_UserCurrent) + '|' + aKey;
  FOR vKey # RmtDataSearch(aKey, 0)
  LOOP vKey # RmtDataSearch(aKey, 0)
  WHILE (vKey != '') and (StrCut(vKey,1,StrLen(aKey))=aKey) do begin
    RmtDataWrite(vKey, _recUnlock, ''); // Löschen
  END;
  
end;


//========================================================================