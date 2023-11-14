@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Remote
//                OHNE E_R_G
//  Info      StahlControl von extern fernbedienen
//
//
//  26.08.2020  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//  30.08.2021  AH  mit vErr
//  25.01.2022  AH  Cmd BaNewPos, BaFertNextNewPos
//  02.05.2023  DB  Cmd_BaNachspaltungAnlegen  Proj. 2429/1129
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cDemo : false
end;


declare ProcessCmd(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_Msg(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaShowWebApp(aCmd : alpha(1000);  aPrecheck : logic;  ) : alpha
declare Cmd_BaShow(aCmd : alpha(1000); aPrecheck : logic; aUseWebApp : logic;) : alpha
declare Cmd_BaMerge(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaMergePos(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaMergeFert(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaFertNextPos(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaFertNextNewPos(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaNewPos(aCmd : alpha(1000); aPrecheck : logic) : alpha

declare Cmd_BaMergeUpPos(aCmd : alpha(1000); aPrecheck : logic) : alpha
declare Cmd_BaIgnoreRso(aCmd : alpha(1000); aPrecheck : logic) : alpha;
declare Cmd_BaCheckPlan(aCmd : alpha(1000); aPrecheck : logic) : alpha;
declare Cmd_BaNachspaltungAnlegen(aCmd : alpha(1000); aPrecheck : logic) : alpha;

//========================================================================
//========================================================================
sub EvtSocket(
  aEvt                  : event;        // Ereignis
  aHandle               : handle;       // Socket-Deskriptor
  aSubType              : int;          // Untertyp des Ereignisses
) : logic;
local begin
  vA    : alpha(1000);
  vErr  : alpha(4000);
end
begin

  // Art der Ereignisses überprüfen
  if (aSubType != _SckEvtConnect) then RETURN(FALSE);

//  WHILE ((SckInfo(aSck,_SckReadyRead,mTimeout) = '0') AND (vReadBytes > 0)) do begin
  SckRead(aHandle, _SckLine, vA);

  vErr # ProcessCmd(vA, true);   // CMD Prüfen
  if (vErr<>'') then begin
    aHandle->SckWrite(0,vErr);
    aHandle->SckClose();
    RETURN true;
  end;
/**
debug('ahha');
debugx('ahha');
debugstamp('START');
debugstamp('ENDE');
Todo('löschen vom Datensatz');
Todox('löschen vom Datensatz');
***/

  // Schreiben der Daten in den Socket.
//  if (vOK) then
//    aHandle->SckWrite(0,'OK')
//  else
//    aHandle->SckWrite(0,'ERROR');

//debugx(aHandle->SckInfo(_SckAddrPeer));
  vErr # ProcessCmd(vA, false);
  if (vErr<>'') then begin
    aHandle->SckWrite(0,vErr);
    aHandle->SckClose();
    RETURN true;
  end;

  aHandle->SckWrite(0,'OK');
  aHandle->SckClose();

  // CMD durchführen............................
//  vOK # ProcessCmd(vA, false);
  ErrorOutput;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub WaitForSync() : logic
local begin
  vI    : int;
  vAnz  : int;
end;
begin
  vI # RecInfo(992, _RecCount);
  if (vI=0) then RETURN true;

  GV.Sys.UserID # gUserID;
  // nix von mir?
  WHILE (vAnz<500) and (RecLinkInfo(992,999,10,_recCount)<>0) do begin
    winsleep(10);
    // SYNC macht nix?? -> mitzählen ! Maximal 5000 ms das aushalten!!
    if (vI=RecInfo(992,_RecCount)) then inc(vAnz);
  END;

  RETURN (RecLinkInfo(992,999,10,_recCount)=0);
end;


//========================================================================
//========================================================================
sub ProcessCmd(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  vA          : alpha;
  vErr        : alpha(4000);
  vVonWebApp  : logic;
end;
begin
//debugx('Received:'+aCmd);

  vA # StrCnv(Str_Token(aCmd,'|',1),_Strupper);
/*
  if (Str_Contains(vA,'WEBAPP:')) then begin
    vA # StrCut(vA,8,StrLen(va));
    vVonWebApp # true;
  end;
*/
  case vA of
    'WEBAPP:MSG'        : vErr # Cmd_Msg(aCmd, aPrecheck);
    'WEBAPP:BA_SHOW'    : vErr # Cmd_BaShowWebApp(aCmd, aPrecheck);
    'BA_SHOW'           : vErr# Cmd_BaShow(aCmd, aPrecheck, vVonWebApp);
    'BA_MERGE'          : vErr # Cmd_BaMerge(aCmd, aPrecheck);
    'BA_MERGE_POS'      : vErr # Cmd_BaMergePos(aCmd, aPrecheck);
    'BA_MErxE_FERT'     : vErr # Cmd_BaMergeFert(aCmd, aPrecheck);
    'BA_FERT_NEXT_POS'  : vErr # Cmd_BaFertNextPos(aCmd, aPrecheck);
    'BA_FERT_NEXT_NEW_POS'  : vErr # Cmd_BaFertNextNewPos(aCmd, aPrecheck);
    'BA_NEW_POS'        : vErr # Cmd_BaNewPos(aCmd, aPrecheck);

    'BA_MERGEUP_POS'    : vErr # Cmd_BaMergeUpPos(aCmd, aPrecheck);
    'BA_CHECKRSO','BA_IGNORERSO'      : vErr # Cmd_BaIgnoreRso(aCmd, aPrecheck);
    'BA_CHECKPLAN'      : vErr # Cmd_BaCheckPlan(aCmd, aPrecheck);
    'BA_NACHSPALTEN'    : vErr # Cmd_BaNachspaltungAnlegen(aCmd, aPrecheck);
  end;

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub LockApp(opt aUseWebApp : logic)
begin
  WinLayer(_WinLayerStart, gFrmMain, 30000, 'Berechne...', _WinLayerDarken);

  if (aUseWebApp = false) then
    Lib_DotNetServices:Remote_LockApp();
end;


//========================================================================
//========================================================================
sub UnlockApp(opt aError : alpha(1000); opt aUseWebApp : logic)
begin
  WinLayer(_WinLayerEnd);
  if (aUseWebApp = false) then
    Lib_DotNetServices:Remote_UnlockApp(aError);
end;


//========================================================================
//========================================================================
sub Cmd_Msg(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  vA      : alpha;
  vBA1    : int;
  vW      : word;
  vOK     : logic;
end;
begin
  if (aPreCheck) then RETURN '';

  vA # Str_Token(aCmd,'|',2);
  Msg(99,vA,1,1,0);
  RETURN '';
end;


//========================================================================
//========================================================================
sub Cmd_BaShowWebApp(
  aCmd      : alpha(1000);
  aPrecheck : logic;
  ) : alpha
local begin
  vA      : alpha;
  vBA1    : int;
  vW      : word;
  vOK     : logic;
end;
begin
  if (aPreCheck) then RETURN '';


  vA # Str_Token(aCmd,'|',2);
  // Token2 = "POS" oder "ID"
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vW, var vW);
  if (vBA1<=0) then RETURN 'BA fehlt';

  // VALIDIERUNG -----------------------------------------------------
  if (aPreCheck) then RETURN '';

  // AUSFÜHREN ---------------------------------------------------------
  BA1_Main:Start(0, vBA1, y, y);

  RETURN '';
end;


//========================================================================
//========================================================================
sub Cmd_BaShow(
  aCmd        : alpha(1000);
  aPrecheck   : logic;
  aUseWebApp  : logic;
  ) : alpha
local begin
  vA      : alpha;
  vBA1    : int;
  vW      : word;
  vOK     : logic;
end;
begin
  if (aPreCheck) then RETURN '';

  Lockapp(true);

  // "BaShow|12345|POS_1;IO_1;FERT_2/2;"
  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vW, var vW);
  if (vBA1<=0) then RETURN 'BA fehlt';

  // VALIDIERUNG -----------------------------------------------------
  if (aPreCheck) then RETURN '';

  // AUSFÜHREN ---------------------------------------------------------
  BA1_Main:Start(0, vBA1, y, y, Str_Token(aCmd,'|',3));
  UnLockapp('',true);

  RETURN '';
end;


//========================================================================
//========================================================================
sub Cmd_BaMerge(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vW      : word;
  v700    : int;
  vErr    : Alpha(4000);
end;
begin

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vW, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  vA # Str_Token(aCmd,'|',3);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA2, var vW, var vW);
  if (vBA2<=0) then RETURN 'BA B fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.Nummer # vBA2;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA2)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA2)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA2)+' hat schon Verwiegungen';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RETURN vErr;
  end;
  
  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
    TRANSON;

    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);

    if (BA1_P_Data:ImportBA(vBA1, vBA2, 0, 0, false)=0) then vErr # 'Import fehlgeschlagen';

    if (vErr='') then
      TRANSOFF
    else
      TRANSBRK;
  end;
  
  RekRestore(v700);
  WaitForSync();
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaMergePos(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha;
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vPos1   : word;
  vPos2   : word;
  vW      : word;
  v700    : int;
  v702    : int;
  vErr    : alpha(4000);
end;
begin

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  vA # Str_Token(aCmd,'|',3);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA2, var vPos2, var vW);
  if (vBA2<=0) then RETURN 'BA B fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);
  v702 # RekSave(702);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.Nummer # vBA2;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA2)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA2)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA2)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.P.Nummer    # vBA1;
    BAG.P.Position  # vPos1;
    Erx # RecRead(702,1,0);
    if (Erx<>_rOK) then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' nicht gefunden'
    else if ("BAG.P.Löschmarker"<>'') then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' ist gelöscht';
  end;

  if (vErr='') then begin
    BAG.P.Nummer    # vBA2;
    BAG.P.Position  # vPos2;
    Erx # RecRead(702,1,0);
    if (Erx<>_rOK) then vErr # 'BA-Pos. '+aint(vBA2)+'/'+aint(vPos2)+' nicht gefunden'
    else if ("BAG.P.Löschmarker"<>'') then vErr # 'BA-Pos. '+aint(vBA2)+'/'+aint(vPos1)+' ist gelöscht';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RekRestore(v702);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
    TRANSON;

    if (BA1_P_Data:Merge(vBA1, vPos1, vPos2)=false) then vErr # 'Merge fehgeschlagen';
  
    if (vErr='') then
      TRANSOFF
    else
      TRANSBRK;
  end;
  
  RekRestore(v700);
  RekRestore(v702);
  WaitForSync();
  winsleep(200);
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaMergeFert(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vW      : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin
  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vW, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  vA # Str_Token(aCmd,'|',3);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA2, var vW, var vW);
  if (vBA2<=0) then RETURN 'BA B fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.Nummer # vBA2;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA2)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA2)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA2)+' hat schon Verwiegungen';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
  // TODO
  end;

  RekRestore(v700);
  WaitForSync();
  Winsleep(200);
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaFertNextPos(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vPos1   : word;
  vFert1  : word;
  vW      : word;
  vPos2   : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin
// BA_FERT_NEXT_POS|10/1/1|10/5   [Lib_Remote:390]

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vFert1);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  vA # Str_Token(aCmd,'|',3);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA2, var vPos2, var vW);
  if (vBA2<=0) then RETURN 'BA B fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);
/***
  if (vOK) then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) or (BAG.VorlageYN) or (RecLinkInfo(707,700,5,_recCount)>0) then vOK # false;
  end;

  if (vOK) then begin
    BAG.Nummer # vBA2;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) or (BAG.VorlageYN) or (RecLinkInfo(707,700,5,_recCount)>0) then vOK # false;
  end;
***/
  if (vErr<>'') or (aPrecheck) then begin
    RekRestore(v700);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
    BA1_F_Subs:WeiterDurchPos(vBA1, vPos1, vFert1, vPos2);
  end;

  RekRestore(v700);
  WaitForSync();
  Winsleep(500);
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaFertNextNewPos(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vPos1   : word;
  vFert1  : word;
  vW      : word;
  vPos2   : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin
  if (aPreCheck) then RETURN '';

  Lockapp(true);

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vFert1);
  if (vBA1<=0) then RETURN 'BA fehlt';

  // VALIDIERUNG -----------------------------------------------------
  if (aPreCheck) then RETURN '';

  BAG.F.Nummer    # vBA1;
  BAG.F.Position  # vPos1;
  BAG.F.Fertigung # vFert1;
  Erx # Recread(703,1,0);
  if (erx>_rLocked) then RETURN 'Fertigung falsch';
//debugx('LOAD KEY703');
//Lib_Debug:Startbluemode();

  // AUSFÜHREN ---------------------------------------------------------
  BA1_Main:Start(0, vBA1, y, y, 'NEXTNEWPOS'+aint(RecInfo(703,_recId)));
  UnLockapp('',true);
  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaNewPos(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vPos1   : word;
  vFert1  : word;
  vW      : word;
  vPos2   : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin
// BA_NEW_POS|4711
  if (aPreCheck) then RETURN '';

  Lockapp(true);

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vW, var vW);
  if (vBA1<=0) then RETURN 'BA fehlt';

  // VALIDIERUNG -----------------------------------------------------
  if (aPreCheck) then RETURN '';

  // AUSFÜHREN ---------------------------------------------------------
  BA1_Main:Start(0, vBA1, y, y, 'NEWPOS');
  UnLockapp('',true);

  RETURN '';
end;


//========================================================================
//========================================================================
sub Cmd_BaMergeUpPos(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vBA2    : int;
  vPos1   : word;
  vPos2   : word;
  vW      : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  vA # Str_Token(aCmd,'|',3);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA2, var vPos2, var vW);
  if (vBA2=0) then RETURN 'BA B fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.Nummer # vBA2;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA2)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA2)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA2)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.P.Nummer    # vBA1;
    BAG.P.Position  # vPos1;
    Erx # RecRead(702,1,0);
    if (Erx<>_rOK) then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' nicht gefunden'
    else if ("BAG.P.Löschmarker"<>'') then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' ist gelöscht';
  end;

  if (vErr='') then begin
    BAG.P.Nummer    # vBA2;
    BAG.P.Position  # vPos2;
    Erx # RecRead(702,1,0);
    if (Erx<>_rOK) then vErr # 'BA-Pos. '+aint(vBA2)+'/'+aint(vPos2)+' nicht gefunden'
    else if ("BAG.P.Löschmarker"<>'') then vErr # 'BA-Pos. '+aint(vBA2)+'/'+aint(vPos2)+' ist gelöscht';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
    BAG.P.Nummer    # vBA1;
    BAG.P.Position  # vPos1;
    Erx # RecRead(702,1,0);
    call('SFX_BA1:MergeHoch',vPos2);
  end;
  
  RekRestore(v700);
  WaitForSync();
  winsleep(500);
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaIgnoreRso(
  aCmd      : alpha(1000);
  aPrecheck : logic) : Alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vPos1   : word;
  vW      : word;
  v700    : int;
  v702    : int;
  vErr    : alpha;
end;
begin

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);
  v702 # RekSave(702);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr='') then begin
    BAG.P.Nummer    # vBA1;
    BAG.P.Position  # vPos1;
    Erx # RecRead(702,1,0);
    if (Erx<>_rOK) then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' nicht gefunden'
    else if ("BAG.P.Löschmarker"<>'') then vErr # 'BA-Pos. '+aint(vBA1)+'/'+aint(vPos1)+' ist gelöscht';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RekRestore(v702);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
// TODO
    Call('SFX_BA1_P_Restrikt:Ignore',true);
  end;
  
  RekRestore(v700);
  RekRestore(v702);
  WaitForSync();
  winsleep(250);
  UnlockApp();

  RETURN vErr;
end;


//========================================================================
//========================================================================
sub Cmd_BaCheckPlan(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha;
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vPos1   : word;
  vW      : word;
  v700    : int;
  vErr    : alpha(4000);
end;
begin

  vA # Str_Token(aCmd,'|',2);
  Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vW);
  if (vBA1<=0) then RETURN 'BA A fehlt';

  // VALIDIERUNG -----------------------------------------------------
  v700 # RekSave(700);

  if (vErr='') then begin
    BAG.Nummer # vBA1;
    Erx # RecRead(700,1,0);
    if (Erx<>_rOK) then vErr # 'BA '+aint(vBA1)+' nicht gefunden'
    else if (BAG.VorlageYN) then vErr # 'BA '+aint(vBA1)+' ist eine Vorlage'
    else if (RecLinkInfo(707,700,5,_recCount)>0) then vErr # 'BA '+aint(vBA1)+' hat schon Verwiegungen';
  end;

  if (vErr<>'') or (aPreCheck) then begin
    RekRestore(v700);
    RETURN vErr;
  end;

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
// TODO
    Call('SFX_BA1_P_Restrikt:CheckBagRwPlg',true);
  end;
  
  RekRestore(v700);
  WaitForSync();
  winsleep(250);
  UnlockApp();

  RETURN vErr
end;

//========================================================================
//========================================================================
sub Cmd_BaNachspaltungAnlegen(
  aCmd      : alpha(1000);
  aPrecheck : logic) : alpha
local begin
  Erx     : int;
  vA      : alpha;
  vBA1    : int;
  vPos1   : word;
  vW      : word;
  vErr    : alpha;
  vOK     : logic;
  vI      : int;
  vMax    : int;
  v702    : int;
end;
begin
  // BA_NACHSPALTEN|BaNr/Pos|BaNr/Pos|BaNr/Pos max 10

  v702 # RekSave(702);

  // AUSFÜHREN ---------------------------------------------------------
  Lockapp();

  if (cDemo=false) then begin
    Lib_Mark:Reset(702);    // alle 702er Markierungen entfernen
    
    vMax # Str_Count(aCmd,'|');   // Gesamtzahl ermitteln
    
    FOR vI # 1
    LOOP inc(vI)
    WHILE (vI<=vMax) and (vErr='') do begin
      vA # Str_Token(aCmd,'|',vI+1);
      Lib_Berechnungen:IntsAusAlpha(vA, var vBA1, var vPos1, var vW);
      if (vBA1<=0) then begin
        vErr # 'BA fehlt';
        BREAK;
      end;

      BAG.P.Nummer    # vBA1;
      BAG.P.Position  # vPos1;
      Erx # RecRead(702,1,0);
      if (Erx>_rLocked) then begin
        vErr # 'BA '+vA+' nicht gefunden';
        BREAK;
      end;
      Lib_Mark:MarkAdd(702, true, true, 0);
    END; // Ende der Parameter
    
    if (vErr='') and (aPreCheck=false) then begin
      vOK # call('SFX_BA1_P:SFX.NachSpalten', true);
    end;
  end;
  
  RekRestore(v702);
  WaitForSync();
  UnlockApp();

  return vErr;
end;

//========================================================================
