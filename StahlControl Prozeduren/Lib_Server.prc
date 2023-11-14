@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Server
//                  OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB Remote_Selrun(aID : int)
//    SUB SelDynChk : logic;
//
//========================================================================
@I:Def_global


sub CopyDB(
  aSrc  : alpha(1000);
  aDest : alpha(1000));
local begin
  vI  : int;
end;
begin
  //Winsleep(3000);
  // Ausführen des Shell-Befehls copy
  //SysExecute('cmd', '/c copy '+aSrc+' '+aDest,_Execwait);
//  DbaLog(_LogInfo,n,'Copy Start...'+aSrc);
//  DbaLog(_LogInfo,n,'Dest:'+aDest);
//  DbaLog(_LogInfo,n,'path...'+FsiPath());
  vI # Lib_FileIO:FSICopy(aSrc, aDest, n);
  if (vI<>0) then begin
    vI # _Sys->spFsiError;                   // read error code
//    DbaLog(_LogInfo,n,ErrMapText(vI,'DE',_ErrMapSys)); // get error message
  end;
//  DbaLog(_LogInfo,n,cnvai(vI));
//  DbaLog(_LogInfo,n,'Copy End...');
end;


//========================================================================
//  Remote_Selrun(ID)
//                    Führt die angegebne Selektion durch
//========================================================================
sub Remote_Selrun(
  aID : int;
)
local begin
  vHdl    : int;
  vErg    : int;
  vCount  : int;
end;
begin
  Sel.UserID # aID;
  if (RecRead(998,1,_RecLock)<>_rOk) then begin
    RETURN;
  end;
//debug('sel run');
  vHdl # SelOpen();
  vErg # vHdl->SelRead(Sel.Datei,_SelLock,Sel.Selektionsname);
//debug('erg A:'+cnvai(vErg));;
  vErg # vHdl->SelRun(_SelBreak);
//debug('erg B:'+cnvai(vErg));;
  vCount # RecInfo(Sel.Datei, _recCount, vHdl);
  vHdl->SelClose();
//debug('sel close : '+cnvai(vCount));

  Sel.Status # 1;
  RecReplace(998,_RecUnlock);
end;


//========================================================================
// SelDynChk
//
//========================================================================
sub SelDynChk() : logic;
begin
debug('selcheck: '+art.nummer);
  RETURN Call(Sel.Check.Prozedur);
end;


//========================================================================
//========================================================================
//========================================================================