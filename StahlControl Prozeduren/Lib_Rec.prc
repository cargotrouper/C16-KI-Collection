@A+
//==== Business-Control ==================================================
//
//  Prozedur    Lib_Rec
//                      OHNE E_R_G
//  Info        Beinhaltet alle Datenbankbefehle
//
//
//  05.02.2003  AI  Erstellung der Prozedur
//  22.10.2012  AI  NEU: Scopes
//  10.01.2014  AH  "Replace" mit opt- Selektion
//  09.01.2015  AH  "replace," "Insert", "Delete" mit optionalen aOpt und aTyp
//  09.03.2015  ST  "RekTransOff(...)" keine Meldung fü∑r SOA- oder Jobserver-Nutzung
//  10.11.2015  AH  "Upgrade57to58" für Client 5.8
//  12.05.2016  AH  PtdSync
//  08.06.2016  AH  BugFix PtdSync
//  01.07.2016  AH  Criticial-Management
//  26.10.2017  AH  BugFix: "_CommitAllScopes" für Temp.Daten, die innerhalb Scope INSERT und REPLACE PrimKey haben
//  19.11.2018  ST  Usergruppe "SOA_Server" integriert
//  14.01.2019  AH  BugFix: RecDelete mit CustomBuffer hatte falsche RecId für Sync
//  08.07.2021  AH  Transaktion-RamList
//  27.07.2021  AH  ERX
//  17.08.2021  AH  Fix für RekDelete und ERX
//  28.10.2021  AH  Fix für Deadlocks und TransCounter
//  2023-08-22  AH  "LoopDataAndReplaceByQuery"
//
//  Subprozeduren
//    SUB MakeKey(aDatei : int; opt aNoPoint : logic): alpha;
//    SUB SetKeyFields(aDatei : int; aKey : alpha) : int;
//    SUB ReadByKey(aDatei : int; aKey : alpha) : int
//    SUB _NewScope();
//    SUB _DelScope(aScope : int);
//    SUB _ScopeRec(aTyp : alpha(5); aFile : int);
//    SUB _ScopeText(aTyp : alpha(5); aName : alpha(32); opt aName2 : alpha(32));
//    SUB _CommitAllScopes();
//
//    SUB Insert(aDatei : int; opt aOpt : int; opt aTyp : alpha) : int
//    SUB Replace(aDatei : int; opt aOpt : int; opt aTyp : alpha; opt aSel :int) : int
//    SUB Delete(aDatei : int; opt aOpt : int; opt aTyp : alpha) : int
//    SUB DeleteAll(aDatei : int);
//
//    SUB LinkConst(var aBufD : int; aBufS : int ;aLink : int; aMode : int) : int;
//    SUB LinkBuf(var aBufD : int; aBufS : int ;aLink : int; aMode : int) : int;
//    SUB BufKill(var aBuf);

//    SUB RekTransOn();
//    SUB RekTransOff();
//    SUB RekTransBrk();
//    SUB _RekSave(aDatei : int) : int
//    SUB _RekRestore(aHdl : int; aDatei : int);
//    SUB ClearFile(aFile : int; opt aType : alpha)
//    SUB LoopDataAndReplaceByQuery
//
//========================================================================
@I:Def_Global


define begin
  cPtdSync      : Set.SQL.SoaYN
  cPtdDirekt    : false   // false=> über SCOPE lösen
end;

//========================================================================
// StampDB
//
//========================================================================
sub StampDB();
begin

  if (cPtdSync) then RETURN;

  Version.Stamp->vmServerTime();
//  if (TransActive) then RETURN;

  if (Version.lfdNr=0) then begin
    //if ( StrFind(StrCnv( DbaName( _dbaAreaAlias ), _strUpper ),'TESTSYSTEM',1) > 0) then begin
    if (isTestsystem) then begin
      Version.lfdNr # 100;    // bin Testsystem
    end
    else begin
      Version.lfdNr # 1;      // bin Echtsystem
    end;
  end;

  RecDelete(997,0);
  RecInsert(997,_recunlock);

  if (TransActive=false) and (gBlueMode=false) then
    Lib_ODBC:TransferStamp();

//debug('stamp :'+cnvab(version.Stamp));

end;


//========================================================================
// MakeKey(Datei)
//              generiert einen String aus den eindeutigen Schlüsselfeldern
//========================================================================
sub MakeKey(
  aDateiHdl     : int;
  opt aNoPoint  : logic;
  opt aSep      : alpha;
//  opt aBuf      : int;
): alpha;
local begin
  vn      : int;
  vX      : int;
  vY      : int;
  vKey    : alpha;
  vDatei  : int;
end;
begin

  if (aDateiHdl=0) then RETURN '';

  if (aSep='') then aSep # StrChar(255,1);

  if (HdlInfo(aDateiHdl, _HdlExists)>0) then begin
    vDatei # HdlInfo(aDateiHdl, _HdlSubType);
  end
  else begin
    vDatei # aDateiHdl;
  end;

  if (FileInfo(vDatei,_FldExists)<1) then RETURN '';

  // 26.03.2020 AH:
  if (vDatei=916) then begin
    vKey # CnvAI(Anh.Datei) + aSep;
    vKey # vKey + CnvAB(Anh.ID)+aSep;
    RETURN vKey;
  end;

  vKey # '';
  vN # KeyInfo(vDatei, 1, _KeyFldCount);
  FOR vY # 1 loop inc(vY) while (vY<=vN) do begin
    vX # KeyFldInfo(vDatei,1,vY,_KeyFldNumber);

    if (aNoPoint=false) then begin
      case FldInfo(vDatei,1,vX,_KeyFldType) of
        _TypeAlpha  : vKey # vKey + FldAlpha(aDateiHdl,1,vX);
        _TypeWord   : vKey # vKey + CnvAI(FldWord(aDateiHdl,1,vX));
        _TypeInt    : vKey # vKey + CnvAI(FldInt(aDateiHdl,1,vX));
        _TypeBigInt : vKey # vKey + CnvAB(FldBigInt(aDateiHdl,1,vX));
        _TypeFloat  : vKey # vKey + CnvAF(FldFloat(aDateiHdl,1,vX));
        _TypeDate   : vKey # vKey + CnvAD(FldDate(aDateiHdl,1,vX));
        _TypeTime   : vKey # vKey + CnvAT(FldTime(aDateiHdl,1,vX));
        _TypeLogic  : if FldLogic(aDateiHdl,1,vX) then vKey # vKey + 'y'
                      else                        vKey # vKey + 'n';
      end;
    end
    else begin
      case FldInfo(vDatei,1,vX,_KeyFldType) of
        _TypeAlpha  : vKey # vKey + FldAlpha(aDateiHdl,1,vX);
        _TypeWord   : vKey # vKey + CnvAI(FldWord(aDateiHdl,1,vX),_FmtNumNoGroup);
        _TypeInt    : vKey # vKey + CnvAI(FldInt(aDateiHdl,1,vX),_FmtNumNoGroup);
        _TypeBIgInt : vKey # vKey + CnvAB(FldBigInt(aDateiHdl,1,vX),_FmtNumNoGroup);
        _TypeFloat  : vKey # vKey + CnvAF(FldFloat(aDateiHdl,1,vX),_FmtNumNoGroup);
        _TypeDate   : vKey # vKey + CnvAD(FldDate(aDateiHdl,1,vX));
        _TypeTime   : vKey # vKey + CnvAT(FldTime(aDateiHdl,1,vX));
        _TypeLogic  : if FldLogic(aDateiHdl,1,vX) then vKey # vKey + 'y'
                      else                        vKey # vKey + 'n';
      end;
    end;

    vKey # vKey + aSep;
  END;

  RETURN vKey;
end;


//========================================================================
// SetKeyFields
//
//========================================================================
sub SetKeyFields(
  aDatei        : int;
  aKey          : alpha;
) : int;
local begin
  vn    : int;
  vX    : int;
  vY    : int;
  vKey  : alpha;
  vA    : alpha;
end;
begin

  if (aDatei=0) then RETURN _rNorec;
  if (FileInfo(aDatei,_FldExists)<1) then RETURN _rNoRec;

  vN # KeyInfo(aDatei, 1, _KeyFldCount);
  FOR vY # 1 loop inc(vY) while (vY<=vN) do begin

    vA # Str_Token(aKey,strchar(255,1),vY);
    vX # KeyFldInfo(aDatei,1,vY,_KeyFldNumber);

    case FldInfo(aDatei,1,vX,_KeyFldType) of
      _TypeAlpha  : FldDef(aDatei, 1, vX, vA);
      _TypeWord   : FldDef(aDatei, 1, vX, cnvia(vA));
      _TypeInt    : FldDef(aDatei, 1, vX, cnvia(vA));
      _TypeFloat  : FldDef(aDatei, 1, vX, cnvfa(vA));
      _TypeDate   : FldDef(aDatei, 1, vX, cnvda(vA));
      _TypeTime   : FldDef(aDatei, 1, vX, cnvta(va));
      _TypeLogic  : FldDef(aDatei, 1, vX, vA='y');
    end;

  END;

  RETURN _rOK;
end;


//========================================================================
// ReadByKey(Datei, Key)
//
//========================================================================
sub ReadByKey(
  aDatei        : int;
  aKey          : alpha;
) : int;
local begin
  Erx   : int;
  vI    : int;
end;
begin

  if (aDatei=916) then begin    // 26.03.2020 AH
    Anh.Datei # cnvia(Str_Token(aKey,strchar(255,1),1));
    Anh.ID    # cnvba(Str_Token(aKey,strchar(255,1),2));
    Erx # RecRead(916,3,0);
    if (Erx<=_rMultikey) then begin
      Erx # RecRead(aDatei,1,0)
      Erg # Erx;    // TODOERX
      RETURN Erx;
    end;
    Erg # _rNoRec;  // TODOERX
    RETURN _rnoRec;
  end;
  
  Erx # SetKeyFields(aDatei, aKey);
  if (erx<>_rOK) then begin
    Erg # _rOK;  // TODOERX
    RETURN _rOK;
  end;

  Erx # RecRead(aDatei,1,0)
  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  _NewScope
//
//========================================================================
sub _NewScope();
local begin
  vScope  : int;
end;
begin
  if (gScopeList=00) then RETURN;
  vScope # CteOpen(_cteItem);
  vScope->spname    # 'scope'+aint(1 + CteInfo(gScopeList,_ctecount));
  vScope->spId      # gScopeActual;   // parent
  vScope->spcustom  # aint(CteOpen(_CteList));
  gScopeList->CteInsert(vScope,_CteLast);
  if (gScopeActual=0) then gScopeTic # 0;
  gScopeActual # vScope;

//debug('new scope '+gScopeActual->spname+' ['+aint(gScopeActual)+']   parent: '+aint(vScope->spid));
//debug('new scope '+gScopeActual->spname);

end;


//========================================================================
//  _DelScope
//
//========================================================================
sub _DelScope(aScope : int);
begin
  // kill history
  CteClear(cnvia(aScope->spcustom),y);
  // kill scope
  CteDelete(gScopeList, aScope);
  CteClose(aScope);
end;


//========================================================================
//  _ScopeRec
//
//========================================================================
sub _ScopeRec(
  aTyp        : alpha(5);
  aFile       : int;
  aRecID      : int);
local begin
  vA    : alpha(200);
  vBuf  : int;
end;
begin
  if (aFile>999) then begin
//    TODO(aTyp+' _ScopeIt for Buffer '+aint(HdlInfo(aFile,_HdlSubType)));
    vBuf  # aFile;
    aFile # HdlInfo(vBuf,_HdlSubType);
    if (aRecID=0) then aRecID # RecInfo(vBuf, _RecId);
    inc(gScopeTic);
    //vA # aTyp + '|'+ cnvai(aFile,_FmtNumLeadZero|_FmtNumNoGroup,0,3)+'|'+MakeKey(aFile,y, vBuf)+'|'+cnvai(aRecID);
    vA # aTyp + '|'+ cnvai(aFile,_FmtNumLeadZero|_FmtNumNoGroup,0,3)+'|'+MakeKey(vBuf,y)+'|'+cnvai(aRecID);
  end
  else begin
    if (aRecID=0) then aRecID # RecInfo(aFile, _RecId);
    inc(gScopeTic);
    vA # aTyp + '|'+ cnvai(aFile,_FmtNumLeadZero|_FmtNumNoGroup,0,3)+'|'+MakeKey(aFile,y)+'|'+cnvai(aRecID);
  end;

  CteInsertItem(cnvia(gScopeActual->spcustom), cnvai(gScopeTic,_FmtNumLeadZero|_FmtNumNoGroup, 0,8), gScopeTic, vA);
end;


//========================================================================
//  _ScopeText
//
//========================================================================
sub _ScopeText(
  aTyp        : alpha(5);
  aName       : alpha(20);
  opt aName2  : alpha(20));
local begin
  vA  : alpha(200);
end;
begin
  inc(gScopeTic);
  vA # aTyp + '|'+ aName;
  if (aName2<>'') then vA # vA + '|'+ aName2;
  CteInsertItem(cnvia(gScopeActual->spcustom), cnvai(gScopeTic,_FmtNumLeadZero|_FmtNumNoGroup, 0,8), gScopeTic, vA);
end;


//========================================================================
//  _CommitAllScopes();
//
//========================================================================
Sub _CommitAllScopes();
local begin
  vHist   : int;
  vItem   : int;
  vTree   : int;
  vTyp    : alpha;
  vFile   : int;
  vBuf    : int;
  vKey    : alpha(4096);
  vRecID  : int;
  vErg    : int;
  myErg   : int;
end;
begin
//debug('---COMMIT ALL---');

  // Sorttree
  vTree # CteOpen(_CteTree);

  gScopeActual # CteRead(gScopeList,_CteLast);
  WHILE (gScopeActual<>0) do begin
//debug('commit '+gScopeActual->spname);
    vHist # cnvia(gScopeActual->spcustom);
    FOR vItem # CteRead(vHist, _CteFirst)
    LOOP vItem # CteRead(vHist, _CteFirst)
    WHILE (vItem<>0) do begin

      // sort history:
      CteInsertItem(vTree, vItem->spname, vItem->spId, vItem->spcustom);

      CteDelete(vHist, vItem);
      CteClose(vItem);
    END;

    _DelScope(gScopeActual);

    gScopeActual # CteRead(gScopeList,_CteLast);
  END;


  // loop history:
  FOR vItem # CteRead(vTree, _Ctefirst)
  LOOP vItem # CteRead(vTree, _Ctefirst)
  WHILE (vItem<>0) do begin

//debug('committing: '+vItem->spname+' , '+vItem->spcustom);
    vTyp    # Str_Token(vItem->spcustom,'|',1);
//if (strcut(vTyp,1,1)='R') then begin
//    vFile   # cnvia(Str_Token(vItem->spcustom,'|',2));
//debug(vTyp+' '+aint(vFile));
//end;

    case vTyp of

      'RI' : begin   // INSERT
        vFile   # cnvia(Str_Token(vItem->spcustom,'|',2));
        vKey    # Str_Token(vItem->spcustom,'|',3);
        vRecID  # cnvia(Str_Token(vItem->spcustom,'|',4));
        vBuf # RecBufCreate(vFile);
        RecBufCopy(vFile, vBuf);
        vErg # Erg;   // TODOERX

        MyErg # ReadByKey(vFile, vKey);
        if (MyErg>_rLocked) then
          MyErg # RecRead(vFile, 0, _RecId, vRecID)
        if (MyErg<=_rOK) then begin
//debug('ok');
          if (cPtdSync) then
            Lib_Sync:Insert(vFile, vRecID)
          else
            Lib_ODBC:Insert(vFile, vRecID);
        end
        else begin
//debugx('not found!');
        end;
        Erg # vErg;   // TODOERX
        RecBufCopy(vBuf,vFile);
        RecBufDestroy(vBuf);
      end;

      'RU' : begin   // UPDATE
        vFile   # cnvia(Str_Token(vItem->spcustom,'|',2));
        vKey    # Str_Token(vItem->spcustom,'|',3);
        vRecID  # cnvia(Str_Token(vItem->spcustom,'|',4));
        vBuf # RecBufCreate(vFile);
        RecBufCopy(vFile, vBuf);
        vErg # Erg;   // TODOERX

        MyErg # ReadByKey(vFile, vKey);
        if (MyErg>_rLocked) then
          MyErg # RecRead(vFile, 0, _RecId, vRecID)
        if (MyErg<=_rOK) then begin
          if (cPtdSync) then
            Lib_Sync:Update(vFile, RecInfo(vFile, _recId))
          else
            Lib_ODBC:Update(vFile);
        end
        else begin
//debugx('not found!');
        end;
        Erg # vErg;   // TODOERX
        RecBufCopy(vBuf,vFile);
        RecBufDestroy(vBuf);
      end;

      'RD' : begin   // DELETE
        vFile   # cnvia(Str_Token(vItem->spcustom,'|',2));
        vKey    # Str_Token(vItem->spcustom,'|',3);
        vRecID  # cnvia(Str_Token(vItem->spcustom,'|',4));
        vBuf # RecBufCreate(vFile);
        RecBufCopy(vFile, vBuf);
        vErg # Erg;   // TODOERX
        if (SetKeyFields(vFile, vKey)=_rOK) then begin
          if (cPtdSync) then
            Lib_Sync:Delete(vFile, vRecID)
          else
            Lib_ODBC:Delete(vFile, vRecId);
        end
        else begin
        end;
        Erg # vErg;   // TODOERX
        RecBufCopy(vBuf,vFile);
        RecBufDestroy(vBuf);
      end;

      'CLR' : begin   // CLEAR FILE
        vFile   # cnvia(Str_Token(vItem->spcustom,'|',2));
        vKey    # Str_Token(vItem->spcustom,'|',3);
        vRecID  # cnvia(Str_Token(vItem->spcustom,'|',4));
        if (cPtdSync) then
          Lib_Sync:DeleteAll(vFile)
        else
          Lib_ODBC:DeleteAll(vFile);
      end;


      // -------- TEXTE ---------------
      'TI' : begin
        vKey    # Str_Token(vItem->spcustom,'|',2);
        if (cPtdSync) then
          Lib_Sync:InsertText(vKey)
        else
          Lib_ODBC:InsertText(vKey);
      end;
      'TCR' : begin
        vKey    # Str_Token(vItem->spcustom,'|',2);
        if (cPtdSync) then
          Lib_Sync:CreateText(vKey)
        else
          Lib_ODBC:CreateText(vKey);
      end;
      'TD' : begin
        vKey    # Str_Token(vItem->spcustom,'|',2);
        if (cPtdSync) then
          Lib_Sync:DeleteText(vKey)
        else
          Lib_ODBC:DeleteText(vKey);
      end;
      'TR' : begin
        if (cPtdSync) then
          Lib_Sync:RenameText(Str_Token(vItem->spcustom,'|',2), Str_Token(vItem->spcustom,'|',3))
        else
          Lib_ODBC:RenameText(Str_Token(vItem->spcustom,'|',2), Str_Token(vItem->spcustom,'|',3));
      end;
      'TCO' : begin
        if (cPtdSync) then
          Lib_Sync:InsertText(Str_Token(vItem->spcustom,'|',2), Str_Token(vItem->spcustom,'|',3))
        else
          Lib_ODBC:InsertText(Str_Token(vItem->spcustom,'|',2), Str_Token(vItem->spcustom,'|',3));
      end;

    end;

    CteDelete(vTree, vItem);
    CteClose(vItem);
  END;

end;


//========================================================================
//  Insert
//
//========================================================================
sub Insert(
  aDatei    : int;
  opt aOpt  : int;
  opt aTyp  : alpha;  // MAN=Manuell
) : int
local begin
  Erx     : int;
  vRecId  : int;
end;
begin

  // 01.07.2016
  Crit_Prozedur:PauseBeiBedarf();


  if (aOpt=0) then aOpt # _recunlock;
  if (aTyp='') then aTyp # 'AUTO';

  // AFX
  if (aDatei<>923) then
    RunAFX('Rec_RekInsert',AInt(aDatei)+'|'+AInt(aOpt)+'|'+aTyp);

  Erx # RecInsert(aDatei,aOpt);
  vRecID # RecInfo(aDatei, _recId);

  if (Erx<>_rOK) then begin
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gSCopeActual=0)) then begin
    Lib_SYNC:Insert(aDatei, vRecID);
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end
  if (gScopeActual<>0) then begin
    _ScopeRec('RI',aDatei, vRecID);
  end
  else begin
    StampDB();
    Lib_ODBC:Insert(aDatei, vRecID);
  end;

  Erg # Erx;  // TODOERX
  RETURN erx;
end;


//========================================================================
//  Replace
//
//========================================================================
sub Replace(
  aDatei    : int;
  opt aOpt  : int;
  opt aTyp  : alpha;    // MAN=Manuell
  opt aSel  : int;
) : int
local begin
  Erx     : int;
  vBuf    : int;
  vRecID  : int;
  vSelErg : int;
//  vA : alpha;
end;
begin
//if (aDatei=170) then begin
//  vA # 'REP KEY170';//+aint("Rso.R.Trägernummer2");
//  vA # vA + '   MIN '   +cnvat(Rso.R.MinZeit.Start)+'-' +cnvat(Rso.R.MinZeit.Ende);
//  vA # vA + '   MAX '   +cnvat(Rso.R.MaxZeit.Start)+'-' +cnvat(Rso.R.MaxZeit.Ende);
  //'REP '+aint("Rso.R.Trägernummer2")+'   PS '+cnvad(Rso.R.Plan.StartDat)+' '+cnvat(Rso.R.Plan.StartZeit)+ ' bis '+cnvad(Rso.R.Plan.EndDat)+' '+cnvat(Rso.R.Plan.EndZeit)+ '   MinStart '+cnvad(Rso.R.MinDat.Start)+' '+cnvat(Rso.R.MinZeit.Start));
//  debug(vA);
//end;
//if (aDatei=702) then debugx('REP KEY702   PS '+cnvad(BAG.P.Plan.StartDat)+' '+cnvat(BAG.P.Plan.StartZeit)+ ' bis '+cnvad(BAG.P.Plan.EndDat)+' '+cnvat(BAG.P.Plan.EndZeit)+ '   MinStart '+cnvad(BAG.P.Fenster.MinDat)+' '+cnvat(BAG.P.Fenster.MinZei));

  // 01.07.2016
  Crit_Prozedur:PauseBeiBedarf();

  if (aOpt=0) then aOpt # _recunlock;
  if (aTyp='') then aTyp # 'AUTO';

  // AFX
  if (aDatei<>923) then
    RunAFX('Rec_RekReplace',AInt(aDatei)+'|'+AInt(aOpt)+'|'+aTyp+'|'+aint(aSel));

  if (aOpt=0) then aOpt # _recunlock;
//if (aDatei=701) and (BAG.IO.ID>=7) then begin
//debug('REPLACE!!!');
//  lib_debug:dump(701);
//end;

  vSelErg # -1;
  if (aSel<>0) then begin
    vBuf # RecBufCreate(aDatei);
    RecBufCopy(aDatei, vBuf);
    RecRead(gFile, 1, _recLock);
    vSelErg # SelRecDelete(aSel, aDatei);
    RecBufCopy(vBuf, aDatei);
    RecbufDestroy(vBuf);
  end;

  Erx # RecReplace(aDatei,aOpt);

  if (Erx=_rOK) and (vSelErg=_rOK) then begin
    SelRecInsert(aSel, aDatei);
  end;

  vRecID # RecInfo(aDatei, _recId);

  if (Erx<>_rOK) then begin
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_SYNC:Update(aDatei, vRecID);
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end
  if (gScopeActual<>0) then begin
    _ScopeRec('RU',aDatei, vRecID);
  end
  else begin
    StampDB();
    Lib_ODBC:Update(aDatei);
  end;

  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aDatei    : int;
  opt aOpt  : int;
  opt aTyp  : alpha;  // MAN=Manuell
) : int
local begin
  Erx     : int;
  vRecId  : int;
end;
begin

  // 01.07.2016
  Crit_Prozedur:PauseBeiBedarf();

  if (aOpt=0) then aOpt # _recunlock;
  if (aTyp='') then aTyp # 'AUTO';

  // AFX
  if (aDatei<>923) then
    RunAFX('Rec_RekDelete',AInt(aDatei)+'|'+AInt(aOpt)+'|'+aTyp);

// 14.01.2019 AH: CustomBuffer hat FALSCHE RECID !!! Darum erst mal laden:
//  vRecID # RecInfo(aDatei, _recId);
  if (aDatei<1000) then begin
    vRecID # RecInfo(aDatei, _recId);
  end
  else begin
    vRecId # HdlInfo(aDatei,_HdlSubType);
    Erx # RecRead(vRecId,1,0);
    if (Erx>_rLocked) then begin
      Erg # Erx;  // TODOERX
      RETURN Erx;
    end;
    vRecID # RecInfo(vRecId, _recId);
  end;


  Erx # RecDelete(aDatei,aOpt);
//  if (aDatei=200) and (erg=_rOK) then begin
//    PtD_Main:Deleted(200);
//  end;
  if (Erx<>_rOK) then begin
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end;
  
  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gScopeActual=0)) then begin
    Lib_SYNC:Delete(aDatei, vRecID);
    Erg # Erx;  // TODOERX
    RETURN Erx;
  end
  if (gScopeActual<>0) then begin
    _ScopeRec('RD',aDatei, vRecID);
  end
  else begin
    StampDB();
    Lib_ODBC:Delete(aDatei, vRecID);
  end;

  // ggf. protokollieren
  if (aDatei=200) or (aTyp='MAN') then PtD_Main:Deleted(aDatei, aTyp);

  case (aDatei) of
    400 : Lib_WorkFlow:RemoveAll(400);
    401 : Lib_WorkFlow:RemoveAll(401);
    500 : Lib_WorkFlow:RemoveAll(500);
    501 : Lib_WorkFlow:RemoveAll(501);
  end
 
  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  DeleteAll
//
//========================================================================
sub DeleteAll(aDatei : int);
begin

  RecDeleteAll(aDatei);

  // SYNC?
  if (cPtdSync) and ((cPtdDirekt) or (gSCopeActual=0)) then begin
    Lib_SYNC:DeleteAll(aDatei);
    RETURN;
  end
  if (gScopeActual<>0) then begin
    _ScopeRec('CLR',aDatei, 0);
  end
  else begin
    StampDB();
    Lib_ODBC:DeleteAll(aDatei);
  end;

end;


//========================================================================
//  LinkBuf
//
//========================================================================
sub LinkBuf(
  var aBufD : int;
  aBufS     : int;
  aLink     : int;
  aMode     : int) : int;
local begin
  erx       : int;
  vDateiS   : int;
end;
begin
//debug(aint(abufD)+' '+aint(aBufS)+' '+aint(aLink));
  if (aBufD=0) then begin
    if (aBufS>0) and (aBufS<5000) then vDateiS # aBufS
    else vDateiS # HdlInfo(aBufS,_HdlSubType);
    // neuen Buffer erzeugen:
    aBufD # RecBufCreate( LinkInfo(vDateiS, aLink, _LinkDestFileNumber) );
  end;

  if (aMode=0) then aMode # _recFirst;
  Erx # RecLink(aBufD, aBufS, aLink, aMode);
  if ((aMode=_RecFirst) or (aMode=_RecLast)) and (Erx>_rLocked) then RecBufClear(aBufD);

  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  LinkConst
//
//========================================================================
sub LinkConst(
  aBufD     : int;
  aBufS     : int;
  aLink     : int;
  aMode     : int) : int;
local begin
  Erx : int;
end;
begin
  if (aMode=0) then aMode # _recFirst;
//debugx(aint(abufd)+' '+aint(aBufS)+' '+aint(aLink));
  Erx # RecLink(aBufD, aBufS, aLink, aMode);
  if ((aMode=_RecFirst) or (aMode=_RecLast)) and (Erx>_rLocked) then RecBufClear(aBufD);

  Erg # Erx;  // TODOERX
  RETURN Erx;
end;


//========================================================================
//  BufKill
//
//========================================================================
SUB BufKill(var aBuf : int);
begin
  if (aBuf=0) then RETURN;
  if (aBuf>0) and (aBuf<5000) then RETURN;
  RecBufDestroy(aBuf);
  aBuf # 0;
end;


//========================================================================
//  RekTransOn
//
//========================================================================
sub RekTransOn();
begin

  Inc(TransCount);
  
  TransActive # true;
  if (gTransList=0) then gTransList # CteOpen(_CteList);

  // SCOPE
  _NewScope();

  DtaBegin();
/**
  if (TransActive=false) then begin
    DtaBegin();
    TransActive # true;
    end
  else begin
    Msg(001100,'',0,0,0);
  end;
**/

end;


//========================================================================
//  RekTransOff
//
//========================================================================
sub RekTransOff();
local begin
  vI  : int;
end;
begin

  if (TransCount=0) then begin
    if (gUserGroup <> 'SOA_SERVER') AND (gUserGroup <> 'JOB-SERVER') then
      Msg(001101,'',0,0,0);
    RETURN;
  end;

  vI # TransCount;
  if (gBluemode) then vI # vI + 1;
  if (vI<>DbaInfo(_DbaDtaLevel)) then begin
    // 28.10.2021 AH : DURCH DEADLOCKS KOMMT DAS !!!
    //  Dann "weiß" unser Counter nix davon, dass alles abgebrochen wurde!
    //  Deadlocks brechen aber ALLE Transaktionen ab, unser Counter muss also NULL sein
    //  dazu dann natürlich alle gemerkten Satzoperatioenn killen !
    
    if (DbaInfo(_DbaDtaLevel)>0) then begin   // doch eine C16-Transaktion da???
      if (gUserGroup <> 'SOA_SERVER') AND (gUserGroup <> 'JOB-SERVER') then
        Msg(99,'!!! TRANSAKTIONS-LEVEL-FEHLER !!!',0,0,0);
      RETURN;
    end;
    Transcount # 0;
    TransActive # false;
    LIB_Sync:TL_Reset();
    RETURN;
  end;


  // SCOPE
  if (gScopeList<>0) and (gScopeActual<>0) then begin
    // closing FIRST Scope? (no parent)
    if (gScopeActual->spid=0) then begin
      _CommitAllScopes();
    end
    else begin
//      Erx # gScopeActual->spid;
      gScopeActual # gScopeActual->spid;
//debug('back to: '+gScopeActual->spname+' ['+aint(Erx)+']');
//debug('close to '+gScopeActual->spname);
    end;
  end;

  Dec(TransCount);
  if (TransCount=0) then TransActive # false;
  DtaCommit();

  Lib_SYNC:TL_Commit();

  if (cPtdSync=false) then begin
    if (TransActive=false) and (gBlueMode=false) then
      Lib_ODBC:TransferStamp();
  end;

end;


//========================================================================
//  RekTransBrk
//
//========================================================================
sub RekTransBrk();
local begin
  vScope  : int;
end;
begin

  if (TransCount=0) then begin
    Msg(001102,'',0,0,0);
    RETURN;
  end;

  Dec(TransCount);
  if (TransCount=0) then TransActive # false;
  DtaRollback(false);

  Lib_SYNC:TL_Rollback();

  // SCOPE
  if (gScopeList<>0) and (gScopeActual<>0) then begin
//debug('rollback '+gScopeActual->spname);
    // kill all later scopes:
    vScope # CteRead(gScopeList, _CteNext, gScopeActual);
    WHILE (vScope<>0) do begin
//debug('rollback inner '+vScope->spname);
      _DelScope(vScope);
      vScope # CteRead(gScopeList, _CteNext, gScopeActual);
    END;

    vScope # gScopeActual->spid;

    // kill actual scope
    _DelScope(gScopeActual);

    gScopeActual # vScope;
//debug('back to last: '+gScopeActual->spname);
  end;

end;


//========================================================================
//  Save
//
//========================================================================
sub _RekSave(aDatei : int) : int
local begin
  vHdl : int;
end;
begin
  vHdl # RecBufcreate(aDatei);
  RecBufCopy(aDatei,vHdl);
  RETURN vHdl;
end;


//========================================================================
//  Restore
//
//========================================================================
sub _RekRestore(aHdl : int);
local begin
  vDatei : int;
end;
begin
  vDatei # HdlInfo(aHdl,_HdlSubType);
  RecBufCopy(aHdl, vDatei);
  RecBufDestroy(aHdl);
  aHdl # 0;
  RETURN;
end;


//========================================================================
//  ClearFile
//
//========================================================================
sub ClearFile(
  aFile     : int;
  opt aType : alpha;
)
local begin
  vRecFlag : int;
  vTextHdl : int;
end;
begin

// TexteLöschen

  If (aType='TEXT') then begin
    vRecFlag # _RecFirst;
    WHILE (RecRead(aFile,1,vRecFlag) <> _rNorec) DO BEGIN
      Case aFile of

        100 : begin
          TxtDelete('~100.'+ CnvAI(Adr.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
        end;

        105 : begin
          TxtDelete('~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4),0);        // 21.07.2015 Länge 7/4
          TxtDelete('~105.'+CnvAI(Adr.V.AdressNr,_FmtNumLeadZero | _FmtNumNoGroup,0,7)+'.'+CnvAI(Adr.V.lfdNr,_FmtNumLeadZero | _FmtNumNoGroup,0,4)+'.01',0);  // 21.07.2015 Länge 7/4
        end;

        250 : begin
          TxtDelete('~250.EK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
          TxtDelete('~250.VK.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
          TxtDelete('~250.PRD.'+CnvAI(Art.ID,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
        end;

        400 : begin
          TxtDelete('~401.'+CnvAI(Auf.nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.K',0);
          TxtDelete('~401.'+CnvAI(Auf.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.F',0);
        end;
        401 : begin
          TxtDelete('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNoGroup,0,3),0);
          TxtDelete('~401.'+CnvAI(Auf.P.Nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.'+CnvAI(Auf.P.Position,_FmtNumLeadZero| _FmtNumNoGroup,0,3)+'.01',0);
        end;

        500 : begin
          TxtDelete('~501.'+CnvAI(Ein.nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.K',0);
          TxtDelete('~501.'+CnvAI(Ein.Nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.F',0);
        end;
        501 : begin
          TxtDelete('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero| _FmtNumNoGroup,0,3),0);
          TxtDelete('~501.'+CnvAI(Ein.P.Nummer,_FmtNumLeadZero| _FmtNumNoGroup,0,8)+'.'+CnvAI(Ein.P.Position,_FmtNumLeadZero| _FmtNumNoGroup,0,3)+'.01',0);
        end;

        837 : begin
          TxtDelete('~837.'+CnvAI(Txt.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8),0);
        end;

        982 : begin
          TxtDelete('~982.'+CnvAI(TeM.B.Nummer,_FmtNumLeadZero | _FmtNumNoGroup,0,8)+'.'+CnvAI(TeM.B.Berichtsnr,_FmtNumLeadZero | _FmtNumNoGroup,0,3),0);
        end;

        915 : TxtDelete(CnvAI(Dok.Nummer),0);

      End;
      vRecFlag # _RecNext;
    END;
  End;

  DeleteAll(aFile);  // zur sicherheit erstmal nicht löschen ;)

end;



//========================================================================
// ConvertSingleRecIDInt
//========================================================================
// Konvertiert eine RecID 5.7, die in einem int-Wert abgelegt ist nach 5.8
sub ConvertSingleRecIDInt
(
  aRecID                : int;   // Datensatz-ID (Version 5.7)
  aTarTblIsSequential   : logic; // Zieldatei (auf die die RecIDs verweisen)
                                 // hat "sequentielles Einfügen" aktiviert?
) : int;                           // Datensatz-ID (Version 5.8)
begin
  if (aTarTblIsSequential) then begin
    if (aRecID & 0x80 != 0) then
      ErrSet(_ErrValueOverflow);
    else
      RETURN (
          (aRecID & 0xFF000000) >> 24 & 0xFF |
          (aRecID & 0x00FF0000) >> 8         |
          (aRecID & 0x0000FF00) << 8         |
          (aRecID & 0x000000FF) << 24
      );
  end
  else begin
    if (aRecID > 0) then
      ErrSet(_ErrValueOverflow);
    else
      RETURN -aRecID;
  end
end;


//========================================================================
// Call Lib_Rec:Upgrade57to58
//========================================================================
sub Upgrade57to58()
local begin
  erx   : int;
  vNeu  : int;
  vPrg  : int;
  vTree : int;
  vItem : int;
  vBuf  : int;
end;
begin

  vPrg  # Lib_Progress:Init('Konvertiere Customfelder',RecInfo(931,_RecCount),true);


  vTree # CteOpen(_cteTree);

  Erx # RecRead(931,1,_recFirst);
  WHILE (erx<=_rLocked) do begin

    // wurde dieser Satz schon konvertiert?
    vItem # CteRead(vTree, _CteFirst | _CteSearch,0, aint( RecInfo(931, _recID)));
    if (vItem<>0) then begin
      Erx # RecRead(931,1,_recNext);
      CYCLE;
    end;

    // Satz als konvertiert merken...
    vTree->CteInsertItem(aint( RecInfo(931, _recID)), RecInfo(931,_recID), '');

    vPrg->Lib_Progress:Step();

    vBuf # RekSave(931);

    vNeu # ConvertSingleRecIDint(Cus.RecId, TRUE);   // SEQUENTIELL
    RecRead(931,1,_recLock);
    Cus.RecId # vNeu;
    RecReplace(931,_RecUnlock);

    RekRestore(vBuf);
    Erx # RecRead(931,1,0);
    Erx # RecRead(931,1,0);
  END;


  CteClear(vTree, y);
  CteClose(vTree);

  vPrg->Lib_Progress:Term();

end;


/*========================================================================
2023-02-09  AH
========================================================================*/
sub LoopDataAndReplaceAlpha(
  aZieldatei                : int;
  aSuchFeld                 : alpha;
  aSuchWert                 : alpha;
  aFeld                     : alpha;
  aNeuerInhalt              : alpha;
  opt aProgress             : int;
  opt aTitel                : alpha;
) : logic;
local begin
  Erx : int;
  vI        : int;
  vBuf      : int;
  vAnz      : int;
  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
  vHdl      : int;
end;
begin

  if (aProgress<>0) and (aTitel<>'') then begin
    vHdl  # Winsearch(aProgress,'Label1');
    vHdl->wpcaption # aTitel;
  end;


  Lib_Sel:QAlpha(var vQ, '"'+aSuchfeld+'"',  '=', aSuchWert);

  vSel # SelCreate(aZielDatei, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  if  (vSelname='') then RETURN false
  
  if (aProgress<>0) then Lib_Progress:SetMax(aProgress, RecInfo(aZielDatei, _recCount, vSel));

  FOR Erx # RecRead(aZielDatei ,vSel, _recFirst | _recLock)
  LOOP Erx # RecRead(aZielDatei, vSel, _recNext | _recLock)
  WHILE (Erx <= _rLocked) DO BEGIN
    if (aProgress<>0) then aProgress->Lib_Progress:Step()
    FldDefByName(aFeld, aNeuerInhalt);
    Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
    if(Erx <> _rOK) then
      RETURN false; // konnte geaenderten Datensatz nicht speichern
    inc(vAnz);
  END;
  if (Erx=_rDeadLock) then RETURN false;
  SelClose(vSel);
  Erx # SelDelete(aZielDatei, vSelName);
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


/*========================================================================
2023-02-23  AH
========================================================================*/
sub LoopDataAndReplaceInt(
  aZieldatei                : int;
  aSuchFeld                 : alpha;
  aSuchWert                 : word;
  aFeld                     : alpha;
  aNeuerInhalt              : word;
  opt aProgress             : int;
  opt aTitel                : alpha;
) : logic;
local begin
  Erx : int;
  vI        : int;
  vBuf      : int;
  vAnz      : int;
  vSel      : int;
  vQ        : alpha(4000);
  vSelName  : alpha;
  vHdl      : int;
end;
begin

  if (aProgress<>0) and (aTitel<>'') then begin
    vHdl  # Winsearch(aProgress,'Label1');
    vHdl->wpcaption # aTitel;
  end;

  Lib_Sel:QInt(var vQ, '"'+aSuchfeld+'"',  '=', aSuchWert);

  vSel # SelCreate(aZielDatei, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  if  (vSelname='') then RETURN false
  
  if (aProgress<>0) then Lib_Progress:SetMax(aProgress, RecInfo(aZielDatei, _recCount, vSel));

  FOR Erx # RecRead(aZielDatei ,vSel, _recFirst | _recLock)
  LOOP Erx # RecRead(aZielDatei, vSel, _recNext | _recLock)
  WHILE (Erx <= _rLocked) DO BEGIN
    if (aProgress<>0) then aProgress->Lib_Progress:Step()
    FldDefByName(aFeld, aNeuerInhalt);
    Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
    if(Erx <> _rOK) then
      RETURN false; // konnte geaenderten Datensatz nicht speichern
    inc(vAnz);
  END;
  if (Erx=_rDeadLock) then RETURN false;
  SelClose(vSel);
  Erx # SelDelete(aZielDatei, vSelName);
  if (erx<>_rOK) then RETURN false;

  RETURN true;
end;


/*========================================================================
2023-02-23  AH
========================================================================*/
sub LoopDataAndReplaceByQuery(
  aZieldatei                : int;
  aQuery                    : alpha(1000);
  aTargetFeldName           : alpha;
  aSourceFeldName           : alpha;
  opt aProgress             : int;
  opt aTitel                : alpha;
) : logic;
local begin
  Erx : int;
  vI        : int;
  vBuf      : int;
  vAnz      : int;
  vSel      : int;
  vSelName  : alpha;
  vHdl      : int;
  vFldType  : int;
end;
begin

  if (aProgress<>0) and (aTitel<>'') then begin
    vHdl  # Winsearch(aProgress,'Label1');
    vHdl->wpcaption # aTitel;
  end;

  if (Fldinfobyname(aSourceFeldName, _Fldexists)=0) then RETURN false;
  if (Fldinfobyname(aTargetFeldName, _Fldexists)=0) then RETURN false;
  vFldType # Fldinfobyname(aSourceFeldName, _FldType);
  if (Fldinfobyname(aTargetFeldName, _FldType)<>vFldType) then RETURN false;

  vSel # SelCreate(aZielDatei, 1);
  Erx # vSel->SelDefQuery('', aQuery);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);
  if  (vSelname='') then RETURN false
  
  if (aProgress<>0) then Lib_Progress:SetMax(aProgress, RecInfo(aZielDatei, _recCount, vSel));

  FOR Erx # RecRead(aZielDatei ,vSel, _recFirst | _recLock)
  LOOP Erx # RecRead(aZielDatei, vSel, _recNext | _recLock)
  WHILE (Erx <= _rLocked) DO BEGIN
    if (aProgress<>0) then aProgress->Lib_Progress:Step()
    
    case (vFldType) of
      _TypeAlpha    : FldDefByName(aTargetFeldName, FldAlphaByName(aSourceFeldName));
      _TypeBigInt   : FldDefByName(aTargetFeldName, FldBigIntbyName(aSourceFeldName));
      _TypeDate     : FldDefByName(aTargetFeldName, FldDateByName(aSourceFeldName));
      _TypeDecimal  : FldDefByName(aTargetFeldName, FldDecimalByName(aSourceFeldName));
      _TypeFloat    : FldDefByName(aTargetFeldName, FldFloatByName(aSourceFeldName));
      _TypeInt      : FldDefByName(aTargetFeldName, FldIntByName(aSourceFeldName));
      _TypeLogic    : FldDefByName(aTargetFeldName, FldLogicbyName(aSourceFeldName));
      _TypeTime     : FldDefByName(aTargetFeldName, FldTimeByName(aSourceFeldName));
      _TypeWord     : FldDefByName(aTargetFeldName, FldWordByName(aSourceFeldName));
    end;

    Erx # RekReplace(aZieldatei, _recUnlock, 'AUTO');
    if(Erx <> _rOK) then BREAK;
    inc(vAnz);
  END;

  SelClose(vSel);
  if (Erx=_rDeadLock) then RETURN false;
  Erx # SelDelete(aZielDatei, vSelName);

  RETURN true;
end;


//========================================================================
//========================================================================
//========================================================================

//========================================================================
//========================================================================
//========================================================================
