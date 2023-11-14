@A+
/*
===== Business-Control =================================================

Prozedur:   Test+Proc

OHNE E_R_G

Info:
Analysiert Prozeduren

Historie:
2022-07-08  AH  Erstellung der Prozedur

Subprozeduren:

FX.eineSonderfunktion

MAIN: Benutzungsbeispiele zum Testen

Tipp: CTRL + SHIFT + G ermöglicht es, per Dropdown Menu zu allen
      subs in einer Prozedur zu springen
========================================================================
*/
@I:Def_Global
/* WICHTIG!:
KEINE Includes außer Def_Global verwenden, und andere unvermeidliche
Includes (z.B. für Konstanten etc.).
Stattdessen Scoping nutzen, also z.B. Lib_Json:LoadJsonFromAlpha(vJsonString)
Gegenbeispiel:
Bitte nicht Lib_Json inkludieren um das "Lib_Json:" Präfix zu sparen!
Hintergrund: C16 kann Includes nicht auflösen zum Durchnavigieren
mittels CTRL + Doppelklick.
*/



/*
========================================================================
Defines
========================================================================
*/
define begin
  cName     : 'Wert der Konstante'  // Wozu dient dieses define?
end


/*========================================================================
 2022-07-08 AH
========================================================================*/
sub _NextLine(
  aTxt      : int;
  var aI    : int) : alpha
local begin
  vA        : alpha(4000);
end
begin
  WHILE (aI<TextInfo(aTxt, _textLines)) do begin
    aI # aI + 1;
    vA # StrAdj(TextLineRead(aTxt, aI, 0),_StrAll);
    if (vA<>'') then RETURN vA;
  END;
  RETURN '';
end;

/*
/*========================================================================
 2022-07-08 AH
========================================================================*/
sub _CheckRecLock(
  aProc : alpha;
  aTxt  : int;
  ) : logic
local begin
  vI,vJ : int;
  vA,vB : alpha(1000);
  vOrg  : alpha(1000);
end;
begin
/*
, '*#', '*if(', 'rekreplace')
*/

  FOR vI # TextSearch(aTxt,1,1,_TextSearchCI|_TextSearchToken, '_recLock')
  LOOP vI # TextSearch(aTxt,vI+1,1,_TextSearchCI|_TextSearchToken, '_recLock')
  WHILE (vI>0) do begin
    vOrg # TextLineRead(aTxt, vI , 0);
    vA # StrAdj(vOrg, _strAll);
    vJ # StrFind(vA, aPost, 1, _StrCaseIgnore);
    if (vJ=0) then CYCLE;
    vB # StrCut(vA, 1, vJ-1);
    //vJ # StrFind(vA, aPre, 1, _StrCaseIgnore);
    //if (vJ<>0) then RETURN true;

    if (vB=*^'*If(') then CYCLE;
    if (vB=*^'Erx#') then begin
      vB # _NextLine(aTxt, var vI);
      if (vB=*^'IF(ERX*') then CYCLE;
    end;
    
//    if ((vB=*aPre1)=false) and ((vB=*aPre2)=false) then begin
debug(aProc+' z'+aint(vI)+': '+vOrg);
//      RETURN true;
  END;
  
  RETURN false;
end;
*/

/*========================================================================
 2022-07-08 AH
========================================================================*/
sub _CheckErx(
  aProc : alpha;
  aTxt  : int;
  aPost : alpha;
  ) : logic
local begin
  vI,vJ : int;
  vA,vB : alpha(1000);
  vOrg  : alpha(1000);
end;
begin

  FOR vI # TextSearch(aTxt,1,1,_TextSearchCI|_TextSearchToken,aPost)
  LOOP vI # TextSearch(aTxt,vI+1,1,_TextSearchCI|_TextSearchToken,aPost)
  WHILE (vI>0) do begin
    vOrg # TextLineRead(aTxt, vI , 0);
    vA # StrAdj(vOrg, _strAll);
    vJ # StrFind(vA, aPost, 1, _StrCaseIgnore);
    if (vJ=0) then CYCLE;
    vB # StrCut(vA, 1, vJ-1);
    //vJ # StrFind(vA, aPre, 1, _StrCaseIgnore);
    //if (vJ<>0) then RETURN true;

    if (vB=*^'If(*') then CYCLE;     // GUT

    if (vB=*^'Erx#*') then begin
      vB # _NextLine(aTxt, var vI);
      if (vB=*^'IF(ERX*') then CYCLE; // GUT
    end;
    
//    if ((vB=*aPre1)=false) and ((vB=*aPre2)=false) then begin
debug(aProc+' z'+aint(vI)+': '+vOrg);
//      RETURN true;
  END;
  
  RETURN false;
end;


/*========================================================================
  2022-07-08  AH
========================================================================**/
sub ProcsMitDeadlock()
local begin
  Erx   : int;
  vTxt  : int;
  vProc : alpha;
  vBad  : logic;
end;
begin
  debug('Procs mit Deadlock-unsicheren Code:');
  vTxt # TextOpen(16);
  Erx # vTxt -> TextRead('!FAQ', _TextProc);
  vProc # vTxt -> TextInfoAlpha(_TextName);
  FOR Erx # vTxt -> TextRead(vProc, _TextProc);
  LOOP Erx # vTxt -> TextRead(vProc, _TextNext | _TextProc);
  WHILE(Erx <= _rNoKey) DO BEGIN
    vProc # vTxt -> TextInfoAlpha(_TextName);
    if (StrCnv(vProc,_StrUpper)>'A') then BREAK;
//    if ((vProc=*'*_Data')=false) then CYCLE;

  //  _CheckRecLock(vProc, vTxt);
    _CheckErx(vProc, vTxt, '_recLock');
    _CheckErx(vProc, vTxt, 'RekReplace');
    _CheckErx(vProc, vTxt, 'RekInsert');
    _CheckErx(vProc, vTxt, 'RekDelete');

    _CheckErx(vProc, vTxt, '_textLock');
    _CheckErx(vProc, vTxt, 'TxtCreate');
    _CheckErx(vProc, vTxt, 'TxtDelete');
    _CheckErx(vProc, vTxt, 'TxtCcpy');
    _CheckErx(vProc, vTxt, 'TxtRename');
    _CheckErx(vProc, vTxt, 'TxtWrite');
    
    _CheckErx(vProc, vTxt, 'SelRun');

  END;
  vTxt -> TextClose();
end;


/*
========================================================================
MAIN: Benutzungsbeispiele zum Testen
========================================================================
*/
MAIN()
local begin
  // hier ausnahmsweise generische Variablennamen die in Beispielen wiederverwendet werden
  vAlpha : alpha;
  vInt   : int;
  vLogic : logic;
end;
begin

  // ggf. benötigte globals allokieren für Standalone-Ausführung (CTRL + T)...
  VarAllocate(VarSysPublic);
  VarAllocate(VarSys);
  VarAllocate(WindowBonus);
  Lib_Debug:Initdebug();
  // ...und setzen
  gUserName # 'ME';
  
  //
  ProcsMitDeadlock()

  VarFree(WindowBonus);
  VarFree(VarSys);
  VarFree(VarSysPublic);
Debug('=== ENDE: MAIN Benutzungsbeispiele von ' + __PROC__+' ===');
  RETURN;
  
end
