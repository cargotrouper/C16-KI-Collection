@A+
//===== Business-Control =================================================
//
//  Prozedur    Mdi_Con_Graph
//                  OHNE E_R_G
//  Info
//
//
//  05.11.2019  AH  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//
//========================================================================
@I:Def_Global

define begin
  cChart1 : 'Menge: akt.Jahresentwicklung'
  cChart2 : 'Menge: Summe Vorjahr zu akt. Jahr'
  cChart3 : 'Menge: 5 Jahresvergleich'

  cChart4 : 'Umsatz: akt.Jahresentwicklung'
  cChart5 : 'Umsatz: Summe Vorjahr zu akt. Jahr'
  cChart6 : 'Umsatz: 5 Jahresvergleich'

  cChart7 : 'DB: akt.Jahresentwicklung'
  cChart8 : 'DB: Summe Vorjahr zu akt. Jahr'
  cChart9 : 'DB: 5 Jahresvergleich'
end;


//========================================================================
//========================================================================
sub FillLayouts(
  aDataList             : handle  // Handle auf DataList
)
local begin
  tFile               : int;    // Datei
end
begin
  if (aDatalist=0) then RETURN;

  aDataList->wpAutoUpdate # false;
  aDataList->WinLstDatLineRemove(_WinLstDatLineAll);

  aDataList->WinLstDatLineAdd(cChart1);
  aDataList->WinLstDatLineAdd(cChart2);
  aDataList->WinLstDatLineAdd(cChart3);
  aDataList->WinLstDatLineAdd(cChart4);
  aDataList->WinLstDatLineAdd(cChart5);
  aDataList->WinLstDatLineAdd(cChart6);
  aDataList->WinLstDatLineAdd(cChart7);
  aDataList->WinLstDatLineAdd(cChart8);
  aDataList->WinLstDatLineAdd(cChart9);

  aDataList->wpCurrentInt # 1;
  aDataList->wpAutoUpdate # true;
end;


//========================================================================
sub _ReadJahr(
  aJahr : int) : int;
local begin
  Erx   : int;
  vBuf  : int;
end;
begin
  vBuf # RecbufCreate(950);
  RecbufCopy(950, vBuf);
  vBuf->Con.Jahr # aJahr;
  Erx # RecRead(vBuf,1,0);
  if (Erx>_rLocked) then RecBufClear(vBuf);
  RETURN vBuf;
end;


//========================================================================
sub _GetLabel(
  aTyp        : alpha;
  var aTds    : int;
  var aLabel  : alpha)
begin
  if (aTyp='MENGE') then begin
    aLabel # 'Menge';
    aTds # 3; // MENGE
  end
  else if (aTyp='UMSATZ') then begin
    aLabel # 'Umsatz';
    aTds # 6; // UMSATZ
  end
  else begin
    aLabel # 'DB';
    aTds # 12; // DB
  end;
end;


//========================================================================
sub Tacho(
  aPara     : alpha;
  aGauge    : int;
  opt aTyp  : alpha;)
local begin
  vBuf1   : int;
  vBuf    : int;
  vTyp    : alpha;
  vF      : float;
  vTds    : int;
  vA      : alpha;
  vLJ,vVJ : float;
end
begin

  vBuf1 # cnvia(Str_Token(aPara,'|',1));
  vTyp  # Str_Token(aPara,'|',2);
  if (aTyp<>'') then vTyp # aTyp;
  vTyp # StrCnv(vTyp,_StrUpper);
 
  RecRead(vBuf1,1,0);
  RecBufCopy(vBuf1, 950);
  
  _GetLabel(vTyp, var vTds, var vA);

  vBuf # _ReadJahr(Con.Jahr - 1);
  vVJ # FldFloat(vBuf, vTds, 13);
  RecBufDestroy(vBuf);

  vBuf # _ReadJahr(Con.Jahr);
  vLJ # FldFloat(vBuf, vTds, 13);
  RecBufDestroy(vBuf);

  vF # Lib_Berechnungen:Prozent(vLJ, vVJ);

  vA # anum(vLJ,2)+' / '+anum(vVJ,2);

  Lib_Gauge:UpdateGaugeRaw(aGauge, vA, vF, anum(vF,1)+'%');
end;


//========================================================================
sub Chart_5Jahre(
  aPara     : alpha;
  aPic      : int;
  opt aTyp  : alpha)
local begin
  vBuf1       : int;
  vTyp        : alpha;
  vMaxX       : float;
  vMaxY       : float;
  vMaxBars    : int;
  vLabelX     : alpha;
  vLabelY     : alpha;

  vChart      : int;
  vChartData  : int;
  vFont       : font;
  vJahr       : int;
  vMon        : int;
  vMem        : int;
  vTds        : int;
  vF          : float;
  vBuf        : int;
end;
begin

  vBuf1 # cnvia(Str_Token(aPara,'|',1));
  vTyp  # Str_Token(aPara,'|',2);
  if (aTyp<>'') then vTyp # aTyp;
  vTyp # StrCnv(vTyp,_StrUpper);
  
  RecRead(vBuf1,1,0);
  RecBufCopy(vBuf1, 950);

  vMaxBars  # 12 * 5;
  
  vLabelX # 'Monat';
  _GetLabel(vTyp, var vTds, var vLabelY);
  
  vMaxX # 1000.0;
  vMaxY # Max(480.0, vMaxY);

  // -----------------------------------------------------------------------------------
  vChart # ChartOpen(_ChartXY, cnvif(vMaxX), cnvif(vMaxY));//, 'Titel', _ChartOptDefault);
  if (vChart <= 0) then RETURN;

//  vChart->spChartArea        # RectMake(60, 50, 380, 350);
  vChart->spChartColBorder      # ColorMake(ColorRgbMake(0, 0, 128), 0);
  vChart->spChartArea           # RectMake(50, 20, cnvif(vMaxX)-5, cnvif(vMaxY)-50);

  vChart->spChartTitleArea      # RectMake(0, 0, 450, 0);
  vChart->spChartTitleColBkg    # ColorMake(ColorRgbMake(0, 0, 0), 0);
  vChart->spChartTitleColFg     # ColorMake(ColorRgbMake(255, 255, 255), 0);
  vChart->spChartXYColBkg       # ColorMake(ColorRgbMake(0, 64, 128), 0);
  vChart->spChartXYColBkgAlt    # ColorMake(ColorRgbMake(0, 32, 96), 0);
  vChart->spChartXYColBorder    # ColorMake(ColorRgbMake(255, 255, 255), 32);
  vChart->spChartXYColData      # ColorMake(ColorRgbMake(255, 255, 255), 128);
  vChart->spChartXYDepth        # 10;
  vChart->spChartXYStyleData    # _ChartXYStyleDataArea;
  vChart->spChartXYTitleX       # vLabelX;
  vChart->spChartXYTitleY       # vLabelY;
  vChart->spChartXYLabelAngleX  # 20.0;

  vChartData # vChart->ChartDataOpen(vMaxBars, _ChartDataValue | _ChartDataColor | _ChartDataLabel);

  if (vChartData <=0) then begin
    vChart->ChartClose();
    RETURN;
  end;

  FOR vJahr # -4
  LOOP inc(vJahr)
  WHILE (vJahr<=0) do begin
    vBuf # _ReadJahr(Con.Jahr + vJahr);
    FOR vMon # 1
    LOOP inc(vMon)
    WHILE (vMon<=12) do begin
      vF # FldFloat(vBuf, vTds, vMon);
//vF # 5000.0 + (Random() * 100.0) + (cnvfi(vJahr) * 1000.0) + (cnvfi(vMon) * 100.0);
      vChartData->ChartDataAdd(vF);
      vChartData->ChartDataAdd(ColorMake(ColorRgbMake(0,205,205), 200), _ChartDataColor)
      if (vMon=1) or (vMon=7) then
        vChartData->ChartDataAdd(aint(vMon)+'/'+aint(Con.Jahr + vJahr), _ChartDataLabel)
      else
        vChartData->ChartDataAdd(' ', _ChartDataLabel);
    END;
    RecBufDestroy(vBuf);
  END;
  
  vChartData->ChartDataClose();


  // Bild erstellen...
  vMem # MemAllocate(_MemAutoSize);
  vChart->ChartSave('', _ChartFormatBmp, vMem);
  aPic->wpMemObjHandle # vMem;

  vChart->ChartClose();

end;


//========================================================================
sub Chart_12Monate(
  aPara     : alpha;
  aPic      : int;
  opt aTyp  : alpha)
local begin
  vBuf1       : int;
  vTyp        : alpha;
  vMaxX       : float;
  vMaxY       : float;
  vLabelX     : alpha;
  vLabelY     : alpha;
  
  vMaxBars    : int;
  vChart      : int;
  vChartData  : int;
  vFont       : font;
  vMon        : int;
  vMem        : int;
  vTds        : int;
  vF          : float;
end;
begin

  vBuf1 # cnvia(Str_Token(aPara,'|',1));
  vTyp  # Str_Token(aPara,'|',2);
  if (aTyp<>'') then vTyp # aTyp;
  vTyp # StrCnv(vTyp,_StrUpper);
  
  RecRead(vBuf1,1,0);
  RecBufCopy(vBuf1, 950);

  vMaxBars  # 12;

  vLabelX # '';
  _GetLabel(vTyp, var vTds, var vLabelY);

  vMaxX # 1000.0;
  vMaxY # Max(480.0, vMaxY);


  vChart # ChartOpen(_ChartXY, cnvif(vMaxX), cnvif(vMaxY));//, '', _ChartOptDefault);
  if (vChart <= 0) then RETURN;

  vChart->spChartXYStyleData        # _ChartXYStyleDataBar;//_ChartXYStyleDataLine;
//  vChart->spChartXYStyleData       # _ChartXYStyleDataBar | _ChartXYStyleDataStack;
  vChart->spChartArea               # RectMake(70, 20, cnvif(vMaxX)-5, cnvif(vMaxY)-50);
  vChart->spChartBorderWidth        # 0;
  vChart->spChartColBkg             # ColorMake(ColorRgbMake(240, 240, 255), 0);
  vChart->spChartXYAxisTitleAlignY  # _ChartAlignLeft;
/***
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
  vChart->spChartXYLabelAngleX      # 45.0;
  vChart->spChartXYTitleAlignY      # _ChartAlignLeft;
  vChart->spChartXYBarGap           # 0.3;
  vChart->spChartXYMinTickIncY      # 2.00;
***/
  vChart->spChartXYBarShading # _ChartXYBarShadingGradientBottom;
  vChart->spChartXYColBkg     # ColorMake(ColorRgbMake(255, 255, 255), 0);
  vChart->spChartXYColBkgAlt  # ColorMake(ColorRgbMake(255, 255, 255), 0);
  vChart->spChartXYColBorder  # ColorMake(ColorRgbMake(255, 255, 255), 160);
  vChart->spChartXYColData    # ColorMake(ColorRgbMake(192, 192, 192), 128);
  vChart->spChartXYDepth      # 10;
  vChart->spChartXYStyleData  # _ChartXYStyleDataBar;
    
  vChart->spChartXYTitleX          # vLabelX;
  vChart->spChartXYTitleY          # vLabelY;
/**
  vFont # vChart->spChartXYLabelFontX;
  vFont:Size # 120;
  vChart->spChartXYLabelFontX       # vFont;
  vChart->spChartXYLabelFontY       # vFont;
  vChart->spChartXYTitleFontY       # vFont;
  vChart->spChartXYTitleFontX       # vFont;
  vChart->spChartXYDepth            # 0;
  vChart->spChartXYDepthGap         # 0;
  vChart->spChartXYBarGap           # 0.0;
  vChart->spChartXYBarShading       # _ChartXYBarShadingDefault;
**/

  vChart->spChartXYStyleLabel       # _ChartXYStyleLabelDataExtra;
  vChartData # vChart->ChartDataOpen(vMaxBars, _ChartDataValue | _ChartDataColor | _ChartDataExtra | _ChartDataLabel);
  if (vChartData <=0) then begin
    vChart->ChartClose();
    RETURN;
  end;

  FOR vMon # 1
  LOOP inc(vMon)
  WHILE (vMon<=12) do begin
    vF # FldFloat(950, vTds, vMon);
//vF # 5000.0 + (Random() * 100.0) + (cnvfi(vMon) * 100.0);
    vChartData->ChartDataAdd(vF);
    vChartData->ChartDataAdd(ColorMake(ColorRgbMake(119,106,236), 31), _ChartDataColor)
    vChartData->ChartDataAdd(anum(vF,2), _ChartDataExtra);
    vChartData->ChartDataAdd(StrCut(Lib_Berechnungen:Monat_aus_Datum(datemake(1,vMon, Con.Jahr)),1,3) , _ChartDataLabel);
  END;
  vChartData->ChartDataClose();


  // Bild erstellen...
  vMem # MemAllocate(_MemAutoSize);
  vChart->ChartSave('', _ChartFormatBmp, vMem);
  aPic->wpMemObjHandle # vMem;

  vChart->ChartClose();

end;


//========================================================================
//
//
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
) : logic;
local begin
  vHdl  : int;
end;
begin
  FillLayouts(Winsearch(aEvt:obj, 'dlLayouts'));

  App_Main:EvtInit(aEvt);
  if (w_Obj2Scale<>0) then w_obj2Scale->CteClear(true);

  RETURN(true);
end;


//========================================================================
sub EvtPosChanged(
  aEvt                  : event;        // Ereignis
  aRect                 : rect;         // Größe des Fensters
  aClientSize           : point;        // Größe des Client-Bereichs
  aFlags                : int;          // Aktion
) : logic;
begin
  $popupLayouts->wpAreawidth # $Layout->wpAreaWidth;
  RETURN(true);
end;


//========================================================================
sub Refresh(
  aMDI  : int)
local begin
  vPara   : alpha;
  vHdl    : int;
  vHdl2   : int;
  vPic    : int;
  vGauge  : int;
end;
begin
//with wfewe $:wriogfj->wpcaption # 'asd';
  vHdl  # Winsearch(aMDI, 'lbPara');
  vPara # vHdl->wpCustom;
  if (vPara='') then RETURN;

  vPic    # Winsearch(aMDI, 'pic');
  vGauge  # Winsearch(aMDI, 'gbGauge');
    
  vHdl2 # Winsearch(aMDI, 'Layout');
  if (vHdl2->wpCaption=cChart1) or
    (vHdl2->wpCaption=cChart4) or
    (vHdl2->wpCaption=cChart7) then begin
    vPic->wpvisible   # true;
    vGauge->wpvisible # false;
    Chart_12Monate(vPara, vPic, Str_Token(vHdl2->wpCaption,':',1));
  end
  else if (vHdl2->wpCaption=cChart3) or
    (vHdl2->wpCaption=cChart6) or
    (vHdl2->wpCaption=cChart9) then begin
    vPic->wpvisible   # true;
    vGauge->wpvisible # false;
    Chart_5Jahre(vPara, vPic, Str_Token(vHdl2->wpCaption,':',1));
  end
  else begin
    vPic->wpvisible   # false;
    vGauge->wpvisible # true;
    Tacho(vHdl->wpcustom, vGauge, Str_Token(vHdl2->wpCaption,':',1));
  end;
end;


//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
) : logic;
begin
  Refresh(WinInfo(aEvt:obj, _winFrame));
  RETURN(true);
end;


//========================================================================
sub SpawnGraph(
  aBuf1     : int;
  aTyp      : alpha)
local begin
  vMDI    : int;
  vHdl    : int;
end;
begin
  vMDI # WinAddByName(gFrmMain, Lib_GuiCom:GetAlternativeName('Mdi.Con.Graph'), _WinAddHidden);
  vMDI->wpCaption # (aBuf1->Con.Bezeichnung)+' '+aint(aBuf1->Con.Jahr);
  vHdl # Winsearch(vMDI, 'lbPara');
  vHdl->wpcustom # aint(aBuf1)+'|'+StrCnv(aTyp,_StrUpper);
  Refresh(vMDI);
  
  lib_guicom2:SetMdiAsChild(vMDI, gMDI);
  vMDI->WinUpdate(_WinUpdOn);
end;

//========================================================================