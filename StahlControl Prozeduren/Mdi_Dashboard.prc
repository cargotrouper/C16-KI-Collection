@A+
//===== Business-Control =================================================
//
//  Prozedur  Mdi_Dashboard
//                  OHNE E_R_G
//  Info
//
//
//  25.07.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//  SUB EvtInit
//  SUB EvtTerm
//  SUB EvtTimer
//
//========================================================================
@I:Def_Global

//========================================================================
//  EvtInit
//========================================================================
sub EvtInit(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin

  vHdl # SysTimerCreate(100,-1, aEvt:obj);
  $lb.Timer->wpcustom # aint(vHdl)+'|';

  RETURN (true);
end;


//========================================================================
//========================================================================
sub EvtMdiActivate(
  aEvt                 : event;    // Ereignis
) : logic;
begin
  gMenuName # 'Main';
  gFrmMain->wpMenuname # gMenuName;
  gMenu # gFrmMain->WinInfo(_WinMenu);
  Lib_GuiCom:TranslateObject(gMenu);
  Lib_GuiCom:TranslateObject(aEvt:obj);
  RETURN(true);
end;


//========================================================================
//  EvtTerm
//========================================================================
sub EvtTerm(
  aEvt                 : event;    // Ereignis
) : logic;
local begin
  vHdl  : int;
  vA    : alpha;
end;
begin

  vHdl # cnvia($lb.Timer->wpcustom);
  SysTimerClose(vHdl);
  gMdiDashboard # 0;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub UpdateGroup(
  aObj  : int;
  aStep : int);
local begin
  vObj        : int;
  vA          : alpha;
end;
begin

  FOR vObj # aObj->WinInfo(_WinFirst);
  LOOP vObj # vObj->WinInfo(_WinNext);
  WHILE (vObj>0) do begin

    if (vObj->wpDisabled) or (vObj->wpVisible=false) then CYCLE;

    vA # vObj->wpName;
//    if (Wininfo(vObj, _wintype)=_WinTypePicture) then begin
//      if (vA='Chart') and (aStep=0) then Lib_Gauge:UpdateChart(0, vObj);
//      CYCLE;
//    end;
    if (Wininfo(vObj, _wintype)=_WinTypeGroupbox) then begin
      if (vA='Groupbox') then UpdateGroup(vObj, aStep);
      if (vA='Chart') and (aStep=0) then Lib_Gauge:UpdateChart(vObj,0);
      if (vA='Gauge') then Lib_Gauge:UpdateGauge(vObj);
      if (vA='Gauge2') then Lib_Gauge:UpdateGauge2(vObj, aStep);
      if (vA='Progress') then Lib_Gauge:UpdateProgress(vObj);
      if (vA='Ampel') then Lib_Gauge:UpdateAmpel(vObj);
      if (vA='Bar') then Lib_Gauge:UpdateBar(vObj);
    end;

  END;

//  aObj->winupdate(_WinupdOn);
end;


//========================================================================
//========================================================================
sub EvtClicked(
  aEvt                 : event;    // Ereignis
) : logic;
begin

  if (Set.Ost.Wie='M') then begin
    Ost_Data:ProcessStack();
  end;

  RETURN(true);
end;


//========================================================================
//  EvtTimer
//========================================================================
sub EvtTimer(
  aEvt                 : event;    // Ereignis
  aTimerID             : int;      // Timer-ID
) : logic;
local begin
  vObj        : int;
  vA          : alpha;
  vChart      : handle;
  vChartData  : handle;
  vMem        : handle;
  vCount      : int;
  vI          : int;
  vHdl        : handle;
end;
begin


  vCount # cnvia($lb.Count->wpcustom);
  if (vCount=20) then vCount # 0
  else inc(vCount);
  $lb.Count->wpcustom # aint(vCount);


  // Refresh benötigt?
  if (Set.Ost.Wie='M') then begin
    vHdl # WinSearch(aEvt:Obj,'btRefresh');
    if (RecRead(891,1,_RecFirst)<=_rLocked) then begin
      vHdl->wpvisible # true;
      if (vCount<=10) then
        vHdl->wpColBkg  # RGB(200+(vCount*5),200+(vCount*5),100)
      else
        vHdl->wpColBkg  # RGB(200+100-(vCount*5),200+100-(vCount*5),100);
    end
    else begin
      if (vHdl->wpvisible) then
        vHdl->wpvisible # false;
    end;
  end;

  // JOB-SERVER steht???
  if (Set.Ost.Wie='J') then begin
    vHdl # WinSearch(aEvt:Obj,'lbJobError');
    if (RmtDataRead('JOBSERVER', _recunlock, var vA)>_rLocked) then begin
      vHdl->wpvisible # true;
    end
    else begin
      vHdl->wpvisible # false;
    end;
  end;

//aEvt:Obj->wpcaption # vA+aint(vCOunt);
// end;

//  if (vCount=1) then    JOBSERVER
//    Ost_Data:ProcessStack();

  UpdateGroup(aEvt:obj, vCount);

  if (vCount=119) then begin

vMem # MemAllocate(_MemAutoSize);

  vChart # ChartOpen(_ChartXY, 450, 300, 'Titel');
  if (vChart > 0) then begin
    // Titel der X-Achse des Koordinatendiagramms
    vChart->spChartXYTitleX     # 'X-Achse';
    // Titel der Y-Achse des Koordinatendiagramms
    vChart->spChartXYTitleY     # 'Y-Achse';
    // Diagrammbereich des Graphen
    vChart->spChartArea         # RectMake(60, 50, 380, 250);
    // Titelbereich
    vChart->spChartTitleArea    # RectMake(0, 0, 450, 0);
    // Tiefe des Koordinatendiagramms
    vChart->spChartXYDepth      # 10;
vChart->spChartXYBarShape   # _ChartXYBarShapeCircle;

    // Hintergrundfarbe des Diagramms
    vChart->spChartColBkg       #
      ColorMake(ColorRgbMake(240, 240, 240));
    // Hintergrundfarbe des Titels
    vChart->spChartTitleColBkg  #
      ColorMake(ColorRgbMake(0, 32, 192), 128);
    // Vordergrundfarbe des Titels
    vChart->spChartTitleColFg   #
      ColorMake(ColorRgbMake(255, 255, 255));
    // Hintergrundfarbe des Koordinatendiagramms
    vChart->spChartXYColBkg     #
      ColorMake(ColorRgbMake(255, 255, 255));
    // Alternative Hintergrundfarbe des Koordinatendiagramms
    vChart->spChartXYColBkgAlt  #
      ColorMake(ColorRgbMake(0, 32, 192), 240);
    // Balkenschattierung des Koordinatendiagramms
    vChart->spChartXYBarShading # _ChartXYBarShadingGradientBottom;

    // Datenstil des Koordinatendiagramms (pro Datenreihe)
//    vChart->spChartXYStyleData  # _ChartXYStyleDataSpline;//
    vChart->spChartXYStyleData  # _ChartXYStyleDataBar;
    // Rahmenfarbe des Koordinatendiagramms (pro Datenreihe)
    vChart->spChartXYColBorder  #
      ColorMake(ColorRgbMake(255, 255, 255), 160);
    // Datenfarbe des Koordinatendiagramms (pro Datenreihe)
    vChart->spChartXYColData    #
      ColorMake(ColorRgbMake(0, 32, 192), 128);

for vi # 0 loop inc(vI) while(vI<=2) do begin

    vChart->spChartXYColData  #
      ColorMake(ColorRgbMake(125*vI, 32*vI, 192-(vI*50)), 128);

    // Datenreihe für Werte und Beschriftungen öffnen
    vChartData # vChart->ChartDataOpen(5,
      _ChartDataValue | _ChartDataLabel);
    if (vChartData > 0) then begin
      // Beschriftung
      vChartData->ChartDataAdd('A', _ChartDataLabel);
      // Wert
      vChartData->ChartDataAdd(7.0*Random(), _ChartDataValue);
      vChartData->ChartDataAdd('B', _ChartDataLabel);
      vChartData->ChartDataAdd(7.0*Random(), _ChartDataValue);
      vChartData->ChartDataAdd('C', _ChartDataLabel);
      vChartData->ChartDataAdd(7, _ChartDataValue);
      vChartData->ChartDataAdd('D', _ChartDataLabel);
      vChartData->ChartDataAdd(3, _ChartDataValue);
      vChartData->ChartDataAdd('E', _ChartDataLabel);
      vChartData->ChartDataAdd(5, _ChartDataValue);

      // Datenreihe schließen
      vChartData->ChartDataClose();
    end;
end;

    // Diagramm speichern
//    vChart->ChartSave('C:\Chart.png', _ChartFormatAuto);
    vChart->ChartSave('', _ChartFormatAuto, vMem);

    // Diagramm schließen
    vChart->ChartClose();
  end;

$Chart->wpMemObjHandle # vMem;
//$Chart->winupdate(_Winupdon, _winupdfld2Obj);
end;
  RETURN (true);
end;

//========================================================================