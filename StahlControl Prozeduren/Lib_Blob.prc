@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Blob
//                  OHNE E_R_G
//  Info
//
//
//  09.04.2014  AH  Erstellung der Prozedur
//  05.05.2014  AH  "Execute" startet asynchron
//  14.05.2014  ST  Sortierung für cDL hinzugefügt Projekt 1499/2
//  04.03.2015  ST  "sub CutFilename(...)" hinzugefügt
//  27.07.2021  AH  ERX
//  2022-07-07  AH  ErrorPattern2022
//  2022-07-15  AH  Fix
//
//  Subprozeduren
//  sub FindTreePath
//  sub SetDLLine
//  sub RechtDir
//  sub Recht
//  sub Exists
//  sub ExistsDir
//  sub BlobToMem
//  sub DeleteRechte
//  sub Delete
//  sub DeleteDir
//  sub Rename
//  sub RenameDir
//  sub CreateDir

//  sub FillDL
//  sub FillOrderdDL

//  sub ShowBinDir
//  sub Import
//  sub Copy
//  sub Export
//  sub CopyRechteID
//  sub CopyRechteDir
//  sub CopyDir
//  Sub Execute
//
//
//  Sub InitBlobCa1
//  sub ConvertFilename
//========================================================================
@I:Def_Global
@I:Def_Rights

define begin
  // Konstanten fuer die Fehlerbehandlung
  errAktionDirOpen   : 100
  errAktionDirCreate : 101
  errAktionDirDelete : 102
  errAktionObjOpen   : 103
  errAktionObjCreate : 104
  errAktionObjImport : 105
  errAktionObjExport : 106
  errAktionObjDelete : 107
  errAktionRename    : 108

  // eigene definierte Fehlercodes
  errObjExists        : -1600
  errObjNotFound      : -1601
  errIllegalFilename  : -1602
end;

declare CutFilename(aFilename : alpha(4096)) : alpha

//========================================================================
// FindTreePath
//  Ermitteln des Pfades zu einem Objekt mit Hilfe der Treeknoten
//========================================================================
sub FindTreePath(
  aNode : int;
) : alpha;
local begin
  vNodeParent     : int;
  vPath           : alpha(4096);
end;
begin
  vNodeParent # WinInfo(aNode,_WinParent);
  if (vNodeParent != 0 AND
      WinInfo(vNodeParent,_WinType)=_WinTypeTreeNode AND
      vNodeParent->wpName != 'Root') then begin
    vPath # FindTreePath(vNodeParent)
  end;
  vPath # vPath+'\'+aNode->wpCaption;

  RETURN(vPath)
end;


//========================================================================
// SetDLLine
//  Anzeige der Eigenschaften eines binaeren Verzeichnis oder Objektes
//========================================================================
sub SetDLLine(
  aDlsHdl    : int;
  aObjHdl    : int;
  aLine      : int;
)
local begin
  vCaltime  : caltime;
  vTime     : time;
  vDate     : date;
end;
begin
  // Eigenschaften des Objektes in die Spalten setzen

  WinLstCellSet(aDlsHdl, aObjHdl->spname, 1,aLine);

  WinLstCellSet(aDlsHdl, Lib_Berechnungen:BytesToAlpha(aObjHdl->spSizeOrg), 2,aLine);

  vCaltime # aObjHdl->spTimeExternal
  try begin
    ErrTryIgnore(_ErrValueRange);
    vDate # vCaltime->vpDate;
    vTime # vCaltime->vpTime;
  end;
  WinLstCellSet(aDlsHdl,CNVAD(vDate)+' '+CNVAT(vTime,_FmtTimeSeconds),3,aLine)

  WinLstCellSet(aDlsHdl,aObjHdl->spFullName,4,aLine)
  WinLstCellSet(aDlsHdl,aObjHdl->spID,5,aLine)
end;


//========================================================================
//  _Recht
//
//========================================================================
sub _Recht(
  aBinObj : int;
  aRecht  : alpha;
  aDBA    : int;
) : logic;
local begin
  Erx     : int;
  vExist  : logic;
  vPar    : alpha(4000);
  vDir    : int;
  vID     : int;
  vOK     : logic;
end;
begin

  vID # aBinObj->spID;

  // Userrecht?
  RecBufClear(917);
  Blb.R.ID    # vID;
  Blb.R.Typ   # 'U';
  Blb.R.Name  # gUsername;
  Erx # RecRead(917,1,0);
  if (Erx<=_rLocked) then begin
    // V iew
    // N ew
    // D el
    // E dit
    if (aRecht='N') then RETURN Blb.R.NewYN;
    if (aRecht='D') then RETURN Blb.R.DelYN;
    if (aRecht='E') then RETURN Blb.R.EditYN;
    RETURN true;
  end;

  // Rechte für ANDERE vorhanden?
  RecBufClear(917);
  Blb.R.ID    # vID;
  Erx # RecRead(917,1,0);
  if (Erx=_rNokey) then begin
    if (Blb.R.ID=vID) then vExist # y;
  end;


  // Gruppenrecht?
  // Gruppen loopen
  FOR Erx # RecLink(802, 800, 1, _recfirst)
  LOOP Erx # RecLink(802, 800, 1, _recNext)
  WHILE (erx<=_rLocked) do begin
    RecBufClear(917);
    Blb.R.ID    # vID;
    Blb.R.Typ   # 'G';
    Blb.R.Name  # "Usr.U<>G.Gruppe";
    Erx # RecRead(917,1,0);
    if (erx<=_rLocked) then begin
      if (aRecht='N') and (Blb.R.NewYN) then RETURN true;
      if (aRecht='D') and (Blb.R.DelYN) then RETURN true;
      if (aRecht='E') and (Blb.R.EditYN) then RETURN true;
      if (aRecht='V') then RETURN true;
    end;
  END;


  // gibt ein FREMDES Recht? -> Dann hab ich wohl keins!!!
  if (vExist) then RETURN false;


  // höher gucken...
  vPar # FsiSplitname(aBinObj->spFullname, _FsiNamePP);
//debug('über '+aBinObj->spFullname+'   '+vPar);
  if (StrLen(vPar)>1) then begin
    vDir # BinDirOpen(0, vPar, aDBA);
    if (vDir<=0) then RETURN false;    // nix drüber was veribetet -> ENDE
    vID  # vDir->spID;
    vOK # _Recht(vDir, aRecht, aDBA);
    BinClose(vDir);
    RETURN vOK;
  end;

  RETURN true;    // nix drüber was veribetet -> ENDE
end;


//========================================================================
//  RechtDir
//
//========================================================================
sub RechtDir(
  aName   : alpha(4000);
  aRecht  : alpha;
  aDBA    : int;
) : logic;
local begin
  vHdl  : int;
  vOK   : logic;
end;
begin
  if (aName='') then RETURN false;
  if (Rechte[Rgt_Admin]) then RETURN true;

  vHdl # BinDirOpen(0, aName, aDBA);
  if (vHdl<=0) then RETURN false;
  vOK # _Recht(vHdl, aRecht, aDBA);
  BinClose(vHdl);

  RETURN vOK;
end;


//========================================================================
//  Recht
//
//========================================================================
sub Recht(
  aName   : alpha(4000);
  aRecht  : alpha;
  aDBA    : int;
) : logic;
local begin
  vHdl  : int;
  vOK   : logic;
end;
begin
  if (aName='') then RETURN false;
  if (Rechte[Rgt_Admin]) then RETURN true;

  vHdl # BinOpen(0, aName, aDBA);
  if (vHdl<=0) then begin
    // vielleicht Directory?
    vHdl # BinOpen(0, aName, aDBA | _BinDirectory);
    if (vHdl<=0) then RETURN false;
  end;

  vOK # _Recht(vHdl, aRecht, aDBA);
  BinClose(vHdl);

  RETURN vOK;
end;


//========================================================================
//  _NewNodeDir
//
//========================================================================
sub _NewNodeDir(
  aTV       : int;
  aDirName  : alpha;
  aFullName : alpha(4000);
  aID       : int;
  ) : int;
local begin
  vNode : int;
end;
begin
  vNode # WinTreeNodeAdd(aTV, aDirName, aDirName);
  vNode->wpHelpTip      # aFullname;
  vNode->wpID           # aID;
  RETURN vNode;
end;


//========================================================================
//  Exists
//
//========================================================================
sub Exists(
  var aOut    : logic;
  aBinDirPath : alpha(4096);
  aExternFull : alpha(4096);
  aDBA        : int) : int;
local begin
  Erx         : int;
  vDirHdl     : int;
  vFilename   : alpha(4000);
  vHdl        : int;
end;
begin
  aOut # false;
//debug('existscheck...'+aExternfull+','+aBinDirPath);
  if (aExternFull = '') then RETURN _rNorec;
  vFileName # FsiSplitName(aExternFull,_FsiNameNE);
  if (vfilename = '') then RETURN _rNoRec;

  vDirHdl # BinDirOpen(0,aBinDirPath, aDBA);
  if (vDirHdl < 0) or (vDirHdl=_rDeadLock) then RETURN vDirHdl;

  // binaeres Objekt erzeugen
  // Zuvor Pruefen ob ein Objekte mit diesem Namen schon vorhanden ist
//debug('check '+aBinDirPath + ' + '+vFilename);
  vHdl # BinOpen(vDirHdl, vFileName, aDBA);
  if (vHdl=_rDeadLock) then begin
    BinClose(vDirHdl);
    RETURN vHdl;
  end;
  
  if (vHdl<0) then begin
    RETURN _rOK;
  end;

  BinClose(vHdl);
  BinClose(vDirHdl);

  aOut # true;
  RETURN _rOK;
//  if (vHdl > 0) then RETURN 1;
//  RETURN 0;
end;


//========================================================================
//  ExistsDir
//
//========================================================================
sub ExistsDir(
  aBinDirPath : alpha(4096);
  aDBA        : int) : int;
local begin
  vDirHdl     : int;
end;
begin

  if (aBinDirPath = '') then RETURN 1;

  vDirHdl # BinDirOpen(0,aBinDirPath, aDBA);
  if (vDirHdl <= 0) then RETURN 0;
  BinClose(vDirHdl);

  RETURN 1;
end;


//========================================================================
//  BlobToMem
//
//========================================================================
sub BlobToMem(
  aInternFull : alpha(4000);
  aDBA        : int;
  var aMem    : int;
) : int;
local begin
  Erx         : int;
  vBlob       : int;
end;
begin

  vBlob # BinOpen(0, aInternFull, _BinLock | aDBA);
  if (vBlob<0) or (vBlob=_rDeadlock) then RETURN vBlob;
  if (vBlob->spSizeOrg=0) then begin
    vBlob->BinClose();
    RETURN _rNorec;
  end;
  aMem # MemAllocate(vBlob->spSizeOrg);
  vBlob->BinReadMem(aMem);
  vBlob->BinClose();

  RETURN _rOK;
end;


//========================================================================
//  DeleteRechte
//
//========================================================================
sub DeleteRechte(
  aID : int) : int
local begin
  Erx : int;
end;
begin
  // Rechte loopen...
  GV.Int.20 # aID;
  WHILE (Reclink(917, 999, 9, _recFirst)<=_rLocked) do begin
    Erx # RekDelete(917,_recunlock,'AUTO');
    if (Erx<>_rOK) then RETURN Erx;
  END;

  RETURN _rOK;
end;


//========================================================================
//  Delete
//
//========================================================================
sub Delete(
  aFilename   : alpha(4000);
  aBinDirPath : alpha(4000);
  aDBA        : int;
  aDlsHdl     : int;
) : int;
local begin
  Erx   : int;
  vErr  : int;
  vA    : alphA(4000);
  vI    : int;
  vID   : int;
end;
begin

  vErr # Binopen(0, aBinDirPath+'\'+aFilename, aDBA);
  if (vErr<=0) or (vErr=_rDeadLock) then RETURN vErr

  vID # Verr->spID;
  Binclose(vErr);

  vErr # BinDelete(0,aBinDirPath+'\'+aFilename, aDBA);
  if (vErr<>_ErrOK) then RETURN vErr;

  Erx # DeleteRechte(vID);
  if (Erx<>_rOK) then RETURN Erx;

  if (aDlsHdl<>0) then begin
    FOR vI # aDlsHdl->WinLstDatLineInfo(_WinLstDatInfoCount)
    LOOP dec(vI)
    WHILE (vI>0) do begin
      WinLstCellGet(aDlsHdl, vA, 1, vI);
      if (vA=aFilename) then begin
        WinLstDatLineRemove(aDlsHdl, vI);
        BREAK;
      end;
    END;
  end;

  RETURN _rOK;
end;


//========================================================================
//  DeleteDir
//
//========================================================================
sub DeleteDir(
  aDirFullName  : alpha(4000);
  aDBA          : int;
  aTVHdl        : int;
  aNodeHdl      : int;
) : int;
local begin
  Erx   : int;
  vErr  : int;
  vPar  : int;
  vID   : int;
end;
begin

  vErr # BinDiropen(0, aDirFullName, aDBA);
  if (vErr<0) or (vErr=_rDeadLock) then RETURN vErr
  vID # vErr->spID;
  Binclose(vErr);

  vErr # BinDirDelete(0, aDirFullname, aDBA);
  if (vErr<0) or (vErr=_rDeadLock) then RETURN vErr;

  Erx # DeleteRechte(vID);
  if (Erx<>_rOK) then RETURN Erx;

  if (aNodeHdl<>0) then begin
    // vorherigen Knoten ermitteln
    vPAr # WinInfo(aNodeHdl,_WinPrev);
    WinTreeNodeRemove(aNodeHdl);
    aTVHdl->wpCurrentInt # vPar;
  end;

  RETURN _rOK;
end;


//========================================================================
//  Rename
//
//========================================================================
sub Rename(
  aPath       : alpha(4000);
  aName       : alpha;
  aDBA        : int;
  aDlsHdl     : int;
  aLine       : int;
) : int;
local begin
  vErr  : int;
  vHdl  : int;
end;
begin

  vHdl # BinOpen(0,aPath,_BinLock | aDBA);
  if (vHdl<0) or (vHdl=_rDeadLock) then RETURN vHdl;

  vErr # BinRename(vHdl, aName);
  if (vErr<>_ErrOk) then RETURN vErr;

  if (aDlsHdl<>0) then begin
      // Fuellen der Datalist mit dem Objekt
    SetDLLine(aDlsHdl, vHdl, aLine)
    WinUpdate(aDlsHdl, _WinUpdOn);
  end;

  BinClose(vHdl);

  RETURN _rOK;
end;


//========================================================================
//  RenameDir
//
//========================================================================
sub RenameDir(
  aBinDirPath : alpha(4000);
  aName       : alpha;
  aDBA        : int;
  aNodeHdl    : int;
) : int;
local begin
  vErr  : int;
  vHdl  : int;
end;
begin

  vHdl # BinDirOpen(0,aBinDirPath,_BinLock | aDBA);
  if (vHdl<0) or (vHdl=_rDeadLock) then RETURN vHdl;

  vErr # BinRename(vHdl, aName);
  if (vErr<>_ErrOk) then RETURN vErr;

  if (aNodeHdl<>0) then begin
    aNodeHdl->wpName    # aName;
    aNodeHdl->wpCaption # aName;
    aNodeHdl->wpHelptIp # vHdl->spFullname;
    WinUpdate(aNodeHdl, _WinUpdOn);
  end;

  BinClose(vHdl);

  RETURN _rOK;
end;


//========================================================================
//  CreateDir
//
//========================================================================
sub CreateDir(
  aBinDirPath : alpha(4000);
  aName       : alpha;
  aDBA        : int;
  aWinHdl     : int;
) : int;
local begin
  vErr  : int;
  vHdl  : int;
  vNode : int;
end;
begin

  vHdl # BinDirOpen(0, aBinDirPath+'\'+aName, _BinCreate|aDBA);
  if (vHdl<0) or (vHdl=_rDeadLock) then RETURN vHdl;

  if (aWinHdl<>0) then begin
    vNode # _NewNodeDir(aWinHdl, aName, vHdl->spFullname, vHdl->spID);
    if (aWinHdl<>0) then
      aWinHdl->wpNodeExpanded # true;
    WinUpdate(vNode, _WinUpdOn);
  end;

  BinClose(vHdl);

  RETURN _rOK;
end;


//========================================================================
//  FillDL
//
//========================================================================
sub FillDL(
  var aCount        : int;
  aBinDirPath       : alpha(4000);
  aDlsHdl           : int;
  aDBA              : int;
) : int;
local begin
  Erx         : int;
  vBinDirHdl  : int;
  vObjName    : alpha;
  vObjHdl     : int;
  vCntObj     : int;
  vLine       : int;
end;
begin

  aCount # 0;
  vBinDirHdl # BinDirOpen(0, aBinDirPath, aDBA)
  if (vBinDirHdl<0) or (vBinDirHdl=_rDeadLock) then RETURN vBinDirHdl;

  vCntObj # 0;
  aDlsHdl->WinUpdate(_WinUpdOff)
  WinLstDatLineRemove(aDlsHdl,_WinLstDatLineAll);

  // alle Objekte zu diesem Verzeichnis ermitteln
  vObjName # BinDirRead(vBinDirHdl,_BinFirst|aDBA)
  WHILE (vObjName != '') and (Erx=0) do begin
    vObjHdl # BinOpen(vBinDirHdl, vObjName, aDBA);
    if (vObjHdl<0) or (vObjHdl=_rDeadLock) then begin
      Erx # vObjHdl;
      BREAK;
    end;
 
    vLine # WinLstDatLineAdd(aDlsHdl, vObjName, _WinLstDatLineLast);
//2022-07-07  AH    if (vObjHdl > 0) then begin
      // Fuellen der Datalist mit dem Objekt
    SetDLLine(aDlsHdl, vObjHdl, vLine)
    inc(vCntObj)
//    end;

    vObjName # BinDirRead(vBinDirHdl,_BinNext|aDBA);
    BinClose(vObjHdl);
  END;

  aDlsHdl->WinUpdate(_WinUpdOn)

  BinClose(vBinDirHdl)

  aCount # vCntObj;
  RETURN Erx;
end;


//========================================================================
//  sub FillOrderdDL(...)
//    Füllt die sortierte DL für die Dateien
//========================================================================
sub FillOrderdDL(
  var aCount        : int;
  aBinDirPath       : alpha(4000);
  aDlsHdl           : int;
  aDBA              : int;
  aSortName         : alpha;
  aDirection        : int;  //  wpClmSortImage  = _WinClmSortImageDown, _WinClmSortImageUp
) : int;
local begin
  Erx         : int;
  vBinDirHdl  : int;
  vObjName    : alpha;
  vObjHdl     : int;
  vCntObj     : int;
  vLine       : int;

  vCteSortList : int;
  vCteSortItem : int;
  vSort        : alpha(250);
  vCaltime     : caltime;
  vTime        : time;
  vDate        : date;

  vReadStart :  int;
  vReadNext :  int;
end;
begin

  aCount # 0;
  vBinDirHdl # BinDirOpen(0, aBinDirPath, aDBA)
  if (vBinDirHdl<0) or (vBinDirHdl=_rDeadLock) then RETURN vBinDirHdl;

  vCntObj # 0;
  aDlsHdl->WinUpdate(_WinUpdOff)
  WinLstDatLineRemove(aDlsHdl,_WinLstDatLineAll);

  vCteSortList # CteOpen(_CteTree);

  // alle Objekte zu diesem Verzeichnis ermitteln
  vObjName # BinDirRead(vBinDirHdl,_BinFirst|aDBA)
  WHILE (vObjName != '') and (Erx=0) do begin
    vObjHdl # BinOpen(vBinDirHdl, vObjName, aDBA);
    if (vObjHdl<0) or (vObjHdl=_rDeadLock) then begin
      Erx # vObjHdl;
      BREAK;
    end;
    
    vSort # '';
    case StrCnv(aSortName,_StrUpper) of
      'CLMGROESSE' : begin
                         vSort # Lib_Strings:IntForSort(vObjHdl->spSizeOrg);
                      end;
      'CLMDATUM' : begin
                        vCaltime # vObjHdl->spTimeExternal
                        try begin
                          ErrTryIgnore(_ErrValueRange);
                          vDate # vCaltime->vpDate;
                          vTime # vCaltime->vpTime;
                        end;
                        vSort # Lib_Strings:Timestamp(vDate, vTime);
                    end;
    end;
    vSort # vSort + ';' + vObjHdl->spname;    // Namen anhhängen um Eindeutigkeit zu gewährleisten
    vCteSortList->Lib_Ramsort:Add(vSort,vObjHdl,vObjName);

    vObjName # BinDirRead(vBinDirHdl,_BinNext|aDBA);
    BinClose(vObjHdl);
  END;

  if (Erx=0) then begin
    // ---------------------------------------------
    // Sortiert in DL eintragen

    // Richtung beachten
    if (aDirection = _WinClmSortImageDown) then begin
      vReadStart # _cteLast;
      vReadNext  # _CtePrev;
    end
    else begin
      vReadStart # _cteFirst;
      vReadNext  # _CteNext;
    end;

    FOR   vCteSortItem # vCteSortList->CteRead(vReadStart);
    LOOP  vCteSortItem # vCteSortList->CteRead(vReadNext,vCteSortItem);
    WHILE (vCteSortItem != 0) DO BEGIN
      vObjHdl # BinOpen(vBinDirHdl, vCteSortItem->spCustom, aDBA);
      if (vObjHdl<0) or (vObjHdl=_rDeadLock) then begin
        Erx # vObjHdl;
        BREAK;
      end;
      vLine # WinLstDatLineAdd(aDlsHdl, vObjName, _WinLstDatLineLast);
      if (vObjHdl > 0) then begin
        // Fuellen der Datalist mit dem Objekt
        SetDLLine(aDlsHdl, vObjHdl, vLine)
        inc(vCntObj)
      end;

      BinClose(vObjHdl);
    END;
  end;

  vCteSortList->CteClear(true);
  vCteSortList->CteClose();

  aDlsHdl->WinUpdate(_WinUpdOn);

  BinClose(vBinDirHdl)

  aCount # vCntObj;
  RETURN Erx;
end;


//========================================================================
//  ShowBinDir
//
//========================================================================
sub ShowBinDir(
  aWinObj   : int;
  aBinDir   : int;
  aDirName  : alpha;
  aDBA      : int;
) : int
local begin
  Erx           : int;
  vDirHdl       : int;
  vDirName      : alpha;
  vRootHdl      : int;
  vHdl          : int;
  vTreeNodeDir  : int;
end;
begin

  // hier könnte man Root-Knoten anlegen

  // Startverzeichnisname angegeben?
  if (aDirName<>'') then
    aBinDir # BinDirOpen(aBinDir, aDirName, aDBA);
  if (aBinDir<0) or (aBinDir=_rDeadLock) then RETURN aBinDir;
 
  // Alle Verzeichnisse ermitteln
  vDirName # BinDirRead(aBinDir,_BinFirst|_BinDirectory|aDBA);
  WHILE (vDirName != '') do begin
    // Verzeichnis ueber den Namen oeffnen
    vDirHdl # BinDirOpen(aBinDir, vDirName, aDBA);
    if (vDirHdl<0) or (vDirHdl=_rDeadLock) then begin
      Erx # aBinDir;
      BREAK;
    end;

    // komplette Pfad im Helptip des Knotens anzeigen
    if (vDirHdl > 0) then begin

      // Knoten im Tree anlegen
      vTreeNodeDir # _NewNodeDir(aWinObj, vDirName, vDirHdl->spFullname, vDirHdl->spID);

      // Unterverzeichnisse zu diesem Verzeichnis ermitteln
      Erx # ShowBinDir(vTreeNodeDir, vDirHdl, '', aDBA);
      if (Erx<>_rOK) then BREAK;

      vTreeNodeDir->wpNodeExpanded # true;

      // Verzeichnis wieder schliessen
      BinClose(vDirHdl);
    end;

    // naechsten Verzeichnis(Namen) ermitteln
    vDirName # BinDirRead(aBinDir,_BinNext|_BinDirectory|aDBA);
  END;

  if (aDirName<>'') then
    BinClose(aBinDir);

  RETURN Erx;
end;


//========================================================================
// Import
//  Binaeres Objekt importieren
//========================================================================
sub Import(
  aExternFull       : alpha(4096);
  aBinDirPath       : alpha(4096);
  aDBA              : int;
  aDlsHdl           : int;
  aOverwrite        : logic;
  var aBlobID       : int;
) : int;
local begin
  Erx               : int;
  vDirHdl           : int;
  vNewObjHdl        : int;
  vFileName         : alpha(4096);
  vLine             : int;
  vOK               : logic;
end;
begin

  if (aExternFull = '') then RETURN _rNoRec;
  vFileName # FsiSplitName(aExternFull,_FsiNameNE);

  // Existiert schon?
  Erx # Exists(var vOK, aBinDirPath, aExternFull, aDBA);
  if (Erx<>_rOK) then RETURN Erx;
  if (vOK) then begin
//  if (Exists(aBinDirPath, aExternFull, aDBA)>0) then begin
    if (aOverwrite=false) then RETURN errObjExists;
    Erx # Delete(vFilename, aBinDirPath, aDBA, aDlsHdl);
    if (Erx<>_errOK) then RETURN Erx;
  end;

  vDirHdl # BinDirOpen(0,aBinDirPath, aDBA);
  if (vDirHdl<0) or (vDirHdl=_rDeadLock) then RETURN vDirHdl;

  // binaeres Objekt erzeugen
  vFilename # CutFilename(vFilename);

  vNewObjHdl # BinOpen(vDirHdl, vFileName,_BinCreate|_BinLock|aDBA);
  if (vNewObjHdl < 0) or  (vNewObjHdl=_rDeadLock) then begin
    // Ausgangsvereichnis wieder schliessen
    BinClose(vDirHdl);
    RETURN(vNewObjHdl);
  end;

  // und importieren (ohne Verschluesselung)
  Erx # BinImport(vNewObjHdl, aExternFull, 4);
  if (Erx<>_ErrOk) then begin
    BinClose(vNewObjHdl);
    RETURN(Erx)
  end;

  // Eigenschaften des Objektes setzen
  vNewObjHdl->spTypeMime # FsiSplitName(aExternFull,_FsiNameE);

  // Aenderungen der Eigenschaften speichern
  Erx # vNewObjHdl->BinUpdate();
  if (Erx<>_rOK) then begin
    BinClose(vNewObjHdl);
    RETURN(Erx)
  end;

  aBlobID # vNewObjHdl->spID;

  if (aDlsHdl<>0) then begin
    // Zeile hinzufuegen
    vLine # WinLstDatLineAdd(aDlsHdl, vNewObjHdl->spName, _WinLstDatLineLast);
    // Eigenschaften des Objektes in der Liste anzeigen
    SetDLLine(aDlsHdl, vNewObjHdl, vLine);
  end;

  vNewObjHdl->BinClose();

  // Ausgangsvereichnis wieder schliessen
  BinClose(vDirHdl);

  RETURN _rOK;
end;


//========================================================================
// Copy
//  Binaeres Objekt intern kopieren
//========================================================================
sub Copy(
  aSourceFull       : alpha(4096);
  aDestPath         : alpha(4096);
  aDBA              : int;
  aDlsHdl           : int;
  aOverwrite        : logic;
  var aBlobID       : int;
) : int;
local begin
  Erx               : int;
  vOK               : logic;
  vObjHdl1          : int;
  vDirHdl2          : int;
  vObjHdl2          : int;
  vFileName         : alpha(4000);
  vLine             : int;
end;
begin

  if (aSourceFull = '') then RETURN _rNoRec;
  if (aDestPath = '') then RETURN _rNoRec;
  vFileName # FsiSplitName(aSourceFull,_FsiNameNE);

  // Existiert schon?
//  if (Exists(aDestPath, vFilename, aDBA)>0) then begin
  Erx # Exists(var vOK, aDestPath, vFilename, aDBA);
  if (Erx<>_rOK) then RETURN Erx;
  if (vOK) then begin
    if (aOverwrite=false) then RETURN errObjExists;
    Erx # Delete(vFilename, aDestPath, aDBA, aDlsHdl);
    if (erx<>_errOK) then RETURN Erx;
  end;

  vObjHdl1 # BinOpen(0, aSourcefull, aDBA);
  if (vObjHdl1<0) or (vObjHdl1=_rDeadLock) then RETURN vObjHdl1;

  vDirHdl2 # BinDirOpen(0, aDestPath, aDBA);
  if (vDirHdl2<0) or (vDirHdl2=_rDeadLock) then begin
    BinClose(vObjHdl1);
    RETURN vDirHdl2;
  end;

  // binaeres Objekt erzeugen
  vObjHdl2 # BinOpen(vDirHdl2, vFileName, _BinCreate|_BinLock|aDBA);
  if (vObjHdl2<0) or (vObjHdl2=_rDeadLock) then begin
    // Ausgangsvereichnis wieder schliessen
    BinClose(vObjHdl1);
    BinClose(vDirHdl2);
    RETURN vObjHdl2;
  end;

  // und KOPIEREN...
  Erx # BinCopy(vObjHdl1, vObjHdl2);
  if (Erx<>_ErrOk) then begin
    BinClose(vObjHdl1);
    BinClose(vObjHdl2);
    BinClose(vDirHdl2);
    RETURN(Erx)
  end;
  BinClose(vObjHdl1);

  // Eigenschaften des Objektes setzen
  vObjHdl2->spTypeMime # FsiSplitName(aSourceFull,_FsiNameE);
  // Aenderungen der Eigenschaften speichern
  Erx # vObjHdl2->BinUpdate();
  if (Erx=_rOK) then begin
    aBlobID # vObjHdl2->spID;
    if (aDlsHdl<>0) then begin
      // Zeile hinzufuegen
      vLine # WinLstDatLineAdd(aDlsHdl, vObjHdl2->spName, _WinLstDatLineLast);
      // Eigenschaften des Objektes in der Liste anzeigen
      SetDLLine(aDlsHdl, vObjHdl2, vLine);
    end;
  end;
  BinClose(vObjHdl2);

  // Ausgangsvereichnis wieder schliessen
  BinClose(vDirHdl2);

  RETURN Erx;
end;


//========================================================================
// BlobToMem
//  Binaeres Objekt importieren
//========================================================================
sub MemToBlob(
  aMem              : int;
  aFilename         : alpha(4000);
  aBinDirPath       : alpha(4096);
  aDBA              : int;
  aDlsHdl           : int;
  aOverwrite        : logic;
  var aBlobID       : int;
) : int;
local begin
  Erx               : int;
  vOK               : logic;
  vDirHdl           : int;
  vNewObjHdl        : int;
  vLine             : int;
end;
begin

  if (aMem = 0) then RETURN -1;

  // Existiert schon?
//  if (Exists(aBinDirPath, aFilename, aDBA)>0) then begin
  Erx # Exists(var vOK, aBinDirPath, aFilename, aDBA);
  if (Erx<>_rOK) then RETURN Erx;
  if (vOK) then begin
    if (aOverwrite=false) then RETURN errObjExists;
    Erx # Delete(aFilename, aBinDirPath, aDBA, aDlsHdl);
    if (Erx<>_errOK) then RETURN Erx;
  end;

  vDirHdl # BinDirOpen(0,aBinDirPath, aDBA);
  if (vDirHdl<0) or (vDirHdl=_rDeadLock) then RETURN vDirHdl;

  // binaeres Objekt erzeugen
  vNewObjHdl # BinOpen(vDirHdl, aFileName,_BinCreate|_BinLock|aDBA);
  if (vNewObjHdl<0) or (vNewObjHdl=_rDeadLock) then begin
    // Ausgangsvereichnis wieder schliessen
    BinClose(vDirHdl);
    RETURN(vNewObjHdl);
  end;


  // und importieren (ohne Verschluesselung)
  //vErr # BinImport(vNewObjHdl, aExternFull, 4);
  Erx # BinWriteMem(vNewObjHdl, aMem, 4);
  if (Erx<>_ErrOk) then begin
    BinClose(vNewObjHdl);
    RETURN(Erx)
  end;

  // Eigenschaften des Objektes setzen
  vNewObjHdl->spTypeMime # FsiSplitName(aFilename,_FsiNameE);
  // Aenderungen der Eigenschaften speichern
  Erx # vNewObjHdl->BinUpdate();
  if (erx=_rOK) then begin
    aBlobID # vNewObjHdl->spID;
    if (aDlsHdl<>0) then begin
      // Zeile hinzufuegen
      vLine # WinLstDatLineAdd(aDlsHdl, vNewObjHdl->spName, _WinLstDatLineLast);
      // Eigenschaften des Objektes in der Liste anzeigen
      SetDLLine(aDlsHdl, vNewObjHdl, vLine);
    end;
  end;
  
  vNewObjHdl->BinClose();

  // Ausgangsvereichnis wieder schliessen
  BinClose(vDirHdl);

  RETURN Erx;
end;


//========================================================================
// Export
//  Binaeres Objekt exportieren
//========================================================================
sub Export(
  aObjFullName      : alpha(4096);
  aExternFull       : alpha(4096);
  aDBA              : int;
  aOverwrite        : logic;
) : int;
local begin
  vExpObjHdl        : int;
  vPathName         : alpha;
  vFileName         : alpha;
  vErr              : int;
end;
begin
  vFileName # FsiSplitName(aObjFullName,_FsiNameNE);
  if (vFileName  = '') then RETURN (errIllegalFilename);

  // Ziel exisitiert?
  if (Lib_FileIO:FileExists(aExternFull+'\'+vFilename)) then begin
    if (aOverWrite=false) then RETURN errObjExists;
    if (FsiDelete(aExternFull+'\'+vFilename)<>_rOK) then RETURN -1;
  end;

  vExpObjHdl # BinOpen(0, aObjFullName, aDBA);
  if (vExpObjHdl < 0) or (vExpObjHdl=_rDeadLock) then begin
    RETURN vExpObjHdl;
  end;

  vErr # BinExport(vExpObjHdl, aExternFull+'\'+vFileName);
  BinClose(vExpObjHdl)

  RETURN(vErr)
  
end;


//========================================================================
//  CopyRechteID
//
//========================================================================
sub CopyRechteID(
  aVon  : int;
  aNach : int) : int;
local begin
  Erx   : int;
end;
begin

  DeleteRechte(aNach);

  // Rechte loopen...
  GV.Int.20 # aVon;
  FOR Erx # Reklink(917, 999, 9, _recFirst)
  LOOP Erx # Reklink(917, 999, 9, _recNext)
  WHILE (erx<=_rLocked) do begin
    Blb.R.ID # aNach;
    Erx # RekInsert(917, _recunlock, 'AUTO');
    if (Erx<>_rOK) then RETURN Erx;
    Blb.R.ID # aVon;
    RecRead(917,1,0);
  END;

  RETURN _rOK;
end;


//========================================================================
//  CopyRechteDir
//
//========================================================================
sub CopyRechteDir(
  aSourceBinDir : alpha(4000);
  aDestBinDir   : alpha(4000);
  aDBA          : int;
) : int;
local begin
  vDir        : int;
  vID1, vID2  : int;
end;
begin

//debugx('copyrechte:'+aSourceBinDir+' -> '+aDestbinDir);
  vDir # BinDirOpen(0, aSourceBinDir, aDBA);
  if (vDir<0) or (vDir=_rDeadLock) then RETURN vDir;
  vID1 # vDir->spID;
  BinClose(vDir);

  vDir # BinDirOpen(0, aDestBinDir, aDBA);
  if (vDir<0) or (vDir=_rDeadLock) then RETURN vDir;
  vID2 # vDir->spID;
  BinClose(vDir);

  RETURN CopyRechteID(vID1, vID2);
end;


//========================================================================
//  CopyDir
//
//========================================================================
sub CopyDir(
  aSource : alpha(4000);
  aDest   : alpha(4000);
  aDBA    : int)
: int
local begin
  Erx   : int;
  vDir  : int;
  vName : alpha;
end;
begin

// 'Templates\Adressen', 'Adresse\1234'

  // neues Verzeichnis anlegen:
  CreateDir(FsiSplitName(aDest, _FsiNamePP), FsiSplitName(aDest, _FsiNameNE), aDBA, 0);
  Erx # CopyRechteDir(aSource, aDest, aDBA);
  if (Erx<>_rOK) then RETURN Erx;

  vDir # BinDirOpen(0, aSource, aDBA);
  if (vDir<0) or (vDir=_rDeadLock) then RETURN vDir;

  // Alle Verzeichnisse ermitteln
  vName # BinDirRead(vDir, _BinFirst|_BinDirectory|aDBA);
  WHILE (vName != '') do begin

    // Unterverzeichnisse zu diesem Verzeichnis kopieren
    Erx # CopyDir(aSource+'\'+vName, aDest+'\'+vName, aDBA);
    if(Erx<>_rOK) then begin
      BinClose(vDir);
      RETURN Erx;
    end;

    // naechsten Verzeichnis(Namen) ermitteln
    vName # BinDirRead(vDir, _BinNext|_BinDirectory|aDBA);
  END;


  BinClose(vDir);

  RETURN _rOK;
end;


//========================================================================
//  Execute
//
//========================================================================
Sub Execute(
  aName : alpha(4000);
  aDBA  : int) : alpha;
begin

  FsiPathCreate(_Sys->spPathTemp+'StahlControl');

  if (Export(aName, _Sys->spPathTemp+'StahlControl', aDBA, true)<>_errOK) then RETURN '';

  aName # FsiSplitName(aName, _FsiNameNE);
  aName # _Sys->spPathTemp+'StahlControl\'+aName;
//  SysExecute('*'+'"'+_Sys->spPathTemp+'\StahlControl\'+aName+'"','',_Execwait);
  SysExecute('*'+'"'+aName+'"','', _ExecMaximized);
//  FsiDelete(_Sys->spPathTemp+'\'+vA);

  RETURN aName;
end;


//========================================================================
//  call Lib_Blob:InitBlobCA1
//
//========================================================================
Sub InitBlobCa1();
local begin
  Erx         : int;
  vOK         : logic;
  vDBACOnnect : int;
  vPath       : alpha(4000);
  vFilename   : alpha(4000);
  vDBA        : int;
  vBlobID     : int;
  vWin        : int;
end;
begin

  if (Set.ExtArchiev.Path<>'CA1') then RETURN;

  vDBA # _BinDBA3;
  if (gDBAConnect=0) then begin
    if (RunAFX('XLINK.CONNECT.DOKCA1','')>0) then vDBAConnect # 3
    else RETURN;
  end;


  vWin # Lib_Progress:Init('Import Blob');

  FOR Erx # RecRead(916,1,_recFirst)
  LOOP Erx # RecRead(916,1,_recNext)
  WHILE (erx<=_rLocked) do begin
    if (Anh.BlobID<>0) then CYCLE;
    if (Anh.File='') then CYCLE;
    if (Lib_FileIO:FileExists(Anh.File)=false) then CYCLE;

    Lib_Progress:Setlabel(vWin, Anh.File);

    vFilename # Anh.File;//FsiSplitName(Anh.File, _FsiNameNE);

    vPath # Anh_Data:CreateBLOBPath(Anh.Datei, Anh.Key);
    if (vPath='') then CYCLE;


    // Existiert bereits??
    //if (Exists(vPath, vFilename, vDBA)>0) then begin
    Erx # Exists(var vOK, vPath, vFilename, vDBA)
    if (vOK) then begin
//      if (Msg(99,'Datei existiert bereit!ÜBerschreiben?',_WinIcoQuestion,_WinDialogYesNo,2)<>_Winidyes) then CYCLE;
      if (Import(vFilename, vPath, vDBA, 0, true, var vBlobID)<>_ErrOK) then begin
        Msg(99,'FEHLER: '+vFilename+' nicht überschreibbar',0,0,0);
        CYCLE;
      end;
      Erx # RecRead(916,1,_recLock);
      if (Erx=_rOK) then begin
        Anh.BlobID # vBlobID;
        Erx # RekReplace(916,_recunlock,'AUTO');
      end;
      if (erx<>_rOK) then begin
        Msg(99,'FEHLER: '+vFilename+' : Datensatz nicht änderbar',0,0,0);
        CYCLE;
      end;
    end
    else begin
      // neu importieren...
      if (Import(vFilename, vPath, vDBA, 0, false, var vBlobID)<>_ErrOK) then begin
        Msg(99,'FEHLER: '+vFilename+' nicht lesbar',0,0,0);
        CYCLE;
      end;
    end;

    Erx # RecRead(916,1,_recLock);
    if (Erx=_rOK) then begin
      Anh.BlobID  # vBlobID;
      Anh.File    # FSISplitName(vFilename, _FsiNameNE);
      Erx # RekReplace(916,_recunlock,'AUTO');
    end;
    if (erx<>_rOK) then begin
      Msg(99,'FEHLER: '+vFilename+' : Datensatz nicht änderbar',0,0,0);
      CYCLE;
    end;
  END;

  Lib_Progress:Term(vWin);

  if (vDBAConnect<>0) then begin
    DbaDisconnect(vDBAConnect);
  end;

  Msg(999998,'',0,0,0);
end;


//========================================================================
//  sub CutFilename(aFilename : alpha) : alpha
//  Konvertiert einen Dateipfad in eine Blob-kompatible Version
//  max 60 Stellen inkl. Dateieindung
//========================================================================
sub CutFilename(aFilename : alpha(4096)) : alpha
local begin
  vtmp : alpha(4096);
end;
begin
  vTmp  # FsiSplitname(aFilename,_FsiNameE);
  vTmp  # StrAdj(StrCut(FsiSplitname(aFilename,_FsiNameN),1,60-(StrLen(vTmp)+1)),_StrEnd) + '.' + vTmp;
  RETURN vTmp;
end;


//========================================================================