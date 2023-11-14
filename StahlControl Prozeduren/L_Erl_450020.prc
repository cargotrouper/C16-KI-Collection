@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450020
//                    OHNE E_R_G
//  Info        Umsatzstatistik
//
//
//
//  11.05.2012  MS  Erstellung der Prozedur
//  30.09.2016  TM  Spaltenbreiten angepasst siehe 1482/75
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Aktionen

declare StartList(aSort : int; aSortName : alpha);

global Struct_VM_Wgr begin
  s_VM_Wgr_EK_Wert   : float[9999];
  s_VM_Wgr_EK_Gew    : float[9999];
  s_VM_Wgr_VK_Wert   : float[9999];
  s_VM_Wgr_VK_Gew    : float[9999];
  s_VM_Wgr_LG_Wert   : float[9999];
  s_VM_Wgr_LG_Gew    : float[9999];
end;

define begin
  thisDateYear(a)     : DateYear(a) + 1900
  thisDateYearC16(a)  : a - 1900
  thisYearDateC16(a)  : a + 1900

  cKumuliertYN        : GV.Logic.10

  cWgr_EK_Wert        : 1
  cWgr_EK_Gew         : 2
  cWgr_VK_Wert        : 3
  cWgr_VK_Gew         : 4
  cWgr_LG_Wert        : 5
  cWgr_LG_Gew         : 6

  cMonth_EK_Wert      : 10
  cMonth_EK_Gew       : 11
  cMonth_VK_Wert      : 12
  cMonth_VK_Gew       : 13
  cMonth_LG_Wert      : 14
  cMonth_LG_Gew       : 15

  cGes_EK_Wert        : 20
  cGes_EK_Gew         : 21
  cGes_VK_Wert        : 22
  cGes_VK_Gew         : 23
  cGes_LG_Wert        : 24
  cGes_LG_Gew         : 25
end;

local begin
  g_Empty             : int; // Handles für die Zeilenelemente
  g_Sel1              : int;
  g_Header1           : int;
  g_Header2           : int;
  g_Monat             : int;
  g_Wgr               : int;
  g_Gesamt            : int;
  g_Summe1            : int;
  g_Summe2            : int;
  g_Leselinie         : logic;

  vWgr                : int;
  vLastWgr            : int;
  vLast_VM_Wgr_Hdl    : int;
  vBufLast890         : int;

  g_VM_Month_EK_Wert : float;
  g_VM_Month_EK_Gew  : float;
  g_VM_Month_VK_Wert : float;
  g_VM_Month_VK_Gew  : float;
  g_VM_Month_LG_Wert : float;
  g_VM_Month_LG_Gew  : float;

  g_VM_Wgr           : int;


  vSelVonMonat  : int;
  vSelBisMonat  : int;
  vSelVonJahr   : int;
  vSelBisJahr   : int;
  /*
  cWgr_EK_Wert  : float;
  cWgr_EK_Gew   : float;
  cWgr_VK_Wert  : float;
  cWgr_VK_Gew   : float;
  cWgr_LG_Wert  : float;
  cWgr_LG_Gew   : float;

  cMonth_EK_Wert  : float;
  cMonth_EK_Gew   : float;
  cMonth_VK_Wert  : float;
  cMonth_VK_Gew   : float;
  cMonth_LG_Wert  : float;
  cMonth_LG_Gew   : float;
  */
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  RecBufClear(999);

  List_FontSize           # 7;
  cKumuliertYN            # true;
  Sel.bis.Datum           # today;
  Sel.Auf.bis.Wgr         # 9999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450020',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;

//========================================================================
//   call L_Erl_450020:Testdaten
//    Erzeugt Summen-Testdaten in der OSt-Datei
//========================================================================
sub Testdaten();
local begin
  Erx           : int;
  vSel          : int;
  vSelName      : alpha;
  vItem         : int;
  vTree         : int;
  vSortKey      : alpha;
  vQ890         : alpha(4000);
  vProgress     : handle;
  vSep          : int;
  vLen          : int;
  vRndMulti     : float;
  vMonth        : int;
end;
begin
  vSelVonMonat  # 04;
  vSelBisMonat  # 04;
  vSelVonJahr   # 2012;
  vSelBisJahr   # 2012;

  vQ890  # '';
  Lib_Sel:QVonBisI(var vQ890, 'OSt.Jahr',  thisDateYearC16(vSelVonJahr), thisDateYearC16(vSelBisJahr));
  Lib_Sel:QEnthaeltA(var vQ890, 'OSt.Name', 'SUM_');
  Lib_Sel:QEnthaeltA(var vQ890, 'OSt.Name', '_WGR');
  vSel # SelCreate(890, 1);
  Erx # vSel->SelDefQuery('', vQ890);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vMonth  #  0;
  FOR vMonth # vMonth + 1;
  LOOP vMonth # vMonth + 1;
  WHILE(vMonth <= 3) DO BEGIN
    FOR Erx # RecRead(890, vSel, _recFirst);
    LOOP Erx # RecRead(890, vSel, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      if( ((OSt.Jahr = vSelVonJahr) and (OSt.Monat < vSelVonMonat))
      or ((OSt.Jahr = vSelBisJahr) and (OSt.Monat > vSelBisMonat)) )then
        CYCLE;

      vRndMulti         # Rnd(Random(), 2);

      OSt.Monat         # OSt.Monat + vMonth;
      OSt.VK.Gewicht    # OSt.VK.Gewicht    * vRndMulti;
      OSt.VK.Wert       # OSt.VK.Wert       * vRndMulti;
      OSt.EK.Gewicht    # OSt.EK.Gewicht    * vRndMulti;
      OSt.EK.Wert       # OSt.EK.Wert       * vRndMulti;
      OSt.Lager.Gewicht # OSt.Lager.Gewicht * vRndMulti;
      OSt.Lager.Wert    # OSt.Lager.Wert    * vRndMulti;

      RekInsert(890, 0, 'MAN');
    END;
  END;
  SelClose(vSel);
  SelDelete(890, vSelName);
  vSel # 0;
end;


//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2  : int;
  vSort       : int;
  vSortName   : alpha;
end;
begin
/*
  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd(Translate(''));
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
*/
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine       : int;
  vObf        : alpha(120);
  vRohertrag  : float;
  vVK_EK      : float;
  vVM_VK_EK      : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   22.0;
      List_Spacing[ 4]  #   30.0;
      List_Spacing[ 5]  #   47.0;
      List_Spacing[ 6]  #   53.0;
      List_Spacing[ 7]  #   80.0;
      List_Spacing[ 8]  #  100.0;
      List_Spacing[ 9]  #  102.0;
      List_Spacing[10]  #  110.0;
      List_Spacing[11]  #  130.0;
      List_Spacing[12]  #  137.0;
      List_Spacing[13]  #  160.0;
      List_Spacing[14]  #  180.0;
      List_Spacing[15]  #  182.0;
      List_Spacing[16]  #  190.0;
      List_Spacing[17]  #  210.0;
      List_Spacing[18]  #  217.0;
      List_Spacing[19]  #  240.0;

      LF_Set(1, 'Warengr'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if (Sel.Auf.von.Wgr <> 0) then
        LF_Set(4,  ZahlI(Sel.Auf.von.Wgr)                           ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Auf.bis.Wgr <> 0) then
        LF_Set(6,  ZahlI(Sel.Auf.bis.Wgr)                           ,y , _LF_INT);
       LF_Set(7, 'Datum'                                    ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if(Sel.von.Datum <> 0.0.0) then
        LF_Set(10, DatS(Sel.von.Datum)                         ,n , _LF_Date);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if(Sel.bis.Datum <> 0.0.0) then
        LF_Set(12, DatS(Sel.bis.Datum)                         ,y , _LF_Date);
    end;


    'HEADER1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 17.0; // 'Monat'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Auftragsbestand Gew.'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 27.0; // 'Auftragsbestand  €'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 15.0; // 'Durchschnitt Auftragsbestand €'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 27.0; // 'Bestellbestand Gew.'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 27.0; // 'Bestellbestand €'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 15.0; // 'Durchschnitt Bestellbestand €'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 27.0; // 'Lagerbestand Gew.'
      List_Spacing[10]  # List_Spacing[ 9]  + 27.0; // 'Lagerbestand €'
      List_Spacing[11]  # List_Spacing[ 10] + 15.0; // 'Durchschnitt Lagerbestand €'
      List_Spacing[12]  # List_Spacing[ 11] + 30.0; // 'Summe Wert € Auf/Best'
      List_Spacing[13]  # List_Spacing[ 12] + 30.0; // 'Entwicklung zum Vormonat'
      List_Spacing[14]  # List_Spacing[ 13] + 30.0;
      List_Spacing[15]  # List_Spacing[ 14] + 30.0;
      List_Spacing[16]  # List_Spacing[ 15] + 30.0;
      List_Spacing[17]  # List_Spacing[ 16] + 30.0;
      List_Spacing[18]  # List_Spacing[ 17] + 30.0;


      LF_Format(_LF_Bold);
      LF_Set(1,  ''                     ,n , 0);
      LF_Set(2,  ''                     ,y , 0);
      LF_Set(3,  'Auftragsbestand  '    ,y , 0);
      LF_Set(4,  ''                     ,y , 0);
      LF_Set(5,  ''                     ,y , 0);
      LF_Set(6,  'Bestellbestand'       ,y , 0);
      LF_Set(7,  ''                     ,y , 0);
      LF_Set(8,  ''                     ,y , 0);
      LF_Set(9,  'Lagerbestand'         ,y , 0);
      LF_Set(10, ''                     ,y , 0);
      LF_Set(11, 'Summe Wert'           ,y , 0);
      LF_Set(12, 'Entwicklung'          ,y , 0);

      //LF_Set(6,  'Rohertrag'                   ,y , 0);
      //LF_Set(7,  'RH/to'                       ,y , 0);
    end;

    'HEADER2' : begin
      if (aPrint) then RETURN
      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Monat'                         ,n , 0);
      LF_Set(2,  'Gewicht'                       ,y , 0);
      LF_Set(3,  'Wert €'                        ,y , 0);
      if(List_XML = false) then // Bildschirmvorschau
        LF_Set(4,  'Ø €/t'                       ,y , 0);
      else
        LF_Set(4,  'Durchschnitt €/t'            ,y , 0);
      LF_Set(5,  'Gewicht'                       ,y , 0);
      LF_Set(6,  'Wert €'                        ,y , 0);
      if(List_XML = false) then // Bildschirmvorschau
        LF_Set(7,  'Ø €/t'                       ,y , 0);
      else
        LF_Set(7,  'Durchschnitt €/t'            ,y , 0);
      LF_Set(8,  'Gewicht'                       ,y , 0);
      LF_Set(9,  'Wert €'                        ,y , 0);
      if(List_XML = false) then // Bildschirmvorschau
        LF_Set(10,  'Ø €/t'                      ,y , 0);
      else
        LF_Set(10,  'Durchschnitt €/t'           ,y , 0);
      LF_Set(11,  'Auf/Best €'                     ,y , 0);
      LF_Set(12,  'zum Vormonat €'               ,y , 0);
      //LF_Set(6,  'Rohertrag'                   ,y , 0);
      //LF_Set(7,  'RH/to'                       ,y , 0);
    end;


    'MONAT' : begin
      if (aPrint) then begin
        LF_Text(1,cnvAI(vBufLast890 -> OSt.Monat, _FmtNumLeadZero, 0, 2) + '/' + AInt(thisYearDateC16(vBufLast890 -> OSt.Jahr)));
        LF_Sum(2, cMonth_VK_Gew, Set.Stellen.Gewicht);
        LF_Sum(3, cMonth_VK_Wert, 2);
        if(GetSum(cMonth_VK_Gew) <> 0.0) then
          LF_Text(4, ZahlF(GetSum(cMonth_VK_Wert) / (GetSum(cMonth_VK_Gew) / 1000.0), 2));
        else
          LF_Text(4, ZahlF(0.0, 2));
        LF_Sum(5, cMonth_EK_Gew, Set.Stellen.Gewicht);
        LF_Sum(6, cMonth_EK_Wert, 2);
        if(GetSum(cMonth_EK_Gew) <> 0.0) then
          LF_Text(7, ZahlF(GetSum(cMonth_EK_Wert) / (GetSum(cMonth_EK_Gew) / 1000.0), 2));
        else
          LF_Text(7, ZahlF(0.0, 2));

        LF_Sum(8, cMonth_LG_Gew, Set.Stellen.Gewicht);
        LF_Sum(9, cMonth_LG_Wert, 2);
        if(GetSum(cMonth_LG_Gew) <> 0.0) then
          LF_Text(10, ZahlF(GetSum(cMonth_LG_Wert) / (GetSum(cMonth_LG_Gew) / 1000.0), 2));
        else
          LF_Text(10, ZahlF(0.0, 2));

        vVK_EK    # GetSum(cMonth_VK_Wert) + GetSum(cMonth_EK_Wert);
        vVM_VK_EK # g_VM_Month_VK_Wert  + g_VM_Month_EK_Wert;
        LF_Text(11, ZahlF(vVK_EK, 2));
        LF_Text(12, ZahlF(vVK_EK - vVM_VK_EK, 2));

        /*
        vRohertrag # GetSum(cMonth_VK_Wert) - GetSum(cMonth_EK_Wert);
        LF_Text(6, ANum(vRohertrag, 2));
        if(GetSum(cMonth_VK_Gew) <> 0.0) then begin
          LF_Text(7, ANum(vRohertrag / (GetSum(cMonth_VK_Gew) / 1000.0), 2));
          LF_Text(8, ANum(GetSum(cMonth_VK_Wert) / (GetSum(cMonth_VK_Gew) / 1000.0), 2));
        end
        else begin
          LF_Text(7, ANum(0.0, 2));
          LF_Text(8, ANum(0.0, 2));
        end;
        */
        if(List_XML = false) and (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      if(cKumuliertYN = false) then
        LF_Format(_LF_OverLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, '#Monat/Jahr'               ,n , 0);
      LF_Set(2, '#VK Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(3, '#VK €'                     ,y , _LF_Wae);
      LF_Set(4, '#Ø VK'                     ,y , _LF_Wae);
      LF_Set(5, '#EK Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '#EK €'                     ,y , _LF_Wae);
      LF_Set(7, '#Ø EK'                     ,y , _LF_Wae);
      LF_Set(8, '#LG Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(9, '#LG €'                     ,y , _LF_Wae);
      LF_Set(10,'#Ø LG'                     ,y , _LF_Wae);
      LF_Set(11,'#VK + EK €'                ,y , _LF_Wae);
      LF_Set(12,'#zu Vormonat VK + EK €'    ,y , _LF_Wae);
    end;

    'WGR' : begin
      if (aPrint) then begin
        LF_Text(1,cnvAI(vLastWgr));
        LF_Sum(2, cWgr_VK_Gew, Set.Stellen.Gewicht);
        LF_Sum(2, cWgr_VK_Gew, Set.Stellen.Gewicht);
        LF_Sum(3, cWgr_VK_Wert, 2);
        if(GetSum(cWgr_VK_Gew) <> 0.0) then
          LF_Text(4, ZahlF(GetSum(cWgr_VK_Wert) / (GetSum(cWgr_VK_Gew) / 1000.0), 2));
        else
          LF_Text(4, ZahlF(0.0, 2));
        LF_Sum(5, cWgr_EK_Gew, Set.Stellen.Gewicht);
        LF_Sum(6, cWgr_EK_Wert, 2);
        if(GetSum(cWgr_EK_Gew) <> 0.0) then
          LF_Text(7, ZahlF(GetSum(cWgr_EK_Wert) / (GetSum(cWgr_EK_Gew) / 1000.0), 2));
        else
          LF_Text(7, ZahlF(0.0, 2));

        LF_Sum(8, cWgr_LG_Gew, Set.Stellen.Gewicht);
        LF_Sum(9, cWgr_LG_Wert, 2);
        if(GetSum(cWgr_LG_Gew) <> 0.0) then
          LF_Text(10, ZahlF(GetSum(cWgr_LG_Wert) / (GetSum(cWgr_LG_Gew) / 1000.0), 2));
        else
          LF_Text(10, ZahlF(0.0, 2));

        vVK_EK    # GetSum(cWgr_VK_Wert) + GetSum(cWgr_EK_Wert);
        vVM_VK_EK # s_VM_Wgr_VK_Wert[vLastWgr]  + s_VM_Wgr_EK_Wert[vLastWgr];
        LF_Text(11, ZahlF(vVK_EK, 2));
        LF_Text(12, ZahlF(vVK_EK - vVM_VK_EK, 2));
        /*
        LF_Sum(3, cWgr_VK_Wert, 2);
        LF_Sum(4, cWgr_EK_Gew, Set.Stellen.Gewicht);
        LF_Sum(5, cWgr_EK_Wert, 2);
        vRohertrag # GetSum(cWgr_VK_Wert) - GetSum(cWgr_EK_Wert);
        LF_Text(6, ANum(vRohertrag, 2));
        if(GetSum(cWgr_VK_Gew) <> 0.0) then begin
          LF_Text(7, ANum(vRohertrag / (GetSum(cWgr_VK_Gew) / 1000.0), 2));
          LF_Text(8, ANum(GetSum(cWgr_VK_Wert) / (GetSum(cWgr_VK_Gew) / 1000.0), 2));
        end
        else begin
          LF_Text(7, ANum(0.0, 2));
          LF_Text(8, ANum(0.0, 2));
        end;
        */
        if(List_XML = false) and (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      // Instanzieren...
      LF_Set(1, '#Monat/Jahr'               ,n , 0);
      LF_Set(2, '#VK Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(3, '#VK €'                     ,y , _LF_Wae);
      LF_Set(4, '#Ø VK'                     ,y , _LF_Wae);
      LF_Set(5, '#EK Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '#EK €'                     ,y , _LF_Wae);
      LF_Set(7, '#Ø EK'                     ,y , _LF_Wae);
      LF_Set(8, '#LG Gew.'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(9, '#LG €'                     ,y , _LF_Wae);
      LF_Set(10,'#Ø LG'                     ,y , _LF_Wae);
      LF_Set(11,'#VK + EK €'                ,y , _LF_Wae);
      LF_Set(12,'#zu Vormonat VK + EK €'    ,y , _LF_Wae);
     end;

     'GESAMT' : begin
      if (aPrint) then begin
        LF_Text(1, '');
        LF_Sum(2, cGes_VK_Gew, Set.Stellen.Gewicht);
        LF_Sum(3, cGes_VK_Wert, 2);
        if(GetSum(cGes_VK_Gew) <> 0.0) then
          LF_Text(4, ZahlF(GetSum(cGes_VK_Wert) / (GetSum(cGes_VK_Gew) / 1000.0), 2));
        else
          LF_Text(4, ZahlF(0.0, 2));
        LF_Sum(5, cGes_EK_Gew, Set.Stellen.Gewicht);
        LF_Sum(6, cGes_EK_Wert, 2);
        if(GetSum(cGes_EK_Gew) <> 0.0) then
          LF_Text(7, ZahlF(GetSum(cGes_EK_Wert) / (GetSum(cGes_EK_Gew) / 1000.0), 2));
        else
          LF_Text(7, ZahlF(0.0, 2));
        LF_Sum(8, cGes_LG_Gew, Set.Stellen.Gewicht);
        LF_Sum(9, cGes_LG_Wert, 2);
        if(GetSum(cGes_LG_Gew) <> 0.0) then
          LF_Text(10, ZahlF(GetSum(cGes_LG_Wert) / (GetSum(cGes_LG_Gew) / 1000.0), 2));
        else
          LF_Text(10, ZahlF(0.0, 2));
        /*
        vRohertrag # GetSum(cGes_VK_Wert) - GetSum(cGes_EK_Wert);
        LF_Text(6, ANum(vRohertrag, 2));
        LF_Text(7, ANum(vRohertrag / (GetSum(cGes_VK_Gew) / 1000.0), 2));
        LF_Text(8, ANum(GetSum(cGes_VK_Wert) / (GetSum(cGes_VK_Gew) / 1000.0), 2));if(GetSum(cGes_VK_Gew) <> 0.0) then begin
          LF_Text(7, ANum(vRohertrag / (GetSum(cGes_VK_Gew) / 1000.0), 2));
          LF_Text(8, ANum(GetSum(cGes_VK_Wert) / (GetSum(cGes_VK_Gew) / 1000.0), 2));
        end
        else begin
          LF_Text(7, ANum(0.0, 2));
          LF_Text(8, ANum(0.0, 2));
        end;
        */
        if(List_XML = false) and (false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;
        RETURN;

      end;

      LF_Format(_LF_OverLine + _LF_Bold);

      // Instanzieren...
      LF_Set(1, '#Monat/Jahr'          ,n , 0);
      LF_Set(2, '#VK Gew.'             ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(3, '#VK €'                ,y , _LF_Wae);
      LF_Set(4, '#Ø VK'                ,y , _LF_Wae);
      LF_Set(5, '#EK Gew.'             ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(6, '#EK €'                ,y , _LF_Wae);
      LF_Set(7, '#Ø EK'                ,y , _LF_Wae);
      LF_Set(8, '#LG Gew.'             ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(9, '#LG €'                ,y , _LF_Wae);
      LF_Set(10, '#Ø LG'               ,y , _LF_Wae);
     end;

  end;  // case

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  LF_Print(g_Empty);

  if (aSeite=1) then begin
    LF_Print(g_Sel1);
    LF_Print(g_Empty);
    LF_Print(g_Empty);
  end;

  LF_Print(g_Header1);
  LF_Print(g_Header2);
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx           : int;
  vSel          : int;
  vFlag         : int;        // Datensatzlese option
  vSelName      : alpha;
  vItem         : int;
  vKey          : int;
  vMFile,vMID   : int;
  vOK           : logic;
  vTree         : int;
  vSortKey      : alpha;
  vQ890         : alpha(4000);
  vProgress     : handle;
  vSep          : int;
  vLen          : int;

  vLastHdl      : int;
  vHdl          : int;
end;
begin
  vSelVonMonat  # Sel.Von.Datum -> vpMonth;
  vSelVonJahr   # Sel.Von.Datum -> vpYear;
  vSelBisJahr   # Sel.Bis.Datum -> vpYear;
  vSelBisMonat  # Sel.Bis.Datum -> vpMonth;

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vQ890  # '';
  Lib_Sel:QVonBisI(var vQ890, 'OSt.Jahr',  thisDateYearC16(vSelVonJahr), thisDateYearC16(vSelBisJahr));
  Lib_Sel:QEnthaeltA(var vQ890, 'OSt.Name', 'SUM_');
  Lib_Sel:QEnthaeltA(var vQ890, 'OSt.Name', '_WGR');
  vSel # SelCreate(890, 1);
  Erx # vSel->SelDefQuery('', vQ890);
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(890, _recCount, vSel));
  FOR Erx # RecRead(890, vSel, _recFirst);
  LOOP Erx # RecRead(890, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    if (!vProgress->Lib_Progress:Step()) then begin     // Progress
      SelClose(vSel);
      SelDelete(890, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if( ((OSt.Jahr = thisDateYearC16(vSelVonJahr)) and (OSt.Monat < vSelVonMonat))
    or ((OSt.Jahr = thisDateYearC16(vSelBisJahr)) and (OSt.Monat > vSelBisMonat)) )then
      CYCLE;

    vSep # StrFind(OSt.Name, ':', 0);
    vLen # StrLen(OSt.Name);
    vWgr # Lib_Strings:AlphaToInt(StrCut(OSt.Name,  vSep + 1, vLen - vSep));

    if((vWgr < Sel.Auf.von.Wgr) or (vWgr > Sel.Auf.bis.Wgr)) then
      CYCLE;


    vSortKey # cnvAI(OSt.Jahr, _FmtNumLeadZero, 0, 4) + '|'
             + cnvAI(OSt.Monat, _FmtNumLeadZero, 0, 4) + '|'
             + cnvAI(vWgr, _FmtNumLeadZero, 0, 7) + '|';

    Sort_ItemAdd(vTree, vSortKey, 890, RecInfo(890,_RecId));
  END;
  SelClose(vSel);
  SelDelete(890, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header1   # LF_NewLine('HEADER1');
  g_Header2   # LF_NewLine('HEADER2');
  g_Monat     # LF_NewLine('MONAT');
  g_Wgr       # LF_NewLine('WGR');
  g_Gesamt    # LF_NewLine('GESAMT');
  g_Summe1    # LF_NewLine('SUMME1');
  g_Summe2    # LF_NewLine('SUMME2');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  vItem # Sort_ItemFirst(vTree) // RAMBAUM
  if(vItem <> 0) then
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen OSt(890)
  vBufLast890     # RekSave(890);
  vSep            # StrFind(OSt.Name, ':', 0);
  vLen            # StrLen(OSt.Name);
  vWgr            # Lib_Strings:AlphaToInt(StrCut(OSt.Name,  vSep + 1, vLen - vSep));
  vLastWgr        # vWgr;

  g_VM_Month_EK_Wert  # 0.0;
  g_VM_Month_EK_Gew   # 0.0;
  g_VM_Month_VK_Wert  # 0.0;
  g_VM_Month_VK_Gew   # 0.0;
  g_VM_Month_LG_Wert  # 0.0;
  g_VM_Month_LG_Gew   # 0.0;

  vLastHdl # VarAllocate(Struct_VM_Wgr);
  vHdl     # VarAllocate(Struct_VM_Wgr);

  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID); // Datensatz holen OSt(890)

    vSep # StrFind(OSt.Name, ':', 0);
    vLen # StrLen(OSt.Name);
    vWgr # Lib_Strings:AlphaToInt(StrCut(OSt.Name,  vSep + 1, vLen - vSep));

    if( (cKumuliertYN = false)
    and ( (vWgr <> vLastWgr)
    or (OSt.Monat <> vBufLast890 -> OSt.Monat)
    or (OSt.Jahr <> vBufLast890 -> OSt.Jahr)
    )
    )then begin
      if(vLastHdl <> 0) then
        VarInstance(Struct_VM_Wgr, vLastHdl);
      LF_Print(g_Wgr);
      if(vHdl <> 0) then
        VarInstance(Struct_VM_Wgr, vHdl);

      ResetSum(cWgr_EK_Wert);
      ResetSum(cWgr_EK_Gew );
      ResetSum(cWgr_VK_Wert);
      ResetSum(cWgr_VK_Gew );
      ResetSum(cWgr_LG_Wert);
      ResetSum(cWgr_LG_Gew );
    end;

    if( (OSt.Monat <> vBufLast890 -> OSt.Monat)
    or (OSt.Jahr <> vBufLast890 -> OSt.Jahr) ) then begin
      LF_Print(g_Monat);
      LF_Print(g_Empty);

      g_VM_Month_EK_Wert  # GetSum(cMonth_EK_Wert);
      g_VM_Month_EK_Gew   # GetSum(cMonth_EK_Gew );
      g_VM_Month_VK_Wert  # GetSum(cMonth_VK_Wert);
      g_VM_Month_VK_Gew   # GetSum(cMonth_VK_Gew );
      g_VM_Month_LG_Wert  # GetSum(cMonth_LG_Wert);
      g_VM_Month_LG_Gew   # GetSum(cMonth_LG_Gew );

      ResetSum(cMonth_EK_Wert);
      ResetSum(cMonth_EK_Gew );
      ResetSum(cMonth_VK_Wert);
      ResetSum(cMonth_VK_Gew );
      ResetSum(cMonth_LG_Wert);
      ResetSum(cMonth_LG_Gew );

      VarInstance(Struct_VM_Wgr, vLastHdl);
      VarFree(Struct_VM_Wgr);
      vLastHdl # vHdl;
      vHdl     # VarAllocate(Struct_VM_Wgr);
    end;

    s_VM_Wgr_EK_Wert[vWgr]  # s_VM_Wgr_EK_Wert[vWgr] + OSt.EK.Wert   ;
    s_VM_Wgr_EK_Gew[vWgr]   # s_VM_Wgr_EK_Gew[vWgr]  + OSt.EK.Gewicht;
    s_VM_Wgr_VK_Wert[vWgr]  # s_VM_Wgr_VK_Wert[vWgr] + OSt.VK.Wert   ;
    s_VM_Wgr_VK_Gew[vWgr]   # s_VM_Wgr_VK_Gew[vWgr]  + OSt.VK.Gewicht;
    s_VM_Wgr_LG_Wert[vWgr]  # s_VM_Wgr_LG_Wert[vWgr] + OSt.Lager.Wert;
    s_VM_Wgr_LG_Gew[vWgr]   # s_VM_Wgr_LG_Gew[vWgr]  + OSt.Lager.Gewicht;

    AddSum(cWgr_EK_Wert , OSt.EK.Wert      );
    AddSum(cWgr_EK_Gew  , OSt.EK.Gewicht   );
    AddSum(cWgr_VK_Wert , OSt.VK.Wert      );
    AddSum(cWgr_VK_Gew  , OSt.VK.Gewicht   );
    AddSum(cWgr_LG_Wert , OSt.Lager.Wert   );
    AddSum(cWgr_LG_Gew  , OSt.Lager.Gewicht);

    AddSum(cMonth_EK_Wert , OSt.EK.Wert      );
    AddSum(cMonth_EK_Gew  , OSt.EK.Gewicht   );
    AddSum(cMonth_VK_Wert , OSt.VK.Wert      );
    AddSum(cMonth_VK_Gew  , OSt.VK.Gewicht   );
    AddSum(cMonth_LG_Wert , OSt.Lager.Wert   );
    AddSum(cMonth_LG_Gew  , OSt.Lager.Gewicht);

    AddSum(cGes_EK_Wert , OSt.EK.Wert      );
    AddSum(cGes_EK_Gew  , OSt.EK.Gewicht   );
    AddSum(cGes_VK_Wert , OSt.VK.Wert      );
    AddSum(cGes_VK_Gew  , OSt.VK.Gewicht   );
    AddSum(cGes_LG_Wert , OSt.Lager.Wert   );
    AddSum(cGes_LG_Gew  , OSt.Lager.Gewicht);

    vLastWgr # vWgr;
    RecBufCopy(890, vBufLast890);
  END;

  if((cKumuliertYN = false) and (OSt.Jahr <> 0))then begin
    if(vLastHdl <> 0) then
      VarInstance(Struct_VM_Wgr, vLastHdl);
    LF_Print(g_Wgr);
    if(vHdl <> 0) then
      VarInstance(Struct_VM_Wgr, vHdl);
    ResetSum(cWgr_EK_Wert);
    ResetSum(cWgr_EK_Gew );
    ResetSum(cWgr_VK_Wert);
    ResetSum(cWgr_VK_Gew );
    ResetSum(cWgr_LG_Wert);
    ResetSum(cWgr_LG_Gew );
  end;

  if((vBufLast890 -> OSt.Jahr <> 0)) then begin
    LF_Print(g_Monat);

    ResetSum(cMonth_EK_Wert);
    ResetSum(cMonth_EK_Gew );
    ResetSum(cMonth_VK_Wert);
    ResetSum(cMonth_VK_Gew );
    ResetSum(cMonth_LG_Wert);
    ResetSum(cMonth_LG_Gew );
  end;

  LF_Print(g_Gesamt);

  VarInstance(Struct_VM_Wgr, vLastHdl);
  VarFree(Struct_VM_Wgr);
  VarInstance(Struct_VM_Wgr, vHdl);
  VarFree(Struct_VM_Wgr);

  Sort_KillList(vTree); // Löschen der Liste

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header1);
  LF_FreeLine(g_Header2);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Monat);
  LF_FreeLine(g_Wgr);
  LF_FreeLine(g_Gesamt);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);

end;

//========================================================================