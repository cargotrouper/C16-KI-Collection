@A+
//===== Business-Control =================================================
//
//  Prozedur    .
//
//  Info
//
//
//  21.06.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//
//========================================================================
@I:def_global

global Block begin
  block_ID    : alpha(10);
  block_X     : float;
  block_Y     : float;
  block_platz : float;
  block_turn  : logic;
end

global Raum begin
  raum_ID     : int;
  raum_X      : float;
  raum_Y      : float;
  raum_frei   : float;
  raum_PList  : int;      // Liste auf Punkte
  raum_ResList  : int;  // Liste auf Reserv
end

global Punkt begin
  punkt_x     : float;
  punkt_y     : float;
//  punkt_Block : int;
end;

global Reserv begin
  Reserv_x     : float;
  Reserv_y     : float;
  Reserv_Block : int;
end;

//*****************************

global Common begin
  gERR    : int;

  gHdl    : int;
  gHdl2   : int;
  gHdl3   : int;
  gItem   : int;
  gItem2  : int;
  gA      : alpha;
  gN      : float;

  gBList  : int;
  gRList  : int;
  gPList  : int;

  gPHdl   : Int;
  gPHdl2  : int;
  gKHdl   : int;
  gKHdl2  : int;

  gF      : float;

  gPerm_ID      : int[10];
  gPerm_i       : int;
  gPerm_anzahl  : int;
  gPerm_p       : int;
end;


define begin
  cFaktor : 0.1
  cMitTurn : false
end;


//========================================================================
sub _ausgabe();
local begin
  k : INT;
end;
BEGIN
  FOR k # 1 loop inc(k) WHILE (k<=gperm_anzahl) do
debug(cnvai(gPerm_ID[k]));
 if (10%6=4) then
END;


//========================================================================
sub _tausch(VAR aID1 : int; var aID2 : int);
local begin
  h : int;
end;
BEGIN
  h    # aID1;
  aID1  # aID2;
  aID2  # h;
END;


//========================================================================
sub _perm (aN : int);
local begin
  vk : INt;
end;
begin

  IF (aN = 0) THEN BEGIN
    _ausgabe();
    inc(gPerm_p);
    end
  else begin
    FOR vk # aN loop dec(vK) while (vK>=1) do BEGIN
      _tausch(var gperm_ID[vk],var  gPerm_ID[aN]);
      _perm(aN-1);
      _tausch(var gPerm_ID[vk], var gPerm_ID[aN]);
    END;
  end;
END;


//========================================================================
sub StartPerm();
BEGIN
  gPerm_ID[1] # 10;
  gPerm_ID[2] # 20;
  gPerm_ID[3] # 30;
  gPerm_Anzahl # 3;
//  _perm(3);


  //_tauschBlock(var gperm_ID[vk],var  gPerm_ID[aN]);
  gItem # gBList->cteRead(_CteFirst);
  gHdl # HdlLink(gItem);
  gItem2 # gBList->cteRead(_CteNext, gItem);
  gHdl2 # HdlLink(gItem2);
  HdlLink(gItem2, gHdl);
  HdlLink(gItem, gHdl2);

  gItem # gBList->cteRead(_CteFirst);
  WHILE (gItem<>0) do begin
    VarInstance(Block,HdlLink(gItem));
debug(block_ID);
    gItem # gBList->cteRead(_CteNext,gItem);
  END;

END;


//========================================================================
// Output
//
//========================================================================
sub Output();
local begin
  vRaum     : int;
  vItem     : int;
  vBlock    : int;
  vX        : int;
end;
begin
  gHdl # Winopen('aaa',_Winopendialog);


  vRaum   # gRList->cteRead(_CteFirst);
  WHILE (vRaum<>0) do begin
    varinstance(Raum,hdllink(vRaum));
//debug('Freiraum: '+cnvaf(raum_frei));

    FOR vX # 1 loop inc(vX) WHILE (vX<=50) do begin
      gHdl2 # gHdl->winsearch('Button'+cnvai(vX));
      gHdl2->wpvisible # false;
    END;
    gHdl->wparealeft  # 0;
    gHdl->wpareatop   # 0;
    gHdl->wparearight   # (cnvif(raum_X * cFaktor))+8;
    gHdl->wpareabottom  # (cnvif(raum_Y * cFaktor))+25;
    gHdl->wpcaption     # cnvai(raum_ID);

    vX # 1;
    vItem  # Raum_resList->cteread(_Ctefirst);
    WHILE (vItem<>0) do begin
      varinstance(Reserv,HdlLink(vItem));
      varinstance(Block,HdlLink(reserv_block));

      gHdl2 # gHdl->winsearch('Button'+cnvai(vX));
      gHdl2->wpvisible # true;
      gHdl2->wparealeft   # cnvif(Reserv_x * cFaktor);
      gHdl2->wpareatop    # cnvif(Reserv_y * cFaktor);
      gHdl2->wparearight  # cnvif((block_x+Reserv_x) * cFaktor);
      gHdl2->wpareabottom # cnvif((block_y+Reserv_y) * cFaktor);
      if (block_turn) then
         gHdl2->wpcaption    # '_'+block_ID
       else
         gHdl2->wpcaption    # block_ID;
      inc(vX);

      vItem # raum_resList->cteread(_CteNext,vItem);
    END;

    gHdl->windialogrun(_WindialogCenter | _Windialogapp);


    vRaum   # gRList->cteRead(_CteNext,vRaum);
  END;

  gHdl->winclose();

end;


//========================================================================
// NewPunkt
//
//========================================================================
sub NewPunkt(aPList : int; aX : float; aY : float);
begin
  // Punkt ********************
  gPHdl  # CteOpen(_CteItem);
  gPHdl2 # VarAllocate(Punkt);
  HdlLink(gPHdl,gPHdl2);
  gPHdl->spname # cnvaf(aX,_FmtNumLeadZero|_FmtNumNoGroup,0,2,8)+cnvaf(aY,_FmtNumLeadZero|_FmtNumNoGroup,0,2,8);
  punkt_x     # aX;
  punkt_y     # aY;
  aPList->CteInsert(gPHdl);

//debug('new punkt:'+cnvaf(aX)+' '+cnvaf(ay));
end;


//========================================================================
// NewReserv
//
//========================================================================
sub NewReserv(aRList : int; aX : float; aY : float; aBlock :int);
begin
  // Reserv ********************
  gPHdl  # CteOpen(_CteItem);
  gPHdl2 # VarAllocate(Reserv);
  HdlLink(gPHdl,gPHdl2);
  Reserv_x      # aX;
  Reserv_y      # aY;
  Reserv_block  # aBlock;
  aRList->CteInsert(gPHdl);
//debug('new Res:'+cnvaf(aX)+' '+cnvaf(ay));
end;


//========================================================================
// NewRaum
//
//========================================================================
sub NewRaum(aID : int; aX : float; aY : float);
begin

  // Punkteliste **************
  //gHdl3 # CteOpen(_CteList);
  gHdl3 # CteOpen(_CteTree);

  NewPunkt(gHdl3, 0.0, 0.0);

  // Raum *********************
  gHdl # CteOpen(_CteItem);

  if (aY>aX) then begin // drehen
    gN # aX;
    aX # aY;
    aY # gN;
  end;

  // Datenbereich anlegen
  gHdl2 # VarAllocate(Raum);
  HdlLink(gHdl,gHdl2);

  raum_ID     # aID;
  raum_X      # aX;
  raum_Y      # aY;
  raum_frei   # aX*aY;
  raum_PList  # gHdl3;

  // leere ResListe erzeugen
  raum_resList # CteOpen(_CteList);

  gA # cnvaf(100000.0 - aX,_FmtNumLeadZero | _FmtNumNoGroup,0,2,15);
//debug('insert:'+ga);
  gHdl->spName  # gA + CnvAI(gHdl,_FmtNumHex | _FmtNumLeadZero,0,8);
  gHdl->spID    # aID;

  gRList->CteInsert(gHdl);
end;


//========================================================================
// NewBlock
//
//========================================================================
sub NewBlock(aID : alpha(10); aX : float; aY : float);
begin
  gHdl # CteOpen(_CteItem);

  // Datenbereich anlegen
  gHdl2 # VarAllocate(Block);
  HdlLink(gHdl,gHdl2);

  if (aX>aY) /*and (cMitTurn)*/ then begin // drehen
    block_turn # !block_turn;
    gN # aX;
    aX # aY;
    aY # gN;
  end;

  block_ID   # aID;
  block_X    # aX;
  block_Y    # aY;
  block_platz # aX*aY;


  gA # cnvaf(100000.0 - aX,_FmtNumLeadZero | _FmtNumNoGroup,0,2,15)+cnvaf(100000.0 - aY,_FmtNumLeadZero | _FmtNumNoGroup,0,2,15);;
//debug('insert:'+ga);
  gHdl->spName # gA + CnvAI(gHdl,_FmtNumHex | _FmtNumLeadZero,0,8);
  gHdl->spcustom # aID;

  gBList->CteInsert(gHdl);
end;


//========================================================================
//  Konflikt?
//
//========================================================================
sub Konflikt(aLeft : float; aBottom : float; aRight : float; aTop : float) : logic;
local begin
  vBBuf   : int;

  vRes    : int;
  vX,vX2  : float;
  vY,vY2  : float;
  vOk     : logic;
  vS1,vS2 : int;

end;
begin
  vBBuf # VarInfo(Block);

//debug('prüfe basis: '+cnvaf(aLeft)+'x'+cnvaf(abottom)+'   '+cnvaf(aright)+'x'+cnvaf(atop));

  vOk # y;
  vRes # raum_resList->cteread(_ctefirst);
  WHILE (vRes<>0) do begin
    varinstance(Reserv,HdlLink(vRes));
    varinstance(Block,HdlLink(Reserv_block));

    vX    # Reserv_x;
    vY    # Reserv_y;
    vX2   # vX + block_x;
    vY2   # vY + block_y;
//debug('prüfe: '+cnvaf(vX)+'x'+cnvaf(vY)+'   '+cnvaf(vX2)+'x'+cnvaf(vY2));

    if (vX<=aLeft) then         vS1 # 1
    else if (vX<aRight) then    vS1 # 2
    else                        vS1 # 3;
    if (vY<=aBottom) then       vS1 # vS1 + 6;
    else if (vY<aTop) then      vS1 # vS1 + 3;
    else                        vS1 # vS1 + 0;

    if (vX2<=aLeft) then        vS2 # 1
    else if (vX2<aRight) then   vS2 # 2
    else                        vS2 # 3;
    if (vY2<=aBottom) then      vS2 # vS2 + 6;
    else if (vY2<aTop) then     vS2 # vS2 + 3;
    else                        vS2 # vS2 + 0;
//debug('sektor : '+cnvai(vS1)+' '+cnvai(vS2));

    // Mitten drin? - schlecht
    if (vS1=5) or (vS2=5) then begin
      vOk # n;
      BREAK;
    end;

    // gleicher Sektor? - ok
     if (vS1=vS2) then begin
      vRes # raum_resList->cteread(_ctenext,vRes);
      CYCLE;
    end;

    // Von unten-links bis ? - schlecht
    if  ( ((vS1=4) or (vS1=7) or (vS1=8)) and
          ((vS2=2) or (vS2=3) or (vS2=6)) ) then begin
      vOk # n;
      BREAK;
    end;


    vRes # raum_resList->cteread(_ctenext,vRes);
  END;

  varinstance(Block,vBBuf);
//vok # y;
  RETURN !vOK;

end;


//========================================================================
//  PutBlockInRaum?
//
//========================================================================
sub PutBlockInRaum(aRaum : int; aBlock : int) : logic;
local begin
  vHdl : int;
  vItem : int;
  vTurn : int;
  vPasst : logic;
end;
begin

  varinstance(Raum,hdllink(aRaum));
  varinstance(Block,hdllink(aBlock));

//debug('passt block: '+block_id+'?');

  vHdl # raum_PList;
  vItem # vHDL->cteread(_Ctefirst);
  WHILE (vItem<>0) do begin
    varinstance(Punkt,HdlLink(vItem));

    vTurn # 0;
    WHILE (vTurn<=1) do BEGIN
      inc(vTurn);

      if (cMitTurn=n) then vTurn # 2;
      if (vTurn=2) and (cMitTurn) then begin
        gF # block_x;
        block_x # block_y;
        block_y # gF;
        block_turn # !block_turn;
      end;

      // passt gar nicht
      if (punkt_x+block_x>raum_x) or
        (punkt_y+block_y>raum_y) then begin
        CYCLE;
      end;

      // Überschneidungen
      if (Konflikt(punkt_x,punkt_y,punkt_x+block_x,punkt_y+block_y)=true) then begin
        CYCLE;
      end;

//debug('passt');

      // Punkt mit Block belegen
      NewReserv(raum_resList, punkt_x, punkt_y, ablock);

      raum_Frei # raum_frei - (block_platz);
      vHdl->CteDelete(vItem);

      // zwei neue Punkte generieren
      NewPunkt(vHDL, punkt_x+block_x, punkt_y);
      varinstance(Punkt,HdlLink(vItem));
      NewPunkt(vHDL, punkt_x, punkt_y+block_y);

      RETURN true;

    END;    // Drehen

    if (cMitTurn) then begin
      gF      # block_x;
      block_x # block_y;
      block_y # gF;
      block_turn # !block_turn;
    end;

    vItem # vHDL->cteread(_CteNext,vItem);
  END;


  RETURN false;

end;


//========================================================================
MAIN();
local begin
  vX      : int;
  vSel    : int;
  vBlock  : int;
  vRaum   : int;
  vErg    : int
end;
begin
/***/
  RecBufClear(998);
  Sel.Datei           # 250;
  Sel.Selektionsname  # '!DYNAMISCH';
  Sel.Check.Prozedur  # '!!!TEST';
  Sel.UserID          # 1;
/**/
  RecInsert(998,0);

  // temp. Prozedur erzeugen
  Callold('old_Sel_Proccompiler',Sel.Check.Prozedur, vErg);

  RmtCall('Lib_Server:Remote_SelRun',1);
  REPEAT
    WinSleep(500);
    RecRead(998,1,0);
  UNTIL (Sel.Status<>0);
  RecDelete(998,0);

  TextDelete(Sel.Check.Prozedur, _TextProc);  // temp. Prozedur löschen

/**/

  vSel # SelOpen();
  vErg # SelRead(vSel, Sel.Datei, _SelLock, Sel.Selektionsname);
  if (vErg<>_rOK) then todo('ERROR A : '+cnvai(vErg));
  //vErg # SelRun(vSel,_SelDisplay | _Selwait );
  if (vErg<>_rOK) then todo('ERROR B : '+cnvai(vErg));
  vX # RecInfo(Sel.Datei, _recCount, vSel);
  vSel->SelClose();

todo('fertig! : '+cnvai(vX));

RETURN;
/****/

//app_Main();
//RETURN;

  Lib_Debug:InitDebug();

  VarAllocate(Common);

  // Liste für die Räume
  gRList # CteOpen(_CteList);

  // Liste für die Blöcke
//  gBList # CteOpen(_CteTreeCi);
  gBList # CteOpen(_CteList);


  NewBlock('A 1',   900.0, 2150.0);
  NewBlock('A 2',   2150.0, 900.0);
  NewBlock('A 3',   2150.0, 900.0);
  NewBlock('A 4',   2150.0, 900.0);
  NewBlock('A 5',   2150.0, 900.0);
  NewBlock('A 6',   2150.0, 900.0);
  NewBlock('A 7',   2150.0, 900.0);

  NewBlock('B 1',   2150.0, 1100.0);
  NewBlock('B 2',   2150.0, 1100.0);
  NewBlock('B 3',   2150.0, 1100.0);
  NewBlock('B 4',   2150.0, 1100.0);
  NewBlock('B 5',   2150.0, 1100.0);
  NewBlock('B 6',   2150.0, 1100.0);
  NewBlock('B 7',   2150.0, 1100.0);
  NewBlock('B 8',   2150.0, 1100.0);
/***/

/****
  // Blöcke anlegen
  NewBlock('Maus',    10.0,   30.0);
  NewBlock('Pizza',   10.0,   40.0);
  NewBlock('Mond',   100.0,  100.0);
  NewBlock('DinA4',   20.0,   30.0);
  NewBlock('Pixel',   10.0,   10.0);

  NewBlock('Horst',   50.0,   20.0);
  NewBlock('Anne',    40.0,   40.0);
  NewBlock('Fritz',   30.0,   40.0);
  NewBlock('Uschi',   70.0,   20.0);
  NewBlock('Gerd',    10.0,   15.0);
  NewBlock('Willi',   20.0,   25.0);
  NewBlock('Berta',   30.0,   35.0);

  FOR vX # 1 LOOP inc(vx) WHILE (vX<=35) do
    NewBlock('Teil'+cnvai(vX),    5.0+rnd(random()*5.0)*5.0, 10.0+rnd(random()*8.0)*5.0);

  NewBlock('Susi',    25.0,   35.0);
  NewBlock('Egon',    35.0,   15.0);
  NewBlock('Rolf',    45.0,   40.0);
****/


  // Räume anlegen
  FOR vX # 1 loop inc(vX) while (vX<5) do begin
    NewRaum(vX,       2150.0,  5000.0);
  end;

  // BELEGEN ********************************************
  vRaum   # gRList->cteRead(_CteFirst);
  vBlock  # gBList->cteRead(_CteFirst);
  WHILE (vRaum<>0) and (vBlock<>0) do begin

    if (PutBlockInRaum(vRaum, vBlock)=false) then begin
      vRaum   # gRList->cteRead(_CteNext, vRaum);
      CYCLE;
    end;

    vRaum   # gRList->cteRead(_CteFirst);
    vBlock  # gBList->cteRead(_Ctenext,vBlock);
  END;

  if (vBlock<>0) then begin
    WinDialogBox(0,'FEHLER','Passt nicht!',0,0,0);
    gERR # 1;
  end;


  // OUTPUT *********************************************
  Output();


  // CLEANUP ********************************************

  // Räume löschen
  gItem # gRList->CteRead(_CteFirst);
  WHILE (gItem<>0) do begin
    VarInstance(Raum,HdlLink(gItem));

    gHdl # Raum_PList;
    gItem2 # gHdl->CteRead(_CteFirst);
    WHILE (gItem2<>0) do begin
//debug('killpunkt');
      VarInstance(Punkt,HdlLink(gItem2));
      VarFree(Punkt);
      gHdl->CteDelete(gItem2);
      gItem2 # gHdl->CteRead(_CteFirst);
    END;
    gHdl->CteClose();

    Raum_ResList->CteClear(TRUE);
    Raum_ResList->CteClose();

//debug('killRaum');
    VarFree(Raum);
    gRList->CteDelete(gItem);
    gItem # gRList->CteRead(_CteFirst);
  END;
  gRList->CteClear(TRUE);
  gRList->CteClose();


  // Blöcke löschen
  gItem # gBList->CteRead(_CteFirst);
  WHILE (gItem<>0) do begin
    VarInstance(Block,HdlLink(gItem));
//debug('killblock');
    VarFree(Block);
    gBList->CteDelete(gItem);
    gItem # gBList->CteRead(_CteFirst);
  END;
  gBList->CteClear(TRUE);
  gBList->CteClose();

  VarFree(Common);


end;


//========================================================================