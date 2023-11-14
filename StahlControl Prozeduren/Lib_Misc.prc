@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Misc
//                        OHNE E_R_G
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB BuildSel(var aHdl : int; aFile : int; aSelOrgName : alpha; aRunYN : logic; aKey : int) : alpha;
//    SUB SelSaveRun(var aHdl : int; aKey : int) : alpha;
//    SUB SelRecList(aRecList : int; aSelName : alpha; optaSuffix : alpha);
//
//========================================================================
@I:Def_global

define begin
  c_debugUser : 'AIxx'
end;

//========================================================================
//  BuildSel
//
//========================================================================
sub BuildSel(
  var aHdl    : int;
  aFile       : int;
  aSelOrgName : alpha;
  aRunYN      : logic;
  aKey        : int) : alpha;
local begin
  vSelname  : alpha;
  vTmp      : int;
  vZList    : int;
end;
begin
  vZList # gZLList;

  if (VarInfo(class_list)<>0) then
    vSelName # 'TMP.'+ UserInfo(_UserCurrent)+'.List'
  else
    vSelName # 'TMP.'+ UserInfo(_UserCurrent);

  SelDelete(aFile,vSelName);

  vTmp # SelCopy(aFile,aSelOrgName,vSelName);
  if (aHdl=0) then aHdl # SelOpen();

  vTmp # SelRead(aHdl,aFile,_SelLock,vSelName);

  // Selektion auch starten?
  if (aRunYN) then begin

    // Umsortieren?
    if (aKey<>0) then SelInfo(aHdl,_SelSort,aKey);

    if (gUserName=c_debuguser) then
      SelRun(aHdl,_SelDisplay | _selWait | _SelServer | _SelServerAutoFld)
    else
      SelRun(aHdl,_SelDisplay| _SelServer | _SelServerAutoFld);
  end;

//  gFrmMain->winfocusset();
  if (gMDI<>0) then begin
    gMDI->winfocusset(true);
    winsleep(100);
    gZLList # vZList;
  end;

  RETURN vSelName;
end;


//========================================================================
//  SelRecList
//
//========================================================================
sub SelRecList(
  aRecList    : int;
  aSelName    : alpha;
  opt aSuffix : alpha);
local begin
  vSel  : alpha;
  vHdl  : int;
  vFile : int;
end;
begin
  if (aRecList=0) then aRecList # gZLList;
  if (aRecList=0) then RETURN;

  // bereits selektiert?
  if (aRecList->wpDbSelection<>0) then begin  // dann löschen
    vHdl # aRecList->wpdbselection;
    aRecList->wpDbSelection # 0;
    SelClose(vHdl);
  end;

  vFile # aRecList->wpDbFileNo;
  vSel # 'TMP.'+ UserInfo(_UserCurrent)+aSuffix;

  vHdl # VarInfo(WindowBonus);
  varInstance(WindowBonus, Cnvia(gMDI->wpcustom));
  if (w_selname<>'') then begin // bisherige temp.Selektion entfernen
    SelDelete(vFile,w_selName);
  end;
  w_SelName # vSel;
  varInstance(WindowBonus, vHdl);

  SelCopy(vFile,aSelName,vSel);
  vHdl # SelOpen();
  SelRead(vHdl,vFile,_SelLock,vSel);

  // ggf. umsortieren...
//debug('key:'+cnvai(gKey)+'   fileno:'+cnvai(aRecList->wpdbLinkFileNo));
  if (SelInfo(vHdl,_SelSort)<>aRecList->wpDbKeyNo) and (aRecList->wpDbLinkFileNo=0) then begin
    SelInfo(vHdl,_SelSort,aRecList->wpdbKeyno);
  end;

  if (gUserName=c_debuguser) then
    SelRun(vHdl,_SelDisplay | _selwait | _SelServer | _SelServerAutoFld)
  else
    SelRun(vHdl,_SelDisplay| _SelServer | _SelServerAutoFld);
  aRecList->wpDbSelection # vHdl;
//debug('set:'+cnvai(aRecList));
  RETURN;
end;

//========================================================================
//========================================================================
sub AddTodo(
  aWas          : alpha);
begin
  Tmp.Todo.UserID  # gUserID;
  Tmp.Todo.Text    # StrCut(aWas,1,32);
  RecInsert(996,0);
end;




//========================================================================
//========================================================================
sub DelTodo(
  aWas          : alpha) : int
local begin
  Erx : int;
end;
begin
  Tmp.Todo.UserID  # gUserID;
  Tmp.Todo.Text    # StrCut(aWas,1,32);
  Erx # RecDelete(996,0);
  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//========================================================================
sub ExistsTodo(
  aWas          : alpha) : Logic
begin
  Tmp.Todo.UserID  # gUserID;
  Tmp.Todo.Text    # StrCut(aWas,1,32);
  RETURN RecRead(996,1,0)<=_rLocked;
end;


//========================================================================
//========================================================================
sub ProcessTodos() : logic;
local begin
  Erx : int;
  vA  : alpha;
end;
begin

  // MEINE Todos loopen...
  GV.Sys.UserID     # gUserID;
  FOR Erx # RecLink(996,999,11,_recFirst)
  LOOP Erx # RecLink(996,999,11,_recFirst)
  WHILE (Erx<=_rLocked) do begin
    Erx # RekDelete(996);
    vA # StrCnv(Str_Token(Tmp.Todo.Text,'|',1),_StrUpper);
    
    case vA of
      'AUF.A.RECALC' : begin
        Auf.P.Nummer    # cnvia(Str_Token(Tmp.Todo.Text,'|',2));
        Auf.P.Position  # cnvia(Str_Token(Tmp.Todo.Text,'|',3));
        Erx # RecRead(401,1,0);
        if (Erx>_rLocked) then RETURN False;
        if (Auf_A_Data:RecalcAll()=false) then begin
          RETURN false;
        end;
      end;
    end;
  END;

  RETURN true;
end;


//========================================================================