@A+
//===== Business-Control =================================================
//
//  Prozedur    Lib_Sel
//                        OHNE E_R_G
//  Info
//
//
//  07.07.2008  AI  Erstellung der Prozedur
//  28.08.2008  PW  Erweiterung der Querybefehle
//  12.05.2010  AI  Erweiterung für Time
//  06.06.2012  AI  Ähnlich OHNE Gross/Kleinschreibung
//  11.03.2015  AH  SelRun setzt Windowbonus wieder richtig
//  14.04.2021  AH  2. Selektion
//  27.07.2021  AH  ERX
//
//  Subprozeduren
//    SUB Save ( aHdl : int; opt aPostfix : alpha ) : alpha
//    SUB Run( aHdl : int; opt aHidden : logic) : int;
//    SUB SaveRun( var aHdl : int; aKey : int; opt aHidden : logic ; opt aPostif : alpha) : alpha
//    SUB QRecList( aRecList : int; aQ : alpha(4000); opt aSuffix : alpha )
//    SUB QError( aHdl : handle ) : int
//    sub IntersectMark ( var aSel : int; var aSelName : alpha; aFile : int; opt aKey : int );
//
//    SUB QInt   ( var aQ : alpha; aFld : alpha; aOp : alpha; aW1 : int;   opt aLog : alpha )
//    SUB QFloat ( var aQ : alpha; aFld : alpha; aOp : alpha; aW1 : float; opt aLog : alpha )
//    SUB QAlpha ( var aQ : alpha; aFld : alpha; aOp : alpha; aW1 : alpha; opt aLog : alpha )
//    SUB QDate  ( var aQ : alpha; aFld : alpha; aOp : alpha; aW1 : date;  opt aLog : alpha )
//    SUB QLogic ( var aQ : alpha; aFld : alpha; aW1 : logic; opt aLog : alpha );
//    SUB QTime  ( var aQ : alpha; aFld : alpha; aOp : alpha; aW1 : time;  opt aLog : alpha )
//    SUB QVonBisI ( var aQ : alpha; aFld : alpha; aW1 : int;   aW2 : int;   opt aLog : alpha )
//    SUB QVonBisF ( var aQ : alpha; aFld : alpha; aW1 : float; aW2 : float; opt aLog : alpha )
//    SUB QVonBisA ( var aQ : alpha; aFld : alpha; aW1 : alpha; aW2 : alpha; opt aLog : alpha )
//    SUB QVonBisD ( var aQ : alpha; aFld : alpha; aW1 : date;  aW2 : date;  opt aLog : alpha )
//    SUB QenthaeltA ( var aQ : alpha; aFld : alpha; aW1 : alpha; opt aLog : alpha )
//    SUB QVonBisT ( var aQ : alpha; aFld : alpha; aW1 : Time;  aW2 : Time;  opt aLog : alpha )
//
//========================================================================
@I:Def_global
@I:Struct_PartSel

define begin
  c_debugUser : 'AxxI'
  c_KlammerA  : ''
  c_KlammerZ  : ''
end;
declare QError(aHdl : handle) : int;

//========================================================================
//  Save
//
//========================================================================
sub Save(
  aHdl          : handle;
  opt aPostfix  : alpha) : alpha;
local begin
  vSelname  : alpha;
  vSelname2 : alpha;
  vV        : int;
  vErg      : int;
end;
begin

  if (VarInfo(class_list)<>0) then begin
    vSelName # 'TMP.'+ UserInfo(_UserCurrent)+aPostfix+'.List';
    end
  else begin
    vSelName # 'TMP.'+ UserInfo(_UserCurrent)+aPostfix;
  end;

  // speichern...
  REPEAT
    if (vV=0) then
      vSelname2 # vSelname
    else
      vSelname2 # vSelname + '.'+AInt(vV);

    vErg # aHdl->SelStore(vSelName2,_selLock)

    // Fehler: keine Query vorhande? -> triviale Query anlegen
    if (vErg=-12) then begin
      vErg # aHdl->seldefQuery('','Set.eigeneAdressnr=0');
      CYCLE;
    end;

    if (vErg<>_rOK) and (vErg<>_rExists) then begin
      TODO('SELSAVE '+cnvai(vERG));
      RETURN '';
    end;

    if (vErg=_rExists) then vV # vV + 1;

  UNTIL (vErg<>_rExists);

  RETURN vSelName2;
end;


//========================================================================
//  Run
//
//========================================================================
sub Run(
  aHdl          : int;
  opt aHidden   : logic;
  opt aVorSel   : alpha) : int;
local begin
  vZList  : int;
  vI      : int;
  vWinBon : int;
end;
begin
  // Selektion starten...
  if (aHidden) then
    vI # _SelServerAutoFld
  else
    vI # _SelDisplay | _SelServerAutoFld |_SelDisplaydelayed;

  if (gUserName=c_debuguser) then
    vI # vI | _SelWait;

  vZList # gZLList;
  vWinBon # VarInfo(Windowbonus);

  if (aVorSel<>'') then begin
    vI # vI | _SelBase;
//    vI # SelRun(aHdl,vI);
    vI # SelRun(aHdl,vI, aVorSel);
  end
  else begin
    vI # SelRun(aHdl,vI);
  end;

  if (vWinBon<>0) then Varinstance(Windowbonus, vWinBon); // 11.03.2015
  if (gMDI<>0) then begin
    gMDI->winfocusset(true);
    winsleep(100);
    gZLList # vZList;
  end;
  // 11.03.2015 AH: weiter oben  if (vWinBon<>0) then Varinstance(Windowbonus, vWinBon);

  RETURN vI;
end;


//========================================================================
//  SaveRun
//
//========================================================================
sub SaveRun(
  var aHdl      : int;
  aKey          : int;
  opt aHidden   : logic;
  opt aPostfix  : alpha;
  opt aVorSel   : alpha) : alpha;
local begin
  Erx     : int;
  vName   : alpha;
end;
begin

  vName # Save(aHdl, aPostfix);

  aHdl # aHdl->SelOpen();

  // HIER WÄRE SELIGNORE FÜR REVERSE ALPHA-KEYS !!!

  // Umsortieren?
  if (aKey<>0) then SelInfo(aHdl,_SelSort,aKey);

  Erx # Run(aHdl, aHidden, aVorSel);
  if (Erx<>_rOK) then RETURN '';
/**
  vZList # gZLList;

  // Selektion starten...
  if (aHidden) then
    vI # _SelServer | _SelServerAutoFld;
  else
    vI # _SelDisplay | _SelServer | _SelServerAutoFld;

  if (gUserName=c_debuguser) then
    vI # vI | _SelWait;

  vWinBon # VarInfo(Windowbonus);

  Erx # SelRun(aHdl,vI);
  if (erx<>_rOK) then RETURN '';

  if (gMDI<>0) then begin
    gMDI->winfocusset(true);
    winsleep(100);
    gZLList # vZList;
  end;

  if (vWinBon<>0) then Varinstance(Windowbonus, vWinBon);
***/

  RETURN vName;
end;


//========================================================================
//  QRecList
//
//========================================================================
sub QRecList(
  aRecList    : int;
  aQ          : alpha(4000);
  opt aSuffix : alpha;
  opt aKey    : int);
local begin
  Erx       : int;
  vSel      : alpha;
  vHdl      : int;
  vFile     : int;
  vV        : int;
  vSelName2 : alpha;
  vBonus    : int;
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


  vBonus # VarInfo(WindowBonus);
  varInstance(WindowBonus, Cnvia(gMDI->wpcustom));
  if (w_sel2name<>'') then begin   // bisherige temp.Selektion entfernen
    SelDelete(vFile,w_sel2Name);
  end;
  if (w_selname<>'') then begin   // bisherige temp.Selektion entfernen
    SelDelete(vFile,w_selName);
  end;
  //w_SelName # vSel;
  varInstance(WindowBonus, vBonus);


  //SelCopy(vFile,aSelName,vSel);
  //vHdl # SelOpen();
  //SelRead(vHdl,vFile,_SelLock,vSel);

  // Selektion aufbauen...
//debug(aint(aRecList->wpdbkeyno));
  // 10.03.2021 AH: andere Sortierung??
  if (aKey=0) then begin
    aKey # Max(1, aRecList->wpdbkeyno);
    aKey # Max(aKey, gKey);   // 15.07.2021 AH z.B. Prj->Prj.Pos andere Sort
  end;
  gKEY    # aKey;
//  gKEYID  # aKey
  if (gKeyId=0) then   gKEYID  # aKey;    // 20.04.2021 AH, HOW 2224/17
  
  vHdl # SelCreate(vFile, aKey);
  // Selektion aufbauen...
  Erx # vHdl->SelDefQuery('', aQ);
  if (Erx != 0) then QError(vHdl);

  // speichern...
  if (gMDI<>0) then vV # gMDI;
  REPEAT
    if (vV=0) then
      vSelname2 # vSel
    else
      vSelname2 # vSel + '.'+AInt(vV);

    Erx # vHdl->SelStore(vSelName2,_selLock)

    // Fehler: keine Query vorhande? -> triviale Query anlegen
    if (Erx=-12) then begin
      Erx # vHdl->seldefQuery('','Set.eigeneAdressnr=0');
      CYCLE;
    end;

    if (Erx<>_rOK) and (Erx<>_rExists) then begin
      TODO('SELSAVE '+cnvai(Erx));
      RETURN;
    end;

    if (Erx=_rExists) then vV # vV + 1;

  UNTIL (Erx<>_rExists);

  varInstance(WindowBonus, Cnvia(gMDI->wpcustom));
  w_SelName # vSelName2;
  varInstance(WindowBonus, vBonus);;


  // Selektion öffnen...
  vHdl # vHdl->SelOpen();

//gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  if (gUserName=c_debuguser) then
    Erx # SelRun(vHdl,_SelDisplay | _selwait | _SelServerAutoFld)
  else
    Erx # SelRun(vHdl, _SelDisplay | _SelServerAutoFld | _SelDisplaydelayed);
//    Erx # SelRun(vHdl,  _SelServer | _SelServerAutoFld);
  if (vBonus<>0) then varInstance(WindowBonus, vBonus);

  if (Erx<>0) then begin
    Msg(999999,'Selektion konnte NICHT durchgeführt werden!!! (Code'+cnvai(Erx)+c_KlammerZ,1,0,0);
    SelCLose(vHdl);
    SelDelete(vFile,vSel);
    aRecList->wpDbSelection # 0;
    RETURN;
  end;

//  WinSleep(200);
  aRecList->wpDbSelection # vHdl;
//debug('set sel:'+aRecList->wpname+' '+aint(vHdl));

  WinSleep(100);  // 24.07.2014 AH von 500

  RETURN;
end;


//=========================================================================
// IntersectMark [14.04.2010/PW]
//        Schnittmenge mit markierten Elementen bilden (Nachselektion)
//=========================================================================
sub IntersectMark ( var aSel : int; var aSelName : alpha; aFile : int; opt aKey : int );
local begin
  Erx     : int;
  vItem   : handle;
  vSelTmp : alpha;
  vMFile  : int;
  vMId    : int;
end;
begin
  if ( aKey = 0 ) then
    aKey # 1;

  vSelTmp  # aSelName;
  if ( aSel != 0 ) then
    aSel->SelClose();

  aSel     # SelCreate( aFile, aKey );
  aSelName # aSel->Save();
  aSel     # aSel->SelOpen();
  aSel->SelRead( aFile, _selLock, aSelName );

  FOR  vItem # gMarkList->CteRead( _cteFirst );
  LOOP vItem # gMarkList->CteRead( _cteNext, vItem );
  WHILE ( vItem != 0 ) DO BEGIN
    Lib_Mark:TokenMark( vItem, var vMFile, var vMId );
    if ( vMFile != aFile ) then
      CYCLE;

    RecRead( aFile, 0, _recId, vMId );
    aSel->SelRecInsert( aFile );
  END;

  if ( vSelTmp = '' ) then // keine vorherige Selektion ausgeführt
    RETURN;

  // Nachselektion durchführen
  Erx # aSel->SelRun( _selInter | _selDisplay | _selServerAutoFld, vSelTmp );
  if ( Erx != _rOk ) then
    RETURN;

  SelDelete( aFile, vSelTmp );
end;


//========================================================================
//  QError
//
//========================================================================
sub QError (aHdl : handle) : int
local begin
  tStr : alpha(4096)
end;
begin
  if (aHdl->spErrCode != 0) then begin
    tStr # StrCut(aHdl->spErrSource,1,aHdl->spErrPos-1) +
           '[' + aHdl->spErrText + ']'  +
           StrCut(aHdl->spErrSource,aHdl->spErrPos,4096);
    WindialogBox(gFrmMain,'Selektion',tStr,_WinIcoError,_WinDialogOK,1);
  end;
  RETURN (aHdl->spErrCode);
end;


//========================================================================
//  QInt
//
//========================================================================
sub QInt (
  var aQ   : alpha;   // RückgabeQueryvar
  aFld     : alpha;   // Abfragefeld
  aOp      : alpha;   // Vergleichsoperator (=,>,=>,<,<=,*)
  aW1      : int;     // Vergleichswert
  opt aLog : alpha );
begin

  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QInt(var aQ, aFld, aOp, aW1, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' ' + AInt( aW1 )+c_KlammerZ;
end;


//========================================================================
//  QFloat
//
//========================================================================
sub QFloat (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : float;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QFloat(var aQ, aFld, aOp, aW1, aLog);
    RETURN;
  end;


  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 != 0.0 ) then
    aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' ' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint )+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' 0.0'+c_KlammerZ;
end;


//========================================================================
//  QAlpha
//
//========================================================================
sub QAlpha (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : alpha;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QAlpha(var aQ, aFld, aOp, aW1, aLog);
    RETURN;
  end;


  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  //aQ # aQ + '('+ aFld + ' ' + aOp + ' ''' + aW1 + ''''+c_KlammerZ;
  aQ # aQ + c_KlammerA+ aFld + ' ' + aOp + ' ''' + aW1 + ''''+c_KlammerZ;
end;


//========================================================================
//  QDate
//
//========================================================================
sub QDate (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : date;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QDate(var aQ, aFld, aOp, aW1, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 != 0.0.0 ) then
    aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' ' + CnvAD( aW1, _fmtInternal )+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' 0.0.0'+c_KlammerZ;
end;


//========================================================================
//  QLogic
//
//========================================================================
sub QLogic (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : logic;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QLogic(var aQ, aFld, aW1, aLog);
    RETURN;
  end;


  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 ) then
    aQ # aQ +c_KlammerA+ aFld +c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld +'=false'+c_KlammerZ;
end;


//========================================================================
//  QTime
//
//========================================================================
sub QTime (
  var aQ   : alpha;
  aFld     : alpha;
  aOp      : alpha;
  aW1      : time;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QTime(var aQ, aFld, aOp, aW1, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  aQ # aQ +c_KlammerA+ aFld + ' ' + aOp + ' ' + CnvAT( aW1 )+c_KlammerZ;
end;


//========================================================================
//  QVonBisI
//
//========================================================================
sub QVonBisI (
  var aQ    : alpha;
  aFld      : alpha;
  aW1       : int;
  aW2       : int;
  opt aLog  : alpha );
local begin
//  vAttach   : logic;
end;
begin

  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QvonBisI(var aQ, aFld, aW1, aW2, aLog);
    RETURN;
  end;


  if ( aQ != '' ) then begin
//    vAttach # y;
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ aFld + ' between [' + AInt( aW1 ) + ',' + AInt( aW2 ) + ']'+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' = ' + AInt( aW1 )+c_KlammerZ;

end;


//========================================================================
//  QVonBisF
//
//========================================================================
sub QVonBisF (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : float;
  aW2      : float;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QvonBisF(var aQ, aFld, aW1, aW2, aLog);
    RETURN;
  end;


  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ aFld + ' between [' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint ) + ',' + CnvAF( aW2, _fmtNumNoGroup | _fmtNumPoint ) + ']'+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+aFld + ' = ' + CnvAF( aW1, _fmtNumNoGroup | _fmtNumPoint )+c_KlammerZ;
end;


//========================================================================
//  QVonBisD
//
//========================================================================
sub QVonBisD (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : date;
  aW2      : date;
  opt aLog : alpha );
local begin
  vW1      : alpha;
  vW2      : alpha;
end;
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QvonBisD(var aQ, aFld, aW1, aW2, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 = 0.0.0 ) then vW1 # '0.0.0' else vW1 # CnvAD( aW1, _fmtInternal );
  if ( aW2 = 0.0.0 ) then vW2 # '0.0.0' else vW2 # CnvAD( aW2, _fmtInternal );

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ aFld + ' between [' + vW1 + ',' + vW2 + ']'+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' = ' + vW1+c_KlammerZ;
end;


//========================================================================
//  QVonBisA
//
//========================================================================
sub QVonBisA (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : alpha;
  aW2      : alpha;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QvonBisA(var aQ, aFld, aW1, aW2, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ aFld + ' between [''' + aW1 + ''',''' + aW2 + ''']'+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' = ''' + aW1 + ''''+c_KlammerZ;
end;


//========================================================================
//  QenthaeltA
//
//========================================================================
sub QenthaeltA (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : alpha;
  opt aLog : alpha );
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QenthaeltA(var aQ, aFld, aW1, aLog);
    RETURN;
  end;

  QAlpha( var aQ, aFld, '=*^', '*' + aW1 + '*', aLog );
end;


//========================================================================
//  QVonBisT
//
//========================================================================
sub QVonBisT (
  var aQ   : alpha;
  aFld     : alpha;
  aW1      : time;
  aW2      : time;
  opt aLog : alpha );
local begin
  vW1      : alpha;
  vW2      : alpha;
end;
begin
  // SQL-Liste?
  if (gSQLBuffer<>0) then begin
    Lib_SQL:QvonBisT(var aQ, aFld, aW1, aW2, aLog);
    RETURN;
  end;

  if ( aQ != '' ) then begin
    if ( aLog = '' ) then aQ # aQ + ' AND ';
    else aQ # aQ + ' ' + aLog + ' ';
  end;

  if !( aFld =* '"*"' ) then
    aFld # '"' + aFld + '"';

  vW1 # CnvAT( aW1 );
  vW2 # CnvAT( aW2 );

  if ( aW1 != aW2 ) then
    aQ # aQ +c_KlammerA+ aFld + ' between [' + vW1 + ',' + vW2 + ']'+c_KlammerZ;
  else
    aQ # aQ +c_KlammerA+ aFld + ' = ' + vW1+c_KlammerZ;
end;


//========================================================================
//  CreatePartSel
//
//========================================================================
sub CreatePartSel(
  aFile : int;
  aKey  : int;
  aProc : alpha;
) : int
local begin
  vHdl  : int;
end;
begin
  vHdl # VarAllocate(PartSel);
  PartSel_File  # aFile;
  PartSel_Key   # aKey;
  PartSel_Proc  # aProc;

  PartSel_Sel # SelCreate(aFile, aKey);
  PartSel_SelName # Save(PartSel_Sel,'PART');   // speichern mit temp. Namen
  PartSel_Sel # SelOpen();                       // Selektion öffnen
  PartSel_Sel->selRead(aFile,_SelLock,PartSel_SelName); // Selektion laden

  PartSel_Buf # RecBufCreate(aFile);
  PartSel_RecId # 0;

  RETURN VarInfo(PartSel);
end;


//========================================================================
//  ClosePartSel
//
//========================================================================
sub ClosePartSel(aPartSel : int);
begin
  VarInstance(PartSel, aPartSel);

  SelClose(PartSel_Sel);
  SelDelete(PartSel_File,PartSel_selName);

  RecBufDestroy(partSel_Buf);
  VarFree(PartSel);
end;


//========================================================================
//  ResetPartSel
//
//========================================================================
Sub ResetPartSel(aPartSel : int);
begin
  VarInstance(PartSel, aPartSel);
  SelClear(PartSel_Sel);
  PartSel_RecId # 0;
  RecBufClear(PartSel_Buf);
end;


//========================================================================
//  RunPartSel
//
//========================================================================
Sub RunPartSel(
  aPartSel  : int;
  aMax      : int;
  opt aBack : logic;
) : int;
local begin
  Erx       : int;
  vCount    : int;
  vOK       : logic;
  vFlag     : int;
end;
begin

  VarInstance(PartSel, aPartSel);

  if (PartSel_RecID=0) then begin
    if (aBack) then begin
      Erx # RecRead(PartSel_File, PartSel_Key, _reclast);
      vFlag # _recPrev;
      end
    else begin
      Erx # RecRead(PartSel_File, PartSel_Key, _recFirst);
      vFlag # _recNext;
    end;
    end
  else begin
    SelClear(PartSel_Sel);
    RecBufCopy(PartSel_Buf, PartSel_File);
    if (aBack) then begin
      Erx # RecRead(PartSel_File, PartSel_Key, _recPrev);
      vFlag # _recPrev;
      end
    else begin
      Erx # RecRead(PartSel_File, PartSel_Key, _recNext);
      vFlag # _recNext;
    end;
  end;
  if (Erx>_rMultikey) then begin
    PartSel_RecID   # 0;
    RecBufClear(PartSel_Buf);
    RETURN 0;
  end;

  WHILE (Erx<=_rMultikey) and (aMax>0) do begin
    vOK # Call(PartSel_Proc);
    if (vOK) then begin
      Dec(aMax);
      inc(vCount);
      Erx # SelRecInsert(PartSel_Sel, PartSel_File);
    end;
    if (aMax>0) then Erx # RecRead(PartSel_File, PartSel_Key, vFlag);
  END;

  PartSel_RecID # RecInfo(PartSel_File, _recID);
  RecbufCopy(partSel_File, PartSel_Buf);

  RETURN vCount;
end;


//========================================================================

//========================================================================
sub Test_OpenRun(
  var aHdl  : int) : int;
begin
  aHdl # aHdl->SelOpen();
  RETURN SelRun(aHdl, _SelDisplay | _SelServerAutoFld);
end;


//========================================================================