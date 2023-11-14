@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Graph
//                      OHNE E_R_G
//  Info
//
//
//  01.09.2014  AH  Erstellung der Prozedur
//  27.07.2021  AH  ERX
//
//========================================================================
@I:Def_Global
@I:Def_BAG

define begin
  cCR             : StrChar(10)

  Str_GetVonBis   : Lib_Strings:GetVonBis
  Str_CutVonBis   : Lib_Strings:CutVonBis

//  cSelectMarker3 : '*e:\selected_cyan.png'
//  cSelectMarker2 : '*e:\selected5.png'
  cSelectMarker : 'graph_selected5'

/*
  ANum(a,b)   : CnvAf(a,_FmtNumNoGroup,0,b)
  AInt(a)     : CnvAI(a,_FmtNumNoGroup)
  TODO(a)     : windialogbox(0, a, a, 0,0,0)
  Debug(a)    : Lib_Debug:Dbg_Debug(a)
  DebugX(a)   : Lib_Debug:Dbg_Debug(a+'   ['+__PROC__+':'+aint(__LINE__)+']')
  Str_Token(a,b,c)      : Lib_Strings:Strings_Token(a,b,c)
  Str_PosNum(a,b,c)     : Lib_Strings:Strings_PosNum(a,b,c)
*/
end;

//========================================================================
//========================================================================
Sub Trenne701();
local begin
  Erx       : int;
  vBuf701   : int;
  vBuf707   : int;
  vKill707  : logic;
end;
begin
  // hierauf bereits verwogen?
  if (BA1_IO_I_Data:BereitsVerwogen() = true) then begin
    Msg(701007,'',0,0,0);
    RETURN;
  end;

  // MS 18.03.2010
  if (BAG.P.Aktion = c_BAG_VSB) then begin
    if(BA1_P_Data:BereitsVerwiegung(BAG.P.Aktion) = true) then begin
      Msg(701026, '', 0, 0, 0);
      RETURN;
    end;
  end;

  // Weiterbearbeitung?
  if (BAG.IO.Materialtyp=c_IO_BAG) then begin
    vBuf701 # RecBufCreate(701);
    vBuf707 # RecBufCreate(707);
    vKill707 # n;
    FOR Erx # RecLink(vBuf707,701,20,_recFirst)   // Brüder durchlaufen
    LOOP Erx # RecLink(vBuf707,701,20,_recNext)
    WHILE (erx<=_rLocked) and (vKill707=n) do begin
      Erx # RecLink(vBuf701,vBuf707,8,_recFirst);
      if (erx<=_rLocked) then begin
        if (vBuf701->BAG.IO.NachBAG<>0) then
          vKill707 # y;
      end;
    END;
    RecBufDestroy(vBuf707);
    RecBufDestroy(vBuf701);
  end;


  // Diesen Eintrag wirklich löschen?
//  if (Msg(000001,'',_WinIcoQuestion,_WinDialogYesNo,2)=_WinIdNo) then begin
//    RETURN;
//  end;

  TRANSON;

  if (vKill707) then begin

    if (Msg(701035,'?',_WinIcoQuestion,_WinDialogYesNo, 1)<>_winidyes) then begin
      RETURN;
    end;

    vBuf701 # RekSave(701);
    FOR Erx # RecLink(707,701,20,_recFirst)   // Brüder loopen
    LOOP Erx # RecLink(707,701,20,_recNext)
    WHILE (Erx<=_rLocked) do begin

      vBuf707 # RekSave(707);
      Erx # RecLink(701,707,8,_recFirst);   // Output holen
      if (Erx<=_rLocked) then begin
        if (BAG.IO.NachBAG<>0) then begin
          if (BA1_FM_Data:SetSperre()<>true) then begin
            TRANSBRK;
            ErrorOutput;
            RekRestore(vBuf707);
            RekRestore(vBuf701);
            RETURN;
          end;
          ErrorOutput;
        end;
      end;
      RecBufCopy(vBuf701, 701);
      RekRestore(vBuf707);
    END;

    RekRestore(vBuf701);
  end;

  if (BA1_IO_I_Data:DeleteInput(false) = false) then begin
    TRANSBRK;
    ErrorOutput;
    RETURN;
  end;

  TRANSOFF;

  BA1_P_Data:UpdateSort();
end;


//========================================================================
//========================================================================
sub Func_Trennen();
local begin
  Erx     : int;
  vGrf    : int;
  vHdl    : int;
  vA      : alpha;
  vID     : int;
  vP1,vP2 : int;
  vF      : int;
  vBAG    : int;
end;
begin
  vGrf # winsearch(gMDI, 'Graph');
  if (vGrf=0) then RETURN;

  vHdl # winsearch(gMDI, 'ie.Nummer');
  vBAG # vHdl->wpcaptionint;

  FOR vHdl # Wininfo(vGrf, _Winfirst)
  LOOP vHdl # Wininfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
    if (vHdl->wpcaption='') then CYCLE;

    vA # vHdl->wpname;


    // "ID1"
    if (StrCut(vA,1,2)='id') then begin
      vID  # cnvia(vA);
      BAG.IO.Nummer # vBAG;
      BAG.IO.ID     # vID;
      Erx # RecRead(701,1,0);
      if (Erx=_rOK) then begin
        Trenne701();
      end;
    end
    // "P1"
    else if (StrCut(vA,1,1)='p') then begin
      vP1  # cnvia(vA);
    end
    // "f1p1"
    else if (StrCut(vA,1,1)='f') then begin
      vF # cnvia(Str_token(vA,'p',1));
      vP1 # cnvia(Str_token(vA,'p',2));
    end
    // "Line_p1_p2"
    else if (StrCut(vA,1,5)='line_') then begin
      vA # strcut(vA,5,100);
      vP1 # cnvia(Str_token(vA,'_',1));
      vP2 # cnvia(Str_token(vA,'_',2));
    end;

  END;

end;

//========================================================================
//========================================================================
sub Func_Reset();
local begin
  vGrf  : int;
  vHdl  : int;
end;
begin
  vGrf # winsearch(gMDI, 'Graph');
  if (vGrf=0) then RETURN;

  FOR vHdl # Wininfo(vGrf, _Winfirst)
  LOOP vHdl # Wininfo(vGrf, _Winfirst)
  WHILE (vHdl<>0) do begin
    WinRemove(vHdl);
  END;

end;

//========================================================================
//========================================================================
sub inch(aF : float) : int;
begin
  RETURN cnvif(aF * 96.0);
end;


//========================================================================
//========================================================================
sub ReadLine(
  aTxt    : handle;
  var aZ  : int) : alpha;
local begin
  vA      : alpha(4000);
end;
begin
  inc(aZ);
  vA # TextLineRead(aTxt, aZ, 0);
  if (TextInfo(aTxt, _TextNoLineFeed)=0) then RETURN vA;

  vA # vA + ReadLine(aTxt, var aZ);

  RETURN vA;
end;


//========================================================================
//========================================================================
sub MyRect(
  aX        : int;
  aY        : int;
  aXX       : int;
  aYY       : int) : rect;
local begin
  vRect     : rect;
end;
begin

  vRect # Rectmake(aX, aY, aX + aXX, aY + aYY);

//debug('myRecT:'+aint(vX - vXX)+'/'+aint(vY - vYY)+' bis '+aint(vX + vXX)+'/'+aint(vY + vYY));
  RETURN vRect;
end;


//========================================================================
//========================================================================
sub Split(
  aText         : alpha(4096);
  aSep          : alpha;
  var aL        : alpha;
  var aR        : alpha;
) : logic;
local begin
  vI      : int;
end;
begin

  vI # StrFind(aText, aSep, 0);
  if (vI=0) then begin
    aL # StrAdj(aText, _StrBegin | _StrEnd);
    RETURN false;
  end;

  aL # StrAdj(StrCut(aText, 1, vI), _StrBegin | _StrEnd);
  aR # StrAdj(StrCut(aText, vI + StrLen(aSep), 4000), _StrBegin | _StrEnd);

  RETURN true;
end;


//========================================================================
//========================================================================
sub Box.Create(
  aName         : alpha;
  aTitle        : alpha;
  aRect         : rect
) : handle;
local begin
  vBox  : handle;
  vRect : rect;
end
begin

  vRect # aRect;
//  GraphBox.GridToPixel(var vRect);

  vBox # WinCreate(_WinTypePicture, aName);
  vBox->wpArea        # vRect;
  vBox->wpTextLabel   # aTitle;

//vBox->wpJustify     # _WinJustCenter;
//vBox->wpJustifyVert # _WinJustCenter;
vBox->wpScrollBarvisible # false;
vBox->wpOpacity # 100;
vBox->wpHelpTip # 'Das isr '+aName;
vBox->wpStyleBorder # _WinBorStandard;

vBox->wpModeEffect # _WinModeEffectRotCustom;

//vBox->wpAutoupdate  # false;
//vBox->wpAreaScaling # true;

//vBox->wpcaption # cSelectMarker
//vBox->wpZoomfactor # -100;

  vBox->wpModeDraw    # _WinModeDrawStretch;
//vBox->wpModeDraw    # _WinModeDrawRatio;
  vBox->wpColBkg      # _WinColTransparent;

  vBox->WinEvtProcNameSet(_WinEvtMouse,__PROC__ + ':EvtMouse');
//debug('new knot:'+aint(vRect:Left)+'/'+aint(vRect:top)+' nach '+aint(vRect:Right)+'/'+aint(vRect:bottom));
  RETURN(vBox);
end;


//========================================================================
// Graph.Create
//========================================================================
sub Graph.Create(
  aRect     : rect;
) : handle;
local begin
  vGraph : handle;
end
begin
   vGraph # WinCreate(_WinTypePicture);

//debug('new screen:'+aint(aRect:Right)+'/'+aint(aRect:Bottom));
aRect:Bottom # 900;
  vGraph->wpArea              # aRect;
  vGraph->wpStyleBorder       # _WinBorStandard;
  vGraph->wpModeOptimize      # _WinModeOptimizeSpeed;
  vGraph->wpScrollbarVisible  # false;

//debugx('new grap');
//vGraph->wpScrollBarVisible # false;
//vGraph->wpAutoupdate  # false;
//vGraph->wpModeZoom    # _WinModeZoomCursor;

   RETURN(vGraph);
end


//========================================================================
//========================================================================
sub EvtMouse(
  aEvt                  : event;        // Ereignis
  aButton               : int;          // Maustaste
) : logic;
local begin
  vFrame  : handle;
  vRect   : rect;
end
begin
  vFrame # aEvt:obj->WinInfo(_WinFrame);
  vRect # aEvt:obj->wparea;

  if ((aButton  & (_WinMouseLeft | _WinMouseDouble)) = (_WinMouseLeft | _WinMouseDouble)) then begin
//    vFrame->wpCaption # 'Doppelklick ' + aEvt:obj->wpname;

    if (aEvt:Obj->wpcaption='') then
      aEvt:Obj->wpcaption # cSelectMarker
    else
      aEvt:Obj->wpcaption # '';

  end
  else if ((aButton  & _WinMouseLeft) != 0) then begin
//    vFrame->wpCaption # 'Klick ' + aEvt:obj->wpname+'   '+aint(vRect:top);
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtTimer(
  aEvt                 : event;    // Ereignis
  aTimerID             : int;      // Timer-ID
) : logic;
local begin
  vObj  : int;
end;
begin
//  Animate($graph);
  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtClose(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  vHdl # cnvia($Graph->wpCustom);
  if (vHdl<>0) then SysTimerClose(vHdl);

  App_Main:EvtClose(aEvt);
  RETURN(true);
end;


//========================================================================
//========================================================================
sub ParseTable(
  aGraph  : handle;
  aText   : alpha(4000);
  aX      : int;
  aY      : int;
  aXX     : int;
  aYY     : int;
  aOffY   : int;
  aExtend : logic;
  );
local begin
  vX, vY  : int;
  vXX,vYY : int;
  vI, vJ  : int;
  vA, vB  : alpha(4000);
  vCap    : alpha(4000);
  vName   : alpha;
  vL      : int;
  vRect   : rect;
  vKnot   : handle;
end;
begin

    // <TR>
    //   <TD COLSPAN="45">1) Spalten</TD>
    // </TR>
    // <TR>
    //   <TD PORT="f1p1" WIDTH="100">F1<BR/>2 je 165,0</TD>
    //   <TD PORT="f2p1" WIDTH="100">F2<BR/>4 je 187,0</TD>
    //   <TD PORT="f3p1" WIDTH="100">F3<BR/>2 je 57,5</TD>
    // </TR>
    aText # Lib_Strings:Strings_ReplaceAll(aText, '<BR/>', '|');

    vA # Str_CutVonBis(var aText, '<TR>', '</TR>');
    Split(vA, '>', var vA, var vB);
    Split(vB, '<', var vA, var vB);

    aText # Str_CutVonBis(var aText, '<TR>', '</TR>');

    vJ # Lib_strings:Strings_Count(aText,'<TD');    // Unterelemente zählen

    vX  # aX;
    vY  # aY + aOffY + 1;         // nach unten
    vYY # aYY - aOffY - 14;       // Höhe nur noch der "Rest"
    vXX # (aXX / vJ) - 1;

    // Rekord-Token loopen...
    FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
      vA # Str_CutVonBis(var aText, '<TD', '</TD>');
      vName # Str_token(vA, 'PORT="', 2);
      vName # Str_token(vName, '"', 1);

      Split(vA, '>', var vA, var vB);
      Split(vB, '<', var vA, var vB);
      vCap # Str_Token(vA, '|', 1);

      vRect # MyRect(vX, vY, vXX, vYY);
      vKnot # Box.Create(vName, '', vRect);
      aGraph->Winadd(vKnot);
      vKnot->wpAreaScaling # true;

      if (aExtend) then begin
        vRect # MyRect(vX, vY+vYY, 24, 24);
        vKnot # Box.Create('del_'+vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Fertigung';
      end;

      vX # vX + vXX + 1;
    END;

end;


//========================================================================
//========================================================================
sub ParseRecord(
  aGraph  : handle;
  aText   : alpha(4000);
  aX      : int;
  aY      : int;
  aXX     : int;
  aYY     : int;
  aOffY   : int;
  aExtend : logic;
  );
local begin
  vX, vY  : int;
  vXX,vYY : int;
  vI, vJ  : int;
  vC      : alpha(4000);
  vName   : alpha;
  vL      : int;
  vRect   : rect;
  vKnot   : handle;
end;
begin

    vJ # Lib_strings:Strings_Count(aText,'|');

    vX  # aX;
    vY  # aY + aOffY + 1;     // nach unten
    vYY # aYY - aOffY - 3;       // Höhe nur noch der "Rest"
    vXX # aXX;

//debugx('tok:'+aint(vX)+'/'+aint(vY)+'    '+aint(vXX)+'/'+aint(vYY));

    // Rekord-Token loopen...
    FOR vI # 1 loop inc(vI) while (vI<=vJ) do begin
      vC # Str_Token(aText,'|',vI + 1);
//debug('teil:'+vC);
      vName # Str_Token(vC,'>',1);
      vName # Str_Token(vName,'<',2);

      vC # Str_Token(vC,'>',2);
      vC # Str_Token(vC,'\n',2);
      if (vI=vJ) then
        vC # Str_Token(vC,'}',1);
      vC # StrAdj(vC,_StrBegin  | _Strend);
//      Lib_BCSCOM:TextWidth(vC,'Arial', 14, var vL);   // Times-Roman 14
vL # 50;

      vXX # vL + 16;
//      if (vI=1) then vXX # vXX + 1;
//      if (vI=vJ) then aXX # aXX + 1;

      if (vI=vJ) and (vX + vXX < aX + aXX) then vXX # aXX;

      vRect # MyRect(vX, vY, vXX, vYY);
      vKnot # Box.Create(vName, '', vRect);
      aGraph->Winadd(vKnot);
      vKnot->wpAreaScaling # true;

      if (aExtend) then begin
        vRect # MyRect(vX, vY+vYY, 24, 24);
        vKnot # Box.Create('del_'+vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Fertigung';
      end;

//vKnot->wpColBkg # _wincolred;
//vKnot->wpCaption # '*e:\ellipse_red.png';
      vX # vX + vXX + 1;
    END;

end;


//========================================================================
//========================================================================
sub CreateGraphFromPlain(
  aParent     : handle;
  aGraph      : handle;
  aScrollBox  : handle;
  aRect       : rect;
  aPlainText  : alpha(1000);
  aExtend     : logic;
) : logic;
local begin
  vErx      : int;
  vTxt      : handle;
  vI,vJ,vK  : int;
  vL        : int;
  vA,vB,vC  : alpha(4000);
  vLine     : alpha(4000);
  vRest     : alpha(4000);
  vCmd      : alpha(4000);
  vZ        : int;
  vX, vY    : int;
  vXX, vYY  : int;
  vF        : float;
  vCap      : alpha(1000);

  vPicW     : int;
  vPicH     : int;
  vRect     : rect;
  vScB      : handle;
  vName     : alpha(1000);
  vKnot     : handle;
end

begin


  // Graph bereits gefüllt???
//  if (Wininfo(aGraph,_winfirst)<>0) then begin
//    Func_Reset();
//  end;


  vTxt # TextOpen(20);
//  vErx # TextRead(vTxt, 'E:\graph.txt', _TextExtern);
  vErx # TextRead(vTxt, aPlainText, _TextExtern);

  inc(vZ);
  vCmd # TextLineRead(vTxt, vZ, 0);
  // Start muss GRAPH sein
  Split(vCmd, ' ', var vA, var vB);

  if (vA<>'graph') then begin
    TextClose(vTxt);
    RETURN false;
  end;
  vF  # cnvfa(Str_Token(vB, ' ', 2), _FmtNumPoint);
  vPicW         # inch(vF);
  vF  # cnvfa(Str_Token(vB, ' ', 3), _FmtNumPoint);
  vPicH         # inch(vF) + 2;
  if (aGraph=0) then begin
    aGraph # Graph.Create(rectMake(0,0,vPicW,vPicH));
    aGraph->wpColBkg # _WinColInfoBackground;
  end;

  // Zeile für Zeile...
//  inc(vZ);
  vCmd # ReadLine(vTxt, var vZ);
  WHILE (vCmd<>'') and (vCmd<>'stop') do begin

    vCmd # vRest + vCmd;
    vRest # '';

    // Klammern voprhanden??
    vJ # Lib_strings:Strings_Count(vCmd,'{');
    if (vJ>0) then begin
      if (Lib_strings:Strings_Count(vCmd,'}')<vJ) then begin
        vRest # vCmd;
//        inc(vZ);
//        vCmd # TextLineRead(vTxt, vZ, 0);
        vCmd # ReadLine(vTxt, var vZ);
        CYCLE;
      end;
    end;


    Split(vCmd, ' ', var vA, var vB);
    if (vA='edge') then begin
      // edge p1 p6 7 12.069 2.917 12.611 2.625 12.778 2.625 13.333 2.389 14.444 1.889 15.708 1.292 16.528 0.889 "E1\n6Stk\n2605kg\n(2605kg)" 15.583 1.944 solid black

      if (Lib_Strings:Strings_Count(vB,'"')=2) then begin

        vName # Str_Token(vB, ' ',1);
        vName # 'line_'+vName + '_' + Str_Token(vB, ' ',2);

        vJ # Lib_strings:Strings_Count(vB,'\n') + 1; // Anzahl Zeilen

        Split(vB, '"', var vA, var vB);
        Split(vB, '"', var vA, var vB);

        vF # cnvfa(Str_Token(vB, ' ', 1), _FmtNumPoint);
        vX # inch(vF);
        vF # cnvfa(Str_Token(vB, ' ', 2), _FmtNumPoint);
        vY # vPicH - inch(vF);

//debug('ed '+vname+' : '+aint(vX)+'/'+aint(vY));
        vXX # 90;
        vYY # 24 * vJ;
        vX  # (vX + 6) - (vXX / 2);
        vY  # (vY + 2) - (vYY / 2);

        vRect # MyRect(vX, vY, vXX, vYY);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;
//vKnot->wpZoomfactor # -100;
//vKnot->wpStyleBorder # _WinBorSunken;
      end;

    end;

    if (vA='node') then begin
      // z.B: node id1  3.097 14.375 2.349 1.748 "E1 \nMat.4641 \n2,00x1500,0mm\n1Stk 12000kg" bold invhouse green lightgrey
      //      node p1  6.847 3.361 2.750 0.889 "{1)Spalten |{  <f1p1> F1\n2 à 165,0 |  <f2p1> F2\n4 à 187,0 |  <f3p1> F3\n2 à 57,5 } }" solid record black lightgrey
      //      node p1 8.3201 3.2351 4.3889 0.90278 <<FONT FACE="Arial" POINT-SIZE="14"><TABLE BORDER="0" CELLBORDER="1" CELLSPACING="0"><TR><TD COLSPAN="45">1) Spalten</TD></TR><TR><TD PORT="f1p1" WIDTH="100">F1<BR/>2 je 165,0</TD><TD PORT="f2p1"
      //           WIDTH="100">F2<BR/>4 je 187,0</TD><TD PORT="f3p1" WIDTH="100">F3<BR/>2 je 57,5</TD></TR></TABLE></FONT>> solid plaintext black lightgrey

      vName # Str_Token(vB, ' ',1);

      Split(vB, ' ', var vA, var vB);

      vF # cnvfa(Str_Token(vB, ' ', 1), _FmtNumPoint);
      vX # inch(vF);
      vF # cnvfa(Str_Token(vB, ' ', 2), _FmtNumPoint);
      vY # vPicH - inch(vF);
      vF # cnvfa(Str_Token(vB, ' ', 3), _FmtNumPoint);
      vXX # inch(vF);
      vF # cnvfa(Str_Token(vB, ' ', 4), _FmtNumPoint);
      vYY # inch(vF);

      vC    # '';
      vCap # Str_Token(vB, '"', 2);

      if (StrFind(vB, 'invhouse',0)>0) then begin
        vX  # (vX + 6) - (vXX / 2);
        vY  # (vY + 18) - (vYY / 2);
        vXX # vXX - 1;
        vYY # vYY - 16 - 8;
        vRect # MyRect(vX, vY, vXX, vYY);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;

        if (aExtend) then begin
          vRect # MyRect(vX + vXX, vY, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Einsatz';
        end;

      end
      else if (StrFind(vB, 'house',0)>0) then begin
        vX  # (vX + 6) - (vXX / 2);
        vY  # (vY + 8) - (vYY / 2);
        vXX # vXX - 1;
        vYY # vYY - 16 + 5;
        vRect # MyRect(vX, vY, vXX, vYY);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;

        if (aExtend) then begin
          vRect # MyRect(vX+vXX-2, vY+vYY-24, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Pos';
        end;

      end
      else if (StrFind(vB, 'box',0)>0) then begin
        vX  # (vX + 6) - (vXX / 2);
        vY  # (vY + 4) - (vYY / 2);
        vXX # vXX - 1;
        vYY # vYY - 2;

        vRect # MyRect(vX, vY, vXX, vYY);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;
      end
      else if (StrFind(vB, '</TABLE>',0)>0) then begin

        vB # Str_GetVonBis(vB, '<TABLE', '</TABLE>');
        Split(vB, '>', var vA, var vB);

        vX  # (vX + 16) - (vXX / 2);
        vY  # (vY + 10) - (vYY / 2);
        vXX # vXX - 22;
        vK  # 26;
        vRect # MyRect(vX, vY, vXX, vK);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;

        ParseTable(aGraph, vB, vX, vY, vXX, vYY, vK, aExtend);

        if (aExtend) then begin
          vRect # MyRect(vX + vXX, vY + vYY - 24 - 13, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\plus.png';
vKnot->wpHelpTip # 'neue Fertigung';

          vRect # MyRect(vX + vXX, vY, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Pos';
        end;

      end
      else if (StrFind(vB, 'record',0)>0) then begin
        // Caption = "{1)Spalten |{  <f1p1> F1\n2 à 165,0 |  <f2p1> F2\n4 à 187,0 |  <f3p1> F3\n2 à 57,5 } }"

        vX  # (vX + 6) - (vXX / 2);
        vY  # (vY + 4) - (vYY / 2);
        vXX # vXX - 1;
        vK  # 30;
        vRect # MyRect(vX, vY, vXX, vK);
        vKnot # Box.Create(vName, '', vRect);
        aGraph->Winadd(vKnot);
        vKnot->wpAreaScaling # true;
//debugx('knot:'+aint(vX)+'/'+aint(vY)+'    '+aint(vXX)+'/'+aint(vYY));

        ParseRecord(aGraph, vCap, vX, vY, vXX, vYY, vK, aExtend);

        if (aExtend) then begin
          vRect # MyRect(vX + vXX, vY + vYY - 24, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\plus.png';
vKnot->wpHelpTip # 'neue Fertigung';

          vRect # MyRect(vX + vXX, vY, 24, 24);
          vKnot # Box.Create('del_'+vName, '', vRect);
          aGraph->Winadd(vKnot);
          vKnot->wpAreaScaling # true;
vKnot->wpCaption # '*e:\delete.png';
vKnot->wpHelpTip # 'del Pos';
        end;

      end;

    end;

//    inc(vZ);
//    vCmd # TextLineRead(vTxt, vZ, 0);
    vCmd # ReadLine(vTxt, var vZ);
  END;

  TextClose(vTxt);

//aGraph->wpzoomfactor # -100;

  // ohne Scrollbox
/*
  if (aParent<>0) then begin
    aGraph->wpAreaRight # 700;
    aGraph->wpcaption # '*.\visualizer\pics\ah.jpg';
    aParent->WinAdd(aGraph);
  end
  else begin
    aScrollBox->wpArea          # aGraph->wpArea;
    aScrollBox->wpScrollWidth   # aGraph->wpPicWidth+25;
    aScrollBox->wpScrollHeight  # aGraph->wpPicHeight;
    aGraph->wpArea # RectMake(0,0,aGraph->wpPicWidth,aGraph->wpPicHeight);
  end;
*/

  // mit Scrollbox
/*
  vScB # WinCreate(_WinTypeScrollbox, 'Scrollbox');
  vScB->wpArea          # aRect;
  vScB->wpScrollWidth   # vPicW;
  vScB->wpScrollHeight  # vPicH;
  aParent->WinAdd(vScB);
  vScB->Winadd(vGraph);
*/
end;



//========================================================================
// EvtChanged
//            Feldveränderungen
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
local begin
  vI    : int;
  vHdl  : int;
  vGrf  : int;
end;
begin

  if (aEvt:Obj->wpchanged=false) then RETURN true;

  vI # $IE.Zoom->wpcaptionint;

  vGrf # $Graph;

  vGrf->winupdate(_WinUpdOff);

/**/
  FOR vHdl # Wininfo(vGrf, _Winfirst)
  LOOP vHdl # Wininfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
//    vHdl->winupdate(_WinUpdOff);
    vHdl->wpvisible # false;
  END;
/**/

  vGrf->wpzoomfactor # vI;

/**/
  FOR vHdl # Wininfo(vGrf, _Winfirst)
  LOOP vHdl # Wininfo(vHdl, _WinNext)
  WHILE (vHdl<>0) do begin
//    vHdl->winupdate(_WinUpdON);
    vHdl->wpvisible # true;
  END;
/**/
  vGrf->winupdate(_WinUpdOn);

//  $scrollbox->wpScrollWidth   # $scrollbox->wpArearight - $scrollbox->wpAreaLeft - 16;
//  $scrollbox->wpScrollHeight  # $scrollbox->wpAreabottom - $scrollbox->wpAreatop - 16;

//  $Graph->wpArea # RectMake(0,0,$Graph->wpPicWidth * vI / 100,$Graph->wpPicHeight * vI / 100);

end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
begin


  if (aEvt:obj->wpname='bt.NeuPosition') then begin
    Msg(99,'Vorgabe Daten fehlen!',0,0,0);
    RETURN true;
  end;

  if (aEvt:obj->wpname='bt.Verbinden') then begin
    Msg(99,'Vorgabe Daten fehlen!',0,0,0);
    RETURN true;
  end;

  if (aEvt:obj->wpname='bt.Trennen') then begin
    Func_Trennen();
    Func_Reset();
    BA1_Graph:CreateGraph($Graph, 0, y);
    RETURN true;
  end;

  RETURN(true);
end;


//========================================================================
//========================================================================
//========================================================================
//========================================================================