@A+
/*===== Business-Control =================================================

Prozedur:   Lib_Cache

OHNE E_R_G

Info:
Funktionen für TableCache, welches Datensätze im Client-RAM hält

Historie:
2022-09-28  AH  Erstellung der Prozedur

Subprozeduren:

MAIN: Benutzungsbeispiele zum Testen

========================================================================*/
@I:Def_Global

declare _InitTable(aTable : int);
declare _CloseCache(aTable : int);

/*========================================================================
Defines
========================================================================*/
define begin
end


/*========================================================================
2022-09-28  AH
========================================================================*/
sub Init()
local begin
  Erx         : int;
end
begin
  _InitTable(820);
end


/*========================================================================
2022-09-28  AH
========================================================================*/
sub Term()
local begin
  vI          : int;
end
begin
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=999) do begin
    if (gTableCache[vI]<>0) then begin
      _CloseCache(vI);
    end;
  END;
end


/*========================================================================
2022-09-28  AH
========================================================================*/
sub _GetKey(aTable : int) : alpha
local begin
  vKey  : alpha;
end;
begin
  case aTable of
    820 : vKey # aint(Mat.Sta.Nummer);
  end;
  vKey # aint(aTable)+'|'+vKey+'|';
//debugx('KEY820 = '+vKey);

  RETURN vKey;
end;


/*========================================================================
2022-09-28  AH
========================================================================*/
sub _InitTable(aTable : int);
local begin
  Erx     : int;
  vTree   : int;
  vItem   : int;
  vBuf    : int;
end
begin
  _CloseCache(aTable);
  vTree # CteOpen(_CteTree);
  gTableCache[aTable] # vTree;

  // Datensätze laden
  FOR Erx # RecRead(aTable, 1,_recFirst)
  LOOP Erx # RecRead(aTable, 1,_recNext)
  WHILE (Erx<=_rLocked) do begin
    vBuf # RecBufCreate(aTable);
    RecbufCopy(aTable, vBuf);
    vTree->CteInsertItem(_GetKey(aTable), vBuf, '');
  END;
  
end;


/*========================================================================
2022-09-28  AH
========================================================================*/
sub _CloseCache(aTable : int)
local begin
  vItem   : int;
  vBuf    : int;
  vTree   : int;
end
begin
  vTree # gTableCache[aTable];
  if (vTree=0) then RETURN;
  REPEAT
    vItem # CteRead(vTree, _CteFirst);
    if (vItem<>0) then begin
      vBuf # vItem->spID;
      RecbufDestroy(vBuf);
      vTree->CteDelete(vItem);
      CteClose(vItem);
    end;
  UNTIL vItem=0;
  CteClose(vTree);
  gTableCache[aTable] # 0;
end


/*========================================================================
2022-09-28  AH
========================================================================*/
sub ReadCache(
  aTable  : int;
  aKey    : alpha) : int;
local begin
  vItem   : int;
end;
begin
  if (gTableCache[aTable]=0) then RETURN -100;
  aKey # aint(aTable)+'|'+aKey+'|';
  vItem # CteRead(gTableCache[aTable], _CteFirst | _CteSearch, 0, aKey)
  if (vItem=0) then RETURN -1;
  if (vItem->spID=0) then RETURN -10;
  RecBufCopy(vItem->spID, aTable);
  RETURN _rOK;
end;


/*========================================================================
2022-09-28  AH
========================================================================*/
sub Read820(aStatusNr : int) : int
begin
  RETURN ReadCache(820, aint(aStatusNr));
end;


/*========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================*/
MAIN()
local begin
  // hier ausnahmsweise generische Variablennamen die in Beispielen wiederverwendet werden
  vAlpha  : alpha;
  vInt    : int;
  vLogic  : logic;
  Erx     : int;
  vI      : int;
  vMax    : int;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  gUserName # 'AH';
  Lib_Debug:InitDebug();

  // Erforderlich damit Lib_SFX:* Funktionen bei standalone Ausführung (STRG+T) funktionieren (nicht nötig innerhalb von laufendem SC (STRG+R))
  Lib_SFX:InitAFX();
  
  Init();

  Mat.Status # 1;

  vMax # 50000;
debugstamp('START RECLINK');
  FOR vI # 1 loop inc(vI) while (vI<=vMax) do begin
    Erx # RecLink(820,200,9,_recFirst);   // Status holen
//debugx(aint(erx)+' '+Mat.Sta.Bezeichnung);
  END;
debugstamp('START CACHE');
  FOR vI # 1 loop inc(vI) while (vI<=vMax) do begin
    Erx # Read820(Mat.Status);
//debugx(aint(erx)+' '+Mat.Sta.Bezeichnung);
  END;
debugstamp('STOP');
  
  Term();

  DebugM('Ende: MAIN Benutzungsbeispiele von ' + __PROC__);
  return;
  
end

// ========================================================================
