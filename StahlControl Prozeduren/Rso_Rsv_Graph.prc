@A+
//===== Business-Control =================================================
//
//  Prozedur    Rso_Rsv_Graph
//                      OHNE E_R_G
//  Info
//
//
//  14.07.2017  AH  Erstellung der Prozedur
//  22.08.2017  ST  "sub Setup(...)" hinzugefügt
//  04.02.2022  AH  ERX
//
//  Subprozeduren
//    sub Setup(aTyp : alpha; aDatum : date; opt aRaster : int; opt aSchwellenwert  : int; opt aAltlast : logic; )
//
//========================================================================
@I:Def_Global

define begin
  cMinDauer   : 60
  cTitle      : 'Belegungsgraph'
  cFile       :  0
  cMenuName   : 'Std.Bearbeiten'
  cPrefix     : ''
  cZList      : 0
  cKey        : 0
  cStartDatum : $edDatum->wpCaptionDate
  cRaster     : $edRaster->wpCaptionint
  cSchwelle   : $edSchwelle->wpCaptionint
end;

declare GraphTage(aMitAltlast : logic; aVonDat : date; aRasterX : int; aSchwelle : float; aPic : int)
declare GraphWoche(aMitAltlast : logic; aVonDat : date; aRasterX : int; aSchwelle : float; aPic : int)
declare RefreshGraph(aMDI : int)


//========================================================================
//
//
//========================================================================
sub EvtInit(
  aEvt  : event;        // Ereignis
): logic
local begin
  vHdl  : int;
end;
begin

  WinSearchPath(aEvt:Obj);
  gTitle    # Translate(cTitle);
  gFile     # cFile;
  gMenuName # cMenuName;
  gPrefix   # cPrefix;
  gZLList   # cZList;
  gKey      # cKey;

  vHdl # WinSearch(aEvt:obj, 'lb.Res1');
  vHdl->wpcaption       # aint(Rso.Gruppe);
  vHdl # WinSearch(aEvt:obj, 'lb.Res2');
  vHdl->wpcaption       # aint(Rso.Nummer);
  vHdl # WinSearch(aEvt:obj, 'lb.Ressource');
  vHdl->wpCaption       # Rso.Stichwort;
  vHdl # WinSearch(aEvt:obj, 'cbTage');
  vHdl->wpCheckState    # _WinStateChkChecked;
  vHdl # WinSearch(aEvt:obj, 'cbAltlast');
  vHdl->wpCheckState    # _WinStateChkChecked;
  vHdl # WinSearch(aEvt:obj, 'edRaster');
  vHdl->wpcaptionint    # 14;
  vHdl # WinSearch(aEvt:obj, 'edSchwelle');
  vHdl->wpcaptionint    # 80;

//debug('INIT');
  App_Main:EvtInit(aEvt);
  if (w_Obj2Scale<>0) then w_obj2Scale->CteClear(true);

end;


//========================================================================
//========================================================================
sub EvtTerm(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vTimer  : int;
end;
begin

  if (App_Main:EvtTerm(aEvt)=false) then
    RETURN false;

  vTimer # cnvia($cbAuto->wpcustom);
  if (vTimer<>0) then begin
    SysTimerClose(vTimer);
    Winsleep(10);
  end;
  RETURN(true);
end;


//========================================================================
// EvtCreated
//========================================================================
sub EvtCreated
(
  aEvt                  : event;        // Ereignis
)
: logic;
begin
//debugx('EVTCREATED');
//  RefreshGraph();
  RETURN(true);
end;


//========================================================================
//  EvtClicked
//              Button gedrückt
//========================================================================
sub EvtClicked (
  aEvt                  : event;        // Ereignis
) : logic
local begin
  vDat  : date;
  vM    : int;
end;
begin

  vM # 1;
  if ($cbWoche->wpCheckState=_WinStateChkChecked) then
    vM # 7;

  case (aEvt:Obj->wpName) of
    'bt.Left2'   : begin
      vDat # cStartDatum;
      if (vDat>1.1.2000) then begin
        vDat->vmDayModify((- cRaster / 2)*vM);
        cStartDatum # vDat;
        RefreshGraph(gMDI);
      end;
    end;

    'bt.Right2'   : begin
      vDat # cStartDatum;
      if (vDat<1.1.2100) then begin
        vDat->vmDayModify((cRaster / 2)*vM);
        cStartDatum # vDat;
        RefreshGraph(gMDI);
      end;
    end;

    'bt.Left'   : begin
      vDat # cStartDatum;
      if (vDat>1.1.2000) then begin
        vDat->vmDayModify(-1*vM);
        cStartDatum # vDat;
        RefreshGraph(gMDI);
      end;
    end;

    'bt.Right'   : begin
      vDat # cStartDatum;
      if (vDat<1.1.2100) then begin
        vDat->vmDayModify(1*vM);
        cStartDatum # vDat;
        RefreshGraph(gMDI);
      end;
    end;

    'myRefresh' : RefreshGraph(gMDI);
  end;  // ...case

end;


//========================================================================
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vWas    : int;
  vTimer  : int;
end;
begin

  if (aEvt:Obj->wpname='cbAuto') then begin
    if (aEvt:obj->wpCheckState=_WinStateChkChecked) then begin
      vTimer # SysTimerCreate(3000, -1, gMDI);
      aEvt:Obj->wpcustom # aint(vTimer);
      RETURN true;
    end;

    vTimer # cnvia(aEvt:Obj->wpcustom);
    SysTimerClose(vTimer);
    aEvt:Obj->wpcustom # '';
    RETURN true;
  end;


  vWas #_WinStateChkChecked;
  if (aEvt:Obj->wpCheckState=_WinStateChkChecked) then
    vWas #_WinStateChkUnChecked;

  if (aEvt:obj<>$cbWoche) then
    $cbWoche->wpCheckState # vWas
  else
    $cbTage->wpCheckState # vWas;

  RETURN(true);
end;


//========================================================================
//========================================================================
sub EvtTimer(
  aEvt                  : event;        // Ereignis
  aTimerID              : int;          // Timer-ID
) : logic;
begin
  RefreshGraph(aEvt:Obj);
  RETURN(true);
end;


//========================================================================
//  RefreshGraph
//========================================================================
sub RefreshGraph(aMDI : int)
local begin
  vKW     : word;
  vJahr   : word;
  vDat    : date;
  vPath   : int;
  vBonus  : int;
end;
begin

  vPath # WinSearchPathGet();
  WinSearchpath(aMDI);

  vBonus # VarInfo(WindowBonus);
  VarInstance(WindowBonus,cnvIA(aMDI->wpcustom));
  gTitle    # Translate(cTitle)+' @ '+cnvat(now, _FmtTimeSeconds);
  aMdi->wpcaption # gTitle;
  VarInstance(WindowBonus, vBonus);

  // Tageweise?
  if ($cbTage->wpCheckState=_WinStateChkChecked) then begin
    GraphTage($cbAltlast->wpCheckState=_WinStateChkChecked, cStartDatum, $edRaster->wpCaptionInt, cnvfi(cSchwelle), $Picture1);
    if (vPath<>0) then begin  // 01.09.2021 AH
      if (HdlInfo(vPAth,_HdlExists)>1) then
        WinSearchpath(vPath);
    end;
    RETURN;
  end;

  // Wochenweise!

  // auf Montag setzen
  Lib_Berechnungen:KW_aus_Datum(cStartDatum, var vKW, var vJahr);
  Lib_Berechnungen:Mo_von_KW(vKW, vJahr, var vDat);
  cStartDatum  # vDat;

  GraphWoche($cbAltlast->wpCheckState=_WinStateChkChecked, cStartDatum, $edRaster->wpCaptionInt, cnvfi(cSchwelle), $Picture1);
  WinSearchpath(vPath);

end;


//========================================================================
//========================================================================
Sub GraphTage(
  aMitAltlast   : logic;
  aVonDat       : date;
  aRasterX      : int;
  aSchwelle     : float;
  aPic          : int)
local begin
  Erx           : int;
  vBisDat       : date;
  v170          : int;
  vMaxX, vMaxY  : float;
  vChart        : handle;
  vChartData    : handle;
  vMem          : handle;
  vI, vJ, vX    : int;
  vY, vZ        : float;
  vDat,vDat2    : date;
  vWert         : float[99];
  vKapa         : float[99];
  vFont         : font;
  vAltlast      : float;
  vHeute        : int;
  vText         : alpha;
  vFrei         : float;
  vCol          : int;
end;
begin
  if (aVonDat=0.0.0) then RETURN;
  if (aRasterX=0) then aRasterX # 14;
  vBisDat # aVonDat;
  vBisDat->vmDayModify(aRasterX);

  vHeute # cnvid(today) - cnvid(aVonDat) + 1;

  v170 # RekSave(170);

  // Reservierungen loopen...
  FOR Erx # RecLink(170,160,10,_recfirst)
  LOOP Erx # RecLink(170,160,10,_recNext)
  WHILE (Erx<=_rLocked) and (Rso.R.Plan.StartDat<vBisDat) do begin

    vDat # Rso.R.Plan.StartDat;
    if (vDat=0.0.0) then CYCLE;

    if (vDat<today) and (vDat<aVonDat) then begin
      if (aMitAltLast) then
        vAltLast # vAltLast + cnvfi(Rso.R.Dauer) / 60.0;
      CYCLE;
    end;


    vI # cnvid(vDat) - cnvid(aVonDat);
    if (vI<=0) then vI # 0;
    if (vI>=0) and (vI<99) then begin
      vWert[vI+1] # vWert[vI+1] + Max(cnvfi(Rso.R.Dauer) / 60.0, cnvfi(cMinDauer)/60.0);
      vMaxY # Max(vWert[vI+1], vMaxY);
    end;
  END;


  vDat # aVonDat;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterx) do begin
    vY # Rso_Kal_Data:Arbeitszeit(Rso.Gruppe, vDat) / 60.0;
    if (vY>24.0) then vY # 24.0;  // max 24h
    vKapa[vI] # vY;
    vMaxY # Max(vMaxY, vY);
    vDat->vmDayModify(1);
  END;

  vMaxX # 1000.0;
  vMaxY # Max(480.0, vMaxY);

  vChart # ChartOpen(_ChartXY, cnvif(vMaxX), cnvif(vMaxY));//, '', _ChartOptDefault);
  if (vChart <= 0) then RETURN;

  vChart->spChartXYStyleData        # _ChartXYStyleDataBar;//_ChartXYStyleDataLine;
//  vChart->spChartXYStyleData       # _ChartXYStyleDataBar | _ChartXYStyleDataStack;
  vChart->spChartArea               # RectMake(40, 20, cnvif(vMaxX)-5, cnvif(vMaxY)-40);
  vChart->spChartBorderWidth        # 0;
  vChart->spChartColBkg             # ColorMake(ColorRgbMake(240, 240, 255), 0);
  vChart->spChartXYAxisTitleAlignY  # _ChartAlignLeft;
  vChart->spChartXYBarShading       # _ChartXYBarShadingGradientTop;
  vChart->spChartXYColBkg           # ColorMake(ColorRgbMake(232, 232, 255), 0);
  vChart->spChartXYColBkgAlt        # ColorMake(ColorRgbMake(216, 216, 255), 0);
  vChart->spChartXYColBorder        # ColorMake(ColorRgbMake(128, 0, 128), 0);
  vChart->spChartXYColData          # ColorMake(ColorRgbMake(128, 0, 128), 64);
  vChart->spChartXYDepth            # 0;
  vChart->spChartXYDepthGap         # 0;
  vChart->spChartXYLabelColData     # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartXYLabelColSum      # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDefault;
  vChart->spChartXYLabelAngleX      # 90.0;
  vChart->spChartXYTitleAlignY      # _ChartAlignLeft;
  vChart->spChartXYBarGap           # 0.3;
  vChart->spChartXYMinTickIncY      # 2.00;

  vFont # vChart->spChartXYLabelFontX;
  vFont:Size # 120;
  vChart->spChartXYLabelFontX       # vFont;
  vChart->spChartXYLabelFontY       # vFont;
  vChart->spChartXYTitleFontY       # vFont;
  vChart->spChartXYTitleFontX       # vFont;
//  vChart->spChartXYTitleY           # 'h';


  // ALTLAST -------------------------------------------------------------------------------------------------------
  if (vAltLast<>0.0) then begin
    vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataColor);
    if (vChartData <=0) then begin
      vChart->ChartClose();
      RETURN;
    end;

    vChartData->ChartDataAdd(vAltLast);
//  aChartData->ChartDataAdd( ColorMake(ColorRgbMake(64, 255, 64), 100), _ChartDataColor);
    vChartData->ChartDataAdd( ColorMake(ColorRgbMake(64, 64, 64), 100), _ChartDataColor);
//    vChartData->ChartDataAdd(aint(aVonDat->vpDay)+'.'+aint(aVonDat->vpMonth), _ChartDataLabel);

//    _Draw(vChartData, aVonDat, vAltLast, );
    vChartData->ChartDataClose();
  end;


  // BELEGUNG ------------------------------------------------------------------------------------------------------
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDataExtra;
  vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataLabel | _ChartDataColor | _ChartDataExtra);
  if (vChartData <=0) then begin
    vChart->ChartClose();
    RETURN;
  end;
  vDat # aVonDat;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterX) do begin

    vY # vWert[vI];
    // Altlast nur im ersten Balken...
    if (vI=1) then
      vY # vY + vAltLast;

    vFrei # vKapa[vI] - vY;
    vText # ' ';
    if (aRasterX<30) then
      if (vFrei<0.0) then
        vText # aNum(-vFrei,1);

    if (vKapa[vI]<>0.0) then
      vZ # vY / vKapa[vI]
    else
      vZ # 999.0;

    if (vZ<aSchwelle / 100.0) then
      vCol # ColorRgbMake(64, 255, 64)      // GRÜN
    else if (vZ<=1.0) then
      vCol # ColorRgbMake(255, 255, 00)     // GELB
    else
      vCol #ColorRgbMake(255, 64, 64);      // ROT
//      _Draw(vChartData, vDat, vY, ColorMake(ColorRgbMake(255, 64, 64), 100), vText);     // ROT

    vChartData->ChartDataAdd(vY);
//  aChartData->ChartDataAdd( ColorMake(ColorRgbMake(64, 255, 64), 100), _ChartDataColor);
    vChartData->ChartDataAdd( ColorMake(vCol, 100), _ChartDataColor);
    vChartData->ChartDataAdd(aint(vDat->vpDay)+'.'+aint(vDat->vpMonth), _ChartDataLabel);
    vChartData->ChartDataAdd(vText, _ChartDataExtra);


    vDat->vmDayModify(1);
  END;
  vChartData->ChartDataClose();


  // KAPAZITÄT -----------------------------------------------------------------------------------------------------
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDataExtra;
//  vChart->spChartXYLegendText # Translate('Kapazität');
//  vChart->spChartXYStyleData  # _ChartXYStyleDataLine;
//  vChart->spChartXYLineWidth  # 2;
  vChart->spChartXYBarShading       # _ChartXYBarShadingDefault;
  vChart->spChartXYDepth            # 0;
  vChart->spChartXYDepthGap         # 0;
//  vChart->spChartXYColData          # ColorMake(ColorRgbMake(0,0,255), 230);
  vChart->spChartXYBarGap           # 0.0;
  vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataValue | _ChartDataColor | _ChartDataExtra);
  if (vChartData <=0) then begin
    vChart->ChartClose();
    RETURN;
  end;

  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterX) do begin
    vChartData->ChartDataAdd(vKapa[vI]);

    vY # vWert[vI];
    // Altlast nur im ersten Balken...
    if (vI=1) then
      vY # vY + vAltLast;

    vFrei # vKapa[vI] - vY;
    vText # ' ';
    if (aRasterX<30) then
      if (vFrei>0.0) then
        vText # aNum(vFrei,1);

    // Heute?
    if (vI=vHeute) then
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,205,205), 200), _ChartDataColor)
    else
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,0,255), 230), _ChartDataColor);
    vChartData->ChartDataAdd(vText, _ChartDataExtra);
  END;
  vChartData->ChartDataClose();



  // Bild erstellen...
  vMem # MemAllocate(_MemAutoSize);
  vChart->ChartSave('', _ChartFormatBmp, vMem);
  aPic->wpMemObjHandle # vMem;

  vChart->ChartClose();

  RekRestore(v170);
end;


//========================================================================
//========================================================================
sub KWJ(
  aKW   : word;
  aJahr : word;
) : int
begin
  RETURN ((aJahr-2000) * 53) + aKW;
end;


//========================================================================
//========================================================================
Sub GraphWoche(
  aMitAltlast   : logic;
  aVonDat       : date;
  aRasterX      : int;
  aSchwelle     : float;
  aPic          : int)
local begin
  Erx           : int;
  vBisDat       : date;
  v170          : int;
  vMaxX, vMaxY  : float;
  vChart        : handle;
  vChartData    : handle;
  vMem          : handle;
  vI,vJ, vX     : int;
  vY, vZ        : float;
  vDat,vDat2    : date;
  vWert         : float[99];
  vKapa         : float[99];
  vFont         : font;
  vAltlast      : float;
  vText         : alpha;
  vFrei         : float;
  vKW,vJahr     : word;
  vToday        : int;
  vCol          : int;
  vVon,vBis     : int;
end;
begin
  if (aVonDat=0.0.0) then RETURN;
  if (aRasterX=0) then aRasterX # 14;

  // diesen Montag errechnen...
  Lib_Berechnungen:KW_aus_Datum(aVonDat, var vKW, var vJahr);
  Lib_Berechnungen:Mo_von_KW(vKW, vJahr, var aVonDat);
  Lib_Berechnungen:KW_aus_Datum(aVonDat, var vKW, var vJahr);
  vVon    # KWJ(vKW, vJahr);
  vBisDat # aVonDat;
  vBisDat->vmDayModify(7 * aRasterX);
  vBis    # vVon + aRasterX;

  Lib_Berechnungen:KW_aus_Datum(today, var vKW, var vJahr);
  vToday  # KWJ(vKW, vJahr);


  // Reservierungen loopen --------------------------------------
  v170 # RekSave(170);
  FOR Erx # RecLink(170,160,10,_recfirst)
  LOOP Erx # RecLink(170,160,10,_recNext)
  WHILE (Erx<=_rLocked) and (Rso.R.Plan.StartDat<vBisDat) do begin

    vDat # Rso.R.Plan.StartDat;
    if (vDat=0.0.0) then CYCLE;

    Lib_Berechnungen:KW_aus_Datum(vDat, var vKW, var vJahr);
    vX # KWJ(vKW, vJahr);

    if (vX<vToday) and (vX<vVon) then begin
      if (aMitAltLast) then
        vAltLast # vAltLast + cnvfi(Rso.R.Dauer) / 60.0;
      CYCLE;
    end;


    vI # (cnvid(vDat) - cnvid(aVonDat)) / 7;// vX - vVon;

    if (vI<=0) then vI # 0;
    if (vI>=0) and (vI<99) then begin
      vWert[vI+1] # vWert[vI+1] + Max(cnvfi(Rso.R.Dauer) / 60.0, cnvfi(cMinDauer)/60.0);
      vMaxY # Max(vWert[vI+1], vMaxY);
    end;
  END;


  // Kapazität addieren ----------------------------------
  vDat # aVonDat;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterX) do begin
    FOR vJ # 1
    LOOP inc(vJ)
    WHILE (vj<=7) do begin
      vY # Rso_Kal_Data:Arbeitszeit(Rso.Gruppe, vDat) / 60.0;
      if (vY>24.0) then vY # 24.0;  // max 24h
      vKapa[vI] # vKapa[vI] + vY;
      vMaxY # Max(vMaxY, vKapa[vI]);
      vDat->vmDayModify(1);
    END;
  END;


  vMaxX # 1000.0;
  vMaxY # Max(480.0, vMaxY);

  vChart # ChartOpen(_ChartXY, cnvif(vMaxX), cnvif(vMaxY));//, '', _ChartOptDefault);
  if (vChart <= 0) then begin
    RekRestore(v170);
    RETURN;
  end;


  vChart->spChartXYStyleData        # _ChartXYStyleDataBar;//_ChartXYStyleDataLine;
  vChart->spChartArea               # RectMake(40, 20, cnvif(vMaxX)-5, cnvif(vMaxY)-60);
  vChart->spChartBorderWidth        # 0;
  vChart->spChartColBkg             # ColorMake(ColorRgbMake(240, 240, 255), 0);
  vChart->spChartXYAxisTitleAlignY  # _ChartAlignLeft;
  vChart->spChartXYBarShading       # _ChartXYBarShadingGradientTop;
  vChart->spChartXYColBkg           # ColorMake(ColorRgbMake(232, 232, 255), 0);
  vChart->spChartXYColBkgAlt        # ColorMake(ColorRgbMake(216, 216, 255), 0);
  vChart->spChartXYColBorder        # ColorMake(ColorRgbMake(128, 0, 128), 0);
  vChart->spChartXYColData          # ColorMake(ColorRgbMake(128, 0, 128), 64);
  vChart->spChartXYDepth            # 0;
  vChart->spChartXYDepthGap         # 0;
  vChart->spChartXYLabelColData     # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartXYLabelColSum      # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDefault;
  vChart->spChartXYLabelAngleX      # 90.0;
  vChart->spChartXYTitleAlignY      # _ChartAlignLeft;
  vChart->spChartXYBarGap           # 0.3;
  vChart->spChartXYMinTickIncY      # 2.00;

  vFont # vChart->spChartXYLabelFontX;
  vFont:Size # 120;
  vChart->spChartXYLabelFontX       # vFont;
  vChart->spChartXYLabelFontY       # vFont;
  vChart->spChartXYTitleFontY       # vFont;
  vChart->spChartXYTitleFontX       # vFont;


  // ALTLAST -------------------------------------------------------------------------------------------------------
  if (vAltLast<>0.0) then begin
    vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataColor);
    if (vChartData <=0) then begin
      vChart->ChartClose();
      RekRestore(v170);
      RETURN;
    end;

    vChartData->ChartDataAdd(vAltLast);
    vChartData->ChartDataAdd( ColorMake(ColorRgbMake(64, 64, 64), 100), _ChartDataColor);
//    vChartData->ChartDataAdd(aint(aVnnDat->vpDay)+'.'+aint(aVonDat->vpMonth), _ChartDataLabel);
//    _Draw(vChartData, aVonDat, vAltLast, ColorMake(ColorRgbMake(64, 64, 64), 100));

    vChartData->ChartDataClose();
  end;


  // BELEGUNG ------------------------------------------------------------------------------------------------------
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDataExtra;
  vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataLabel | _ChartDataColor | _ChartDataExtra);
  if (vChartData <=0) then begin
    vChart->ChartClose();
    RekRestore(v170);
    RETURN;
  end;

  vDat # aVonDat;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterX) do begin

    vY # vWert[vI];
    // Altlast nur im ersten Balken...
    if (vI=1) then
      vY # vY + vAltLast;

    vFrei # vKapa[vI] - vY;
    vText # ' ';
    if (aRasterX<30) then
      if (vFrei<0.0) then
        vText # aNum(-vFrei,1);

    if (vKapa[vI]<>0.0) then
      vZ # vY / vKapa[vI]
    else
      vZ # 999.0;

    if (vZ<aSchwelle / 100.0) then
      vCol # ColorRgbMake(64, 255, 64)      // GRÜN
    else if (vZ<=1.0) then
      vCol # ColorRgbMake(255, 255, 00)     // GELB
    else
      vCol #ColorRgbMake(255, 64, 64);      // ROT
    vChartData->ChartDataAdd(vY);
    vChartData->ChartDataAdd( ColorMake(vCol, 100), _ChartDataColor);
//    vChartData->ChartDataAdd(aint(vDat->vpDay)+'.'+aint(vDat->vpMonth), _ChartDataLabel);
    Lib_Berechnungen:KW_aus_Datum(vDat, var vKW, var vJahr);
    vChartData->ChartDataAdd(aint(vKW)+'/'+cnvai(vJahr-2000, _fmtNumleadzero,0,2), _ChartDataLabel);
    vChartData->ChartDataAdd(vText, _ChartDataExtra);

    vDat->vmDayModify(7);
  END;
  vChartData->ChartDataClose();


  // KAPAZITÄT -----------------------------------------------------------------------------------------------------
  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDataExtra;
  vChart->spChartXYBarShading       # _ChartXYBarShadingDefault;
  vChart->spChartXYDepth            # 0;
  vChart->spChartXYDepthGap         # 0;
  vChart->spChartXYBarGap           # 0.0;
  vChartData # vChart->ChartDataOpen(aRasterX, _ChartDataValue | _ChartDataColor | _ChartDataExtra);
  if (vChartData <=0) then begin
    vChart->ChartClose();
    RekRestore(v170);
    RETURN;
  end;

  vJ # vVon;
  FOR vI # 1
  LOOP inc(vI)
  WHILE (vI<=aRasterX) do begin
    vChartData->ChartDataAdd(vKapa[vI]);

    vY # vWert[vI];
    // Altlast nur im ersten Balken...
    if (vI=1) then
      vY # vY + vAltLast;

    vFrei # vKapa[vI] - vY;
    vText # ' ';
    if (aRasterX<30) then
      if (vFrei>0.0) then
        vText # aNum(vFrei,1);

    // Heute?
    if (vJ=vToday) then
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,205,205), 200), _ChartDataColor)
    else
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,0,255), 230), _ChartDataColor);
    vChartData->ChartDataAdd(vText, _ChartDataExtra);

    inc(vJ);
  END;
  vChartData->ChartDataClose();



  // Bild erstellen...
  vMem # MemAllocate(_MemAutoSize);
  vChart->ChartSave('', _ChartFormatBmp, vMem);
  aPic->wpMemObjHandle # vMem;

  vChart->ChartClose();

  RekRestore(v170);
end;


//========================================================================
//  sub Setup(...)
//    Ermöglicht zentralisiertes Setup für den Aufruf
//
//    Argumente:
//      aTyp          : alpha;    (KW|D)
//      aDatum          : date;
//    opt aRaster         : int;
//    opt aSchwellenwert : int;
//    opt aAltlast : logic;
//
//========================================================================
sub Setup(
  aTyp                : alpha;
  aDatum              : date;
  opt aRaster         : int;
  opt aSchwellenwert  : int;
  opt aAltlast        : logic; )
begin
  case StrCnv(aTyp, _StrUpper) of
    'KW'  : begin
        $cbTage->wpCheckState   # _WinStateChkUnchecked;
        $cbWoche->wpCheckState  # _WinStateChkChecked;
      end;
    'D' :  begin
        $cbTage->wpCheckState   # _WinStateChkChecked;
        $cbWoche->wpCheckState  # _WinStateChkUnchecked;
      end;
  end;

  cStartDatum # aDatum;

  if (aRaster > 0) then
    cRaster # aRaster;

  if (aSchwellenwert > 0) then
    cSchwelle # aSchwellenwert;

  if (aAltlast) then
    $cbAltlast->wpCheckState   # _WinStateChkChecked;
  else
    $cbAltlast->wpCheckState   # _WinStateChkUnchecked;

end;



//========================================================================