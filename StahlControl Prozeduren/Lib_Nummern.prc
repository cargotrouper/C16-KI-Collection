@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Nummern
//                      OHNE E_R_G
//  Info
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  01.12.2017  AH  AFX "Lib_Nummern.Name"
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  18.11.2020  AH  "Validiere"
//  04.02.2021  AH  Valdiere auch 280=Pakete
//  15.03.2021  AH  Valdiere auch 400,500,200,700,230
//  27.07.2021  AH  ERX
//  2022-07-07  AH  DEADLOCK
//
//  Subprozeduren
//    SUB Validiere(var aNr : int; aDatei : int);
//    SUB ReadNummerOnce(aName : alpha) : int
//    SUB ReadNummer(aName : alpha) : int
//    SUB SaveNummer()
//    SUB FreeNummer() : logic
//    SUB RestoreNummer(aName : alpha; aNr : int) : logic
//
//========================================================================
@I:Def_global

define begin
  cUnittester     : 'UNITTEST'
  cUnitTestDelta  : 50000000
end;
// Delta    :   50000000
// max int  : 2147483647
// Tmp      : 1000000000+gUserId
// viele CNV nur 8 !!!

//========================================================================
//  Validiere
//    prüft, ob die Nummer wirklich frei ist
//========================================================================
sub Validiere(
  var aNr : int;
  aDatei  : int;
)
local begin
  vBuf  : int;
  vErg  : int;
end;
begin
 
  case (aDatei) of
    120 : begin
      vBuf # RecBufCreate(120);
      REPEAT
        vBuf->Prj.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;

    200 : begin
      vBuf # RecBufCreate(200);
      REPEAT
        vBuf->Mat.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;

    203 : begin // 01.06.2022 AH
      vBuf # RecBufCreate(203);
      REPEAT
        vBuf->Mat.R.Reservierungnr # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;


    230 : begin
      vBuf # RecBufCreate(230);
      REPEAT
        vBuf->Lys.K.Analysenr # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;


    280 : begin
      vBuf # RecBufCreate(280);
      REPEAT
        vBuf->Pak.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;

    401,400 : begin
      vBuf # RecBufCreate(401);
      REPEAT
        vBuf->Auf.P.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
      vBuf # RecBufCreate(400);
      REPEAT
        vBuf->Auf.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;

    501,500 : begin
      vBuf # RecBufCreate(501);
      REPEAT
        vBuf->Ein.P.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
      vBuf # RecBufCreate(500);
      REPEAT
        vBuf->Ein.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;


    700 : begin
      vBuf # RecBufCreate(700);
      REPEAT
        vBuf->BAG.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;


    980 : begin
      vBuf # RecBufCreate(980);
      REPEAT
        vBuf->TeM.Nummer # aNr;
        vErg # RecRead(vBuf,1,_RecTest);
        if (vErg<=_rLocked) then begin
DbaLog(_LogWarning, N, 'Nummerkreis-Automatik-Reparatur: '+Prg.Nr.Name);
          inc(aNr);
          CYCLE;
        end;
      UNTIL (1=1);
      RecBufDestroy(vBuf);
    end;

  end;
  
end;


//========================================================================
//ReadNummerOnce(Name)
//
//========================================================================
sub ReadNummerOnce(
  aName         : alpha;
  var aRes      : int;
) : int
local begin
  Erx   : int;
  vCnt  : int;
end;
begin

  aRes # 0;
  vCnt # 0;
  REPEAT
    Prg.Nr.Name         # aName;

    // 01.12.2017
    RunAFX('Lib_Nummern.Name','');

    Erx # RecRead(902,1,_RecLock);
    if (Erx=_rOk) then begin
      Validiere(var Prg.Nr.Nummer, Prg.Nr.Datei);
      aRes # Prg.Nr.Nummer;
      if (gUsername=cUnittester) then begin
        aRes # aRes + cUnitTestDelta;
      end;
      RETURN Erx;
    end;

    RecRead(902,1,_RecUnLock);
    if (Erx=_rdeadlock) then RETURN Erx;    // 2022-07-07 AH
    vCnt # vCnt + 1;
    winSleep(333);
  UNTIL (vCnt=3);

  RETURN Erx;
end;


//========================================================================
//  ReadNummer(Name)
//
//========================================================================
sub ReadNummer(
  aName         : alpha;
) : int
local begin
  vNr     : int;
  vCount  : int;
  Erx     : int;
end;
begin

  if (gUsergroup='JOB-SERVER') OR (gUsergroup='SOA_SERVER') then begin
    Erx # ReadNummerOnce(aName, var vNr);
    if (Erx<>_rOK) then RETURN 0;
    RETURN vNr;
  end;
  
  vCount # 0;
  REPEAT
    vCount # vCount + 1;
    Erx # ReadNummerOnce(aName, var vNr);
    if (Erx=_rOK) then RETURN vNr;
    if (Erx=_rDeadLock) then RETURN 0;
    if (Erx<>_rOK) then begin
      Msg(902001,aName+'|'+UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0);
    end;
  UNTIL (vNr<>0) or (vCount=10);

  if (vNr=0) then
    Msg(902003,aName+'|'+UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0);

  RETURN vNr;
end;


//========================================================================
//  SaveNummer
//
//========================================================================
sub SaveNummer() : int
local begin
  Erx : int;
end;
begin
  Prg.Nr.Nummer # Prg.Nr.Nummer + 1;
//  Erx # RekReplace(902,_RecUnlock,'');    15.03.2021
  Erx # RecReplace(902,_RecUnlock);
  if (erx<>_rOK) then begin
    DbaLog(_LogWarning, N, 'NUMMERNSYSTEM Prob: kein Replace von '+Prg.Nr.Name);
    Msg(902002,Prg.Nr.Name,0,0,0);
    ErxError(902002,Prg.Nr.Name);
  end;

  RETURN Erx;
end;


//========================================================================
//  FreeNummer
//
//========================================================================
sub FreeNummer() : logic
begin
  RETURN (RecRead(902,1,_RecUnlock)=_rOK);
end;

/*** 24.03.2022 machen wir doch schon lange nicht mehr?? AH
//========================================================================
//  RestoreNummer(aName : alpha; aN
//
//========================================================================
sub RestoreNummer(
  aName         : alpha;
  aNr           : int;
) : logic
local begin
  Erx     : int;
  vNr     : int;
  vCount  : int;
end;
begin

  vCount # 0;
  REPEAT
    vCount # vCount + 1;
    vNr # ReadNummerOnce(aName);
    if (vNr=0) then begin
      Msg(902001,aName+'|'+UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0);
    end;
  UNTIL (vNr<>0) or (vCount=10);

  if (vNr=0) then begin
    Msg(902003,aName+'|'+UserInfo(_UserName,CnvIA(UserInfo(_UserLocked))),0,0,0);
    FreeNummer();
    RETURN false;
  end;

  if (vNr-1<>aNr) then begin
    FreeNummer();
    RETURN false;
  end;

  Dec(Prg.Nr.Nummer);
  Erx # RekReplace(902,_RecUnlock,'');
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;
***/
//========================================================================
//========================================================================
//========================================================================
