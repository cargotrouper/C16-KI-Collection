@A+
//===== Business-Control =================================================
//
//  Prozedur  Lib_Gauge
//                    OHNE E_R_G
//  Info
//
//
//  04.08.2014  AH  Erstellung der Prozedur
//
//  Subprozeduren
//d
//========================================================================
@I:Def_Global
@I:Def_Rights

//@Define Zufall

define begin
  Proz(a,b) : Lib_Berechnungen:Prozent(a, b)
  Dezi(a)   : cnvaf(a,0,0,0)
end;

//========================================================================
// GetWerte
//========================================================================
Sub GetWerte(
  aTyp      : alpha;
  var aText : alpha;
  var aF    : float);
local begin
  vMon      : int;
  vJahr     : int;
  vDat      : date;
  vTim      : time;
  vF,vF2    : float;
  vBuf      : int;
end;
begin

  vDat  # today;
  vMon  # vDat->vpmonth;
  vJahr # vDat->vpyear;

  case aTyp of

    // AUF_EINGANG -------------------------------------------------------------------------
    'MonAufEingang+ArZuVJ:Wert', 'MonAufEingangZuVJ:Wert' :  begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'AUF_EINGANG','');
      vF # OSt.E.BetragW1;
      if (aTyp='MonAufEingang+ArZuVJ:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr, 'AUF_AR_EINGANG','');
        vF # vF + OSt.E.BetragW1;
      end;
      Ost_Data:HoleExtend('M', vMon , vJahr-1, 'AUF_EINGANG','');
      vF2 # OSt.E.BetragW1;
      if (aTyp='MonAufEingang+ArZuVJ:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr-1, 'AUF_AR_EINGANG','');
        vF2 # vF2 + OSt.E.BetragW1;
      end;
@Ifdef Zufall
vF # Random() * vF2;
@endif

      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Auftrag]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;

    'MonAufEingang+ArZuCon:Wert', 'MonAufEingangZuVJ:Wert' :  begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'AUF_EINGANG','');
      vF # OSt.E.BetragW1;
      if (aTyp='MonAufEingang+ArZuCon:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr, 'AUF_AR_EINGANG','');
        vF # vF + OSt.E.BetragW1;
      end;

      vBuf # RekSave(950);
      Con_Data:Read('A',2014,0,0,0,0,0,'');
      vF2 # FldFloat(950,5,vMon);
      RekRestore(vBuf);
@Ifdef Zufall
vF # Random() * vF2;
@endif

      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Auftrag]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;



    'MonAufEingangZuVJ:Pro' : begin
      Ost_Data:HoleExtend('M', vMOn , vJahr, 'AUF_EINGANG','');
      if (OSt.E.Satzanzahl<>0) then
        vF # OSt.E.BetragW1 / cnvfi(OSt.E.Satzanzahl);
      Ost_Data:HoleExtend('M', vMOn , vJahr-1, 'AUF_EINGANG','');
      if (OSt.E.Satzanzahl<>0) then
        vF2 # OSt.E.BetragW1 / cnvfi(OSt.E.Satzanzahl);
      vF # Proz(vF, vF2);
      aText # anum(vF, 2)+'%';
    end;

    // BEST_EINGANG -------------------------------------------------------------------------
    'MonBestEingang+ArZuVJ:Wert', 'MonBestEingangZuVJ:Wert' : begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'BEST_EINGANG','');
      vF # OSt.E.BetragW1;
      if (aTyp='MonBestEingang+ArZuVJ:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr, 'BEST_AR_EINGANG','');
        vF # vF + OSt.E.BetragW1;
      end;

      Ost_Data:HoleExtend('M', vMon , vJahr-1, 'BEST_EINGANG','');
      vF2 # OSt.E.BetragW1;
      if (aTyp='MonAufEingang+ArZuVJ:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr-1, 'BEST_AR_EINGANG','');
        vF2 # vF2 + OSt.E.BetragW1;
      end;
@Ifdef Zufall
vF # Random() * vF2;
@endif
      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Einkauf]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;

    'MonBestEingang+ArZuCon:Wert', 'MonBestEingangZuCon:Wert' : begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'BEST_EINGANG','');
      vF # OSt.E.BetragW1;
      if (aTyp='MonBestEingang+ArZuCon:Wert') then begin
        Ost_Data:HoleExtend('M', vMon , vJahr, 'BEST_AR_EINGANG','');
        vF # vF + OSt.E.BetragW1;
      end;

      vBuf # RekSave(950);
      Con_Data:Read('E',2014,0,0,0,0,0,'');
      vF2 # FldFloat(950,5,vMon);
      RekRestore(vBuf);
@Ifdef Zufall
vF # Random() * vF2;
@endif

      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Einkauf]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;

    'MonBestEingangZuVJ:Pro' : begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'BEST_EINGANG','');
      if (OSt.E.Satzanzahl<>0) then
        vF # OSt.E.BetragW1 / cnvfi(OSt.E.Satzanzahl);
      Ost_Data:HoleExtend('M', vMon , vJahr-1, 'BEST_EINGANG','');
      if (OSt.E.Satzanzahl<>0) then
        vF2 # OSt.E.BetragW1 / cnvfi(OSt.E.Satzanzahl);
      vF # Proz(vF, vF2);
      aText # anum(vF, 2)+'%';
    end;

    // ERLÖS -------------------------------------------------------------------------
    'MonErloesZuVJ:Wert' : begin
/**
      OsT_Data:Hole('UNTERNEHMEN',vMon,vJahr);
      vF # Ost.VK.Wert;
      OsT_Data:Hole('UNTERNEHMEN',vMon,vJahr-1);
      vF2 # Ost.Vk.Wert;
**/
      Ost_Data:HoleExtend('M', vMon , vJahr, 'ERLOES','');
      vF # OSt.E.BetragW1;

      Ost_Data:HoleExtend('M', vMon , vJahr-1, 'ERLOES','');
      vF2 # OSt.E.BetragW1;
/**/
@Ifdef Zufall
vF # Random() * vF2;
@endif
      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Erloese]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';

    end;

    'MonErloesZuCon:Wert' : begin
//    SUB Read(aTyp : alpha; aJahr : int; aAdr : int; aVert : int; aAufArt : int; aWGr : int; aAGr : int; aArtNr : alpha) : int
      Ost_Data:HoleExtend('M', vMon , vJahr, 'DB1','');
      vF # OSt.E.BetragW1;

      vBuf # RekSave(950);
      Con_Data:Read('',2014,0,0,0,0,0,'');
      vF2 # FldFloat(950,5,vMon);
      RekRestore(vBuf);
@Ifdef Zufall
vF # Random() * vF2;
@endif

      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Erloese]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;

    'MonErloesZuVJ:DB' : begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'DB1','');
      vF # OSt.E.BetragW1;
      Ost_Data:HoleExtend('M', vMon , vJahr-1, 'DB1','');
      vF2 # OSt.E.BetragW1;;
@Ifdef Zufall
vF # Random() * vF2;
@endif

      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Erloese]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;

    'MonErloesZuCon:DB' : begin
      Ost_Data:HoleExtend('M', vMon , vJahr, 'DB1','');
      vF # OSt.E.BetragW1;

      vBuf # RekSave(950);
      Con_Data:Read('',2014,0,0,0,0,0,'');
      vF2 # FldFloat(950,11,vMon);
      RekRestore(vBuf);
@Ifdef Zufall
vF # Random() * vF2;
@endif
      aF # Proz(vF, vF2);

      if (Rechte[Rgt_Erloese]) then
        aText # Dezi(vF)+' / '+Dezi(vF2)
      else
        aText # anum(aF, 2)+'%';
    end;


    // TEST ----------------------------------------------------------------------------
    'Zeit' : begin
      vTim  # now;
      vF # cnvfi(vTim->vpSeconds);
      aF # (vF / 60.0) * 100.0;
      aText # cnvat(now, _FmtTimeSeconds);
    end;

    'ZeitInvers' : begin
      vTim  # now;
      vF # cnvfi(vTim->vpSeconds);
      aF # 100.0 - ((vF / 60.0) * 100.0);
      aText # cnvat(now, _FmtTimeSeconds);
    end;

    otherwise aTyp # 'RND';

  end; // case

  if (aTyp='RND') then begin
    aF # rnd(random()*100.0 ,0)
    aText # 'Zufall '+anum(aF,0)+'%';
  end;


end;


//========================================================================
//========================================================================
sub MoveNeedle(
  aNeedle : int;
  aZiel   : int;
  aStep   : int);
local begin
  vDif    : int;
  vI      : int;
  vF      : float;
end;
begin

  vDif # aZiel - aNeedle->wprotation;
//debugx('step:'+aint(aStep)+'   soll:'+aint(aZiel)+'  ist:'+aint(aNeedle->wprotation)+'  Dif:'+aint(vDif));
  if (vDif=0) then RETURN;

  if (aStep>=12) or (vDif=1) then begin
    aNeedle->wprotation # aZiel;
    RETURN;
  end;

  vI # vDif / (12 - aStep);

  aNeedle->wprotation # aNeedle->wprotation + vI
  aNeedle->wprotation # aNeedle->wprotation + vI

end;


//========================================================================
//========================================================================
sub UpdateGauge(
  aObj      : int);
local begin
  vNeedle   : int;
  vLabel    : int;
  vI        : int;
  vF        : float;
  vA        : alpha;
end;
begin

  vNeedle # Winsearch(aObj, 'Needle');
  vLabel  # Winsearch(aObj, 'Label');

  GetWerte(aObj->wpcustom, var vA, var vF);
  vNeedle->wprotation # cnvif(360.0 * vF / 100.0)
  vLabel->wpcaption # vA;

end;


//========================================================================
//  120% = 180°
//========================================================================
sub UpdateGaugeRaw(
  aObj      : int;
  aLabel    : alpha;
  aF        : float;
  opt aLab2 : alpha);
local begin
  vPic      : int;
  vNeedle   : int;
  vShadow   : int;
  vLabel    : int;
  vI        : int;
  vA        : alpha;
  vRect     : rect;
end;
begin

  vPic    # Winsearch(aObj, 'Gauge');
  vNeedle # Winsearch(aObj, 'Needle');
  vShadow # Winsearch(aObj, 'NeedleShadow');
  vLabel  # Winsearch(aObj, 'Label');

  vLabel->wpcaption # aLabel;
  
  if (aLab2<>'') then begin
    vLabel  # Winsearch(aObj, 'Label2');
    vLabel->wpcaption # aLab2;
    vRect # vLabel->wpArea;
    vI # vRect:right - vRect:Left;
    vI # vI / 2;
    vRect:left # 112 - vI;
    vRect:Right # vRect:Left + (vI*2) + 1;
    vLabel->wpArea # vRect;
    vLabel->wpVisible # true;
  end;
  
  vI # cnvif(144.0 * aF / 100.0);
  if (vI>181) then vI # 181;    // Maximum
  if (vI<0) then vI # 0;
  aObj->wpHelptip # aint(vI - 45);
  vI # cnvia(aObj->wpHelptip);

  vPic->wpAutoUpdate # false;
  MoveNeedle(vNeedle, vI, 100);
  MoveNeedle(vShadow, vI, 100);
  vPic->wpAutoUpdate # true;
end;


//========================================================================
sub UpdateGauge2(
  aObj      : int;
  aStep     : int);
local begin
  vPic      : int;
  vNeedle   : int;
  vShadow   : int;
  vLabel    : int;
  vI        : int;
  vF        : float;
  vA        : alpha;
end;
begin

  vPic    # Winsearch(aObj, 'Gauge');
  vNeedle # Winsearch(aObj, 'Needle');
  vShadow # Winsearch(aObj, 'NeedleShadow');
  vLabel  # Winsearch(aObj, 'Label');

  if (aStep=1) then begin
    GetWerte(aObj->wpcustom, var vA, var vF);

//vF # (vF * 0.5) + 50.0;
    vLabel->wpcaption # vA;

    vI # cnvif(144.0 * vF / 100.0);
    if (vI>181) then vI # 181;    // Maximum
    if (vI<0) then vI # 0;

    aObj->wpHelptip # aint(vI - 45);
  end;

  vI # cnvia(aObj->wpHelptip);

  vPic->wpAutoUpdate # false;
  MoveNeedle(vNeedle, vI, aStep);
  MoveNeedle(vShadow, vI, aStep);
  vPic->wpAutoUpdate # true;//  if (vShadow<>0) then
//    vShadow->wprotation # vI-45;
//  vNeedle->wprotation # vI-45;
end;


//========================================================================
//========================================================================
sub UpdateProgress(
  aObj      : int);
local begin
  vProgress : int;
  vLabel    : int;
  vI        : int;
  vF        : float;
  vA        : alpha;
end;
begin

  vProgress # Winsearch(aObj, 'Progress');
  vLabel    # Winsearch(aObj, 'Label');

  GetWerte(aObj->wpcustom, var vA, var vF);
  vProgress->wpprogresspos  # cnvif(vF);
  vLabel->wpcaption         # vA;// + '/'+anum(vF,0);

end;


//========================================================================
//========================================================================
sub UpdateAmpel(
  aObj      : int);
local begin
  vP1,vP2,vP3 : int;
  vLabel      : int;
  vI          : int;
  vF          : float;
  vA          : alpha;
end;
begin

  vP1       # Winsearch(aObj, 'Pic1');
  vP2       # Winsearch(aObj, 'Pic2');
  vP3       # Winsearch(aObj, 'Pic3');
  vLabel    # Winsearch(aObj, 'Label');

  GetWerte(aObj->wpcustom, var vA, var vF);
  vLabel->wpcaption         # vA;// + '/'+anum(vF,0);

  vP1->wpvisible # vF<33.0;
  vP2->wpvisible # (vF>=33.0) and (vF<66.0);
  vP3->wpvisible # vF>=66.0;

end;


//========================================================================
// 166% = 5/5
//========================================================================
sub UpdateBar(
  aObj      : int);
local begin
  vNeedle     : int;
  vLabel      : int;
  vI          : int;
  vF          : float;
  vA          : alpha;
end;
begin

  vNeedle   # Winsearch(aObj, 'Needle');
  vLabel    # Winsearch(aObj, 'Label');

  GetWerte(aObj->wpcustom, var vA, var vF);
  vLabel->wpcaption         # vA+'  ('+anum(vF,0)+'%)';

  if (vF>166.0) then vF # 166.0;    // Maximum
  vI # cnvif(226.0 * vF / 166.0);

  vNeedle->wpArealeft # vI;
  vNeedle->wpArearight # vI+13;

end;


//========================================================================
//========================================================================
Sub UpdateChart(
  aObj  : int;
  aPic  : int);
local begin
  vF          : float;
  vX,vY       : int;
  vDat        : date;
  vMon        : int;
  vMem        : handle;
  tChart      : handle;
  tChartData  : handle;
end;
begin

  vMem # MemAllocate(_MemAutoSize);

  vDat # today;
  vMon # vDat->vpmonth;

  if (aPic=0) then
    aPic  # Winsearch(aObj, 'Picture');
  vX    # aPic->wpAreaRight - aPic->wpAreaLeft;
  vY    # aPic->wpAreaBottom - aPic->wpAreaTop;

  tChart # ChartOpen(_ChartXY, vX-2, vY-2, '', _ChartOptDefault);
  if (tChart > 0) then begin
    tChart->spChartArea              # RectMake(25, 10, vX-20, vY-20-20);
//    tChart->spChartTitleArea         # RectMake(0, 0, vX-2, 25);

    tChart->spChartBorderWidth       # 0;
    tChart->spChartColBkg            # ColorMake(ColorRgbMake(255, 255, 255), 0);
    tChart->spChartTitleColBkg       # ColorMake(ColorRgbMake(100, 100, 255), 128);
    tChart->spChartTitleColFg        # ColorMake(_WinColBlack,0);

    tChart->spChartXYBarShading      # _ChartXYBarShadingGradientTop;
    tChart->spChartXYColBkg          # ColorMake(ColorRgbMake(255, 255, 255), 0);
    tChart->spChartXYColBkgAlt       # ColorMake(ColorRgbMake(255, 255, 255), 0);
    tChart->spChartXYColBorder       # ColorMake(ColorRgbMake(0, 0, 255), 0);
    tChart->spChartXYColData         # ColorMake(ColorRgbMake(0, 128, 255), 64);
    tChart->spChartXYColGridX        # ColorMake(ColorRgbMake(232, 232, 232), 0);
    tChart->spChartXYColGridY        # ColorMake(ColorRgbMake(232, 232, 232), 0);
    tChart->spChartXYColTrend        # ColorMake(ColorRgbMake(105, 105, 105), 0);
    tChart->spChartXYDepth           # 0;
    tChart->spChartXYDepthGap        # 0;
    tChart->spChartXYLabelAngleX     # 0.00;
    tChart->spChartXYLineSymbol      # _ChartSymbolCircle;
    tChart->spChartXYLineSymbolParam # 0;
    tChart->spChartXYLineWidth       # 2;
    tChart->spChartXYStyleData       # _ChartXYStyleDataSpline;
    tChart->spChartXYStyleLabel      # _ChartXYStyleLabelDefault;
    tChart->spChartXYTitleX          # 'Monat';
    tChart->spChartXYTitleY          # '';
    tChart->spChartXYTrendType       # _ChartXYTrendTypeExp;

    tChartData # tChart->ChartDataOpen(6, _ChartDataLabel);
    if (tChartData > 0) then begin
      if (aObj->wpcustom='Auf') then begin
        tChartData->ChartDataAdd(85.23);
        tChartData->ChartDataAdd(66.70);
        tChartData->ChartDataAdd(75.14);
        tChartData->ChartDataAdd(82.96);
        vF # (Random()*5.0)+3.0;
        tChartData->ChartDataAdd((vF * 6.0));
        tChartData->ChartDataAdd((vF * 7.0));
      end
      else begin
        tChartData->ChartDataAdd((Random()*80.0));
        tChartData->ChartDataAdd((Random()*80.0));
        tChartData->ChartDataAdd((Random()*80.0));
        tChartData->ChartDataAdd((Random()*80.0));
        tChartData->ChartDataAdd((Random()*80.0));
        tChartData->ChartDataAdd((Random()*80.0));
      end;

      tChartData->ChartDataAdd(aint(vMon-5), _ChartDataLabel);
      tChartData->ChartDataAdd(aint(vMon-4), _ChartDataLabel);
      tChartData->ChartDataAdd(aint(vMon-3), _ChartDataLabel);
      tChartData->ChartDataAdd(aint(vMon-2), _ChartDataLabel);
      tChartData->ChartDataAdd(aint(vMon-1), _ChartDataLabel);
      tChartData->ChartDataAdd(aint(vMon-0), _ChartDataLabel);
      tChartData->ChartDataClose();
    end;

    // Diagramm unter "Eigene Bilder" speichern
//    tChart->ChartSave(_Sys->spPathMyPictures + '\Chart.png', _ChartFormatPNG);
      tChart->ChartSave('', _ChartFormatAuto, vMem);

    // Diagramm schließen
    tChart->ChartClose();
  end;

  aPic->wpMemObjHandle # vMem;

end;


//========================================================================