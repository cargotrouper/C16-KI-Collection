@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500004
//                    OHNE E_R_G
//  Info        Eingangsliste
//
//
//  05.03.2007  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  01.10.2013  AH  Bugfix
//  07.10.2013  AH  Bugfix
//  16.10.2013  AH  Anfragen
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha; aDatum : date);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha; aDatum : date);

define begin
  cFile : 501
  cSel  : 'LST.500004'
  cMask : 'SEL.LST.500004'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Projekt   # 99999999;
  Sel.Auf.bis.Dicke     # 999999.00;
  Sel.Auf.bis.Breite    # 999999.00;
  "Sel.Auf.bis.Länge"   # 999999.00;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI, cMask, here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
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

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd(Translate('Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Auftragsnr.'));
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Erfassdatum'));
  vHdl2->WinLstDatLineAdd(Translate('Lieferanten-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('Qualität * Abmessung'));
  vHdl2->WinLstDatLineAdd(Translate('Wunschtermin'));
  vHdl2->WinLstDatLineAdd(Translate('Zusagetermin'));
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  StartLine();
  EndLine();
  if (aSeite=1) then begin
    List_Spacing[ 1]  #   0.0;
    List_Spacing[ 2]  #  80.0;
    List_Spacing[ 3]  # 160.0;
    List_Spacing[ 4]  # 240.0;
    StartLine();
    Write( 1, 'Bestell-Nr von ' + AInt(Sel.Auf.von.Nummer) + ' bis ' + AInt(Sel.Auf.bis.Nummer) ,n , 0);
    if (Sel.Auf.von.Datum <> 0.0.0) and (Sel.Auf.bis.Datum <> 0.0.0) then
      Write( 2, 'Datum von ' + DatS(Sel.Auf.von.Datum) + ' bis ' + DatS(Sel.Auf.bis.Datum) ,n , 0);
    if (Sel.Auf.von.WTermin <> 0.0.0) and (Sel.Auf.bis.WTermin <> 0.0.0) then
      Write( 3, 'Wunsch Termin von ' + DatS(Sel.Auf.von.WTermin) + ' bis ' + DatS(Sel.Auf.bis.WTermin) ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Vorgangsart von ' + AInt(Sel.Auf.von.AufArt) + ' bis ' + AInt(Sel.Auf.bis.AufArt) ,n , 0);
    Write( 2, 'Wgr von ' + AInt(Sel.Auf.von.Wgr) + ' bis ' + AInt(Sel.Auf.bis.Wgr) ,n , 0);
    if (Sel.Auf.von.ZTermin <> 0.0.0) and (Sel.Auf.bis.ZTermin <> 0.0.0) then
    Write( 3, 'Zusage  Termin von ' + DatS(Sel.Auf.von.ZTermin) + ' bis ' + DatS(Sel.Auf.bis.ZTermin) ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Dicke von ' + ANum(Sel.Auf.von.Dicke,Set.Stellen.Dicke) + ' bis ' + ANum(Sel.Auf.bis.Dicke,"Set.Stellen.Dicke") ,n , 0);
    Write( 2, 'Breite von ' + ANum(Sel.Auf.von.Breite,Set.Stellen.Breite) + ' bis ' + ANum(Sel.Auf.bis.Breite,"Set.Stellen.Breite") ,n , 0);
    Write( 3, 'Länge von ' + ANum("Sel.Auf.von.Länge","Set.Stellen.Länge") + ' bis ' + ANum("Sel.Auf.bis.Länge","Set.Stellen.Länge") ,n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Projekt von ' + AInt(Sel.Auf.von.Projekt) + ' bis ' + AInt(Sel.Auf.bis.Projekt) ,n , 0);
    Write( 2, 'Sachbearbeiter : ' +Sel.Auf.Sachbearbeit    ,n , 0);
    Write( 3, 'Lieferant : ' + AInt(Sel.Auf.Lieferantnr),n , 0);
    EndLine();
    StartLine();
    Write( 1, 'Güte : ' + "Sel.Auf.Güte" ,n , 0);
    Write( 2, 'ObfNr von ' + AInt(Sel.Auf.ObfNr) + ' bis '+ AInt(Sel.Auf.ObfNr2),n , 0);
    Write( 3, 'NUR MATERIAL',n,0);
    EndLine();
    StartLine();
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 23.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 14.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 18.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 15.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 17.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;
  List_Spacing[10]  # List_Spacing[ 9] + 20.0;
  List_Spacing[11]  # List_Spacing[10] + 25.0;
  List_Spacing[12]  # List_Spacing[11] + 15.0;
  List_Spacing[13]  # List_Spacing[12] + 25.0;
  List_Spacing[14]  # List_Spacing[13] + 25.0;
  List_Spacing[15]  # List_Spacing[14] + 20.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Bestellnr.'                            ,y , 0 , 2.0);
  Write(2,  'Lief- stichwort'                       ,n , 0);
  Write(3,  'Wgr.'                                  ,y , 0 , 2.0);
  Write(4,  'Qualität'                              ,n , 0);
  Write(5,  'Dicke'                                 ,y , 0 , 2.0);
  Write(6,  'Breite'                                ,y , 0 , 2.0);
  Write(7,  'Länge'                                 ,y , 0 , 2.0);
  Write(8,  'Menge kg'                              ,y , 0 , 2.0);
  Write(9,  'EK '+"Set.Hauswährung.Kurz"+'/t'       ,y , 0 , 2.0);
  Write(10, 'Gesamt '  + "Set.Hauswährung.Kurz"     ,y , 0 , 2.0);
  Write(11, 'Wunsch Termin'                         ,n , 0);
  Write(12, 'WE-Menge kg'                           ,y , 0 , 2.0);
  Write(13, 'VSB-Menge kg'                          ,y , 0 , 2.0);
  Write(14, 'letztes WE-Datum'                      ,n , 0);

  EndLine();
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  Print
//
//========================================================================
Sub Print(aName   : alpha; aDatum  : date);
local begin
  Erx     : int;
  vEinzel : float;
  vGesamt : float;
end;
begin
   case aName of

    'Position' : begin
      Erx # RekLink(500, 501, 3, _recFirst);   // Kopf holen
      Erx # RekLink(814, 500, 8, _recFirst);   // Währung holen

      if ("Ein.WährungFixYN") then
        Wae.VK.Kurs # "Ein.Währungskurs";

//      vGesamt # (Ein.P.Menge * Ein.P.Einzelpreis) / cnvfi(Ein.P.PEH);
//      vEinzel # Ein.P.Einzelpreis;
      vGesamt # Ein_data:SumGesamtpreis(Ein.P.Menge, Ein.P.MEH, "Ein.P.Stückzahl" , Ein.P.Gewicht);
//      vGesamt # (Lib_Einheiten:WandleMEH(506, "Ein.P.Stückzahl", Ein.P.Gewicht, Ein.P.Gewicht, Ein.P.MEH.Wunsch, Ein.P.MEH.Preis) * Ein.P.PreisW1);
      vEinzel # 0.0;
      if (Ein.P.Gewicht<>0.0) then vEinzel # Rnd(vGesamt / Ein.P.Gewicht * 1000.0, 2);
      vGesamt # Rnd(vGesamt, 2);


      if(Wae.VK.Kurs > 0.0) then begin
        vEinzel # Rnd(vEinzel / "Wae.VK.Kurs",2)
        vGesamt # Rnd(vGesamt / "Wae.VK.Kurs",2)
      end;

      StartLine();
      Write(1, "Ein.P.Löschmarker" + ZahlI(Ein.P.Nummer) +'/ '+ ZahlI(Ein.P.Position)  ,y , 0 , 2.0);
      Write(2, Ein.P.LieferantenSW                                                     ,n , 0);
      Write(3, ZahlI(Ein.P.Warengruppe)                                                ,y , _LF_INT, 2.0);
      Write(4, "Ein.P.Güte"                                                            ,n , 0);
      Write(5, ZahlF(Ein.P.Dicke, Set.Stellen.Dicke)                                   ,y , _LF_NUM, 2.0);
      Write(6, ZahlF(Ein.P.Breite, Set.Stellen.Breite)                                 ,y , _LF_NUM, 2.0);
      Write(7, ZahlF("Ein.P.Länge", "Set.Stellen.Länge")                               ,y , _LF_NUM, 2.0);
      Write(8, ZahlF(Ein.P.Menge, Set.Stellen.Gewicht)                                 ,y , _LF_Num, 2.0);
      Write(9, ZahlF(vEinzel,2)                                                        ,y , _LF_NUM, 2.0);
      Write(10, ZahlF(vGesamt,2)                                                       ,y , _LF_NUM, 2.0);
      If (Ein.P.Termin1Wunsch <> 0.0.0) then Write(11, DatS(Ein.P.Termin1Wunsch)       ,n , _LF_Date);
      Write(12, ZahlF(Ein.P.FM.Eingang, Set.Stellen.Gewicht)                         ,y , _LF_Num , 2.0);
      Write(13, ZahlF(Ein.P.FM.VSB, Set.Stellen.Gewicht)                             ,y , _LF_Num , 2.0);
      If (aDatum <> 0.0.0) then Write(14, DatS(aDatum)                                 ,n , _LF_Date);

      EndLine();
      AddSum(1,vGesamt);
    end;

    'Summe' : begin
      StartLine(_LF_Overline + _LF_Bold);
      Write(10, ZahlF(GetSum(1),2)                                                     ,y , _LF_NUM, 2.0);
      EndLine();
      ResetSum(1);
    end;
  end; // CASE
end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vWE         : date;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vLastDay    : date;
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vLastDay  # DateMake(31,12,DateYear(today));

  // Selektionsquery für 501
  vQ # '';
  Lib_Sel:QInt( var vQ, 'Ein.P.Nummer', '<', 1000000000 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( "Sel.Auf.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Ein.P.Güte"', '=*', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.P.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.P.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein.P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ, 'Ein.P.Wgr.Dateinr', '>=', 200 );
  Lib_Sel:QInt( var vQ, 'Ein.P.Wgr.Dateinr', '<=', 209 );
  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 500
  vQ2 # '';
  Lib_Sel:QAlpha(var vQ2, 'Ein.Vorgangstyp', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );
  if ( Sel.Auf.Lieferantnr != 0) then
    Lib_Sel:QInt( var vQ2, 'Ein.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  //Selektionsquery für 502
  vQ3 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ3, 'Ein.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );


  // Selektion starten...
  vSel # SelCreate( 501, 1 );
  vSel->SelAddLink('', 500, 501, 3, 'Kopf');
  vSel->SelAddlink('', 502, 501, 12, 'Ausf');
  Erx # vSel->SelDefQuery('', vQ );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf', vQ2 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ3 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  // BESTAND-Selektion öffnen
  //vSelName # Sel_Build(vSel, 501, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(501,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAF(Ein.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Ein.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=2) then vSortKey # Ein.P.AB.Nummer;
    if (aSort=3) then vSortKey # cnvAI(Ein.P.Nummer,_FmtNumLeadZero,0,9);
    if (aSort=4) then vSortKey # cnvAI(cnvID(Ein.P.Anlage.Datum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=5) then vSortKey # Ein.P.LieferantenSW;
    if (aSort=6) then vSortKey # "Ein.P.Güte" + cnvAF(Ein.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF(Ein.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=7) then vSortKey # cnvAI(cnvID(Ein.P.Termin1Wunsch),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=8) then vSortKey # cnvAI(cnvID(Ein.P.TerminZusage),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    Sort_ItemAdd(vTree,vSortKey,501,RecInfo(501,_RecId));
  END;
  SelClose(vSel);
  SelDelete(501, vSelName);
  vSel # 0;

// ABLAGE....

  // Selektionsquery für 501
  vQ # '';
  Lib_Sel:QInt( var vQ, '"Ein~P.Nummer"', '<', 1000000000 );
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Ein~P.Nummer"', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ, '"Ein~P.TerminZusage"', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != vLastDay) then
    Lib_Sel:QVonBisD( var vQ, '"Ein~P.Termin1Wunsch"', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ, '"Ein~P.Lieferantennr"', '=', Sel.Auf.Lieferantnr );
  if ( "Sel.Auf.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ, '"Ein~P.Güte"', '=', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein~P.Dicke"', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein~P.Breite"', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein~P.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Ein~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Ein~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, '"Ein~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ, '"Ein~P.Wgr.Dateinr"', '>=', 200 );
  Lib_Sel:QInt( var vQ, '"Ein~P.Wgr.Dateinr"', '<=', 209 );
  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 500
  vQ2 # '';
  Lib_Sel:QAlpha(var vQ2, '"Ein~Vorgangstyp"', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ2, '"Ein~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );
  if ( Sel.Auf.Lieferantnr != 0) then
    Lib_Sel:QInt( var vQ2, '"Ein~Lieferantennr"', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today ) then
    Lib_Sel:QVonBisD( var vQ2, '"Ein~Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  //Selektionsquery für 502
  vQ3 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 9999 ) then
    Lib_Sel:QVonBisI( var vQ3, 'Ein.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );


  // Selektion starten...
  vSel # SelCreate( 511, 1 );
  vSel->SelAddLink('', 510, 511, 3, 'Kopf');
  vSel->SelAddlink('', 502, 511, 12, 'Ausf');

  Erx # vSel->SelDefQuery('', vQ );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf', vQ2 );
  if (Erx<>0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Ausf', vQ3 );
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  //vSelName # Sel_Build(vSel, 511, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(511,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAF("Ein~P.Dicke",_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF("Ein~P.Breite",_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein~P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=2) then vSortKey # "Ein~AB.Nummer";
    if (aSort=3) then vSortKey # cnvAI("Ein~P.Nummer",_FmtNumLeadZero,0,9);
    if (aSort=4) then vSortKey # cnvAI(cnvID("Ein~P.Anlage.Datum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=5) then vSortKey # "Ein~P.LieferantenSW";
    if (aSort=6) then vSortKey # "Ein~P.Güte" + cnvAF("Ein~P.Dicke",_FmtNumLeadZero|_FmtNumNoGroup,0,3,8)+cnvAF("Ein~P.Breite",_FmtNumLeadZero|_FmtNumNoGroup,0,2,10)+cnvAF("Ein~P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);
    if (aSort=7) then vSortKey # cnvAI(cnvID("Ein~P.Termin1Wunsch"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    if (aSort=8) then vSortKey # cnvAI(cnvID("Ein~P.TerminZusage"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    Sort_ItemAdd(vTree,vSortKey,511,RecInfo(511,_RecId));
  END;
  SelClose(vSel);
  SelDelete(511, vSelName);
  vSel # 0;



  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    If (CnvIA(vItem->spCustom)=511) then RecBufCopy(511,501);

    // letzten Wareneingang holen
    vWE # 0.0.0;
    Erx # RecLink(506,501,14,_RecFirst);
    WHILE (Erx <= _rLocked) do begin

      If (vWE < Ein.E.Eingang_Datum) then begin
        vWE # Ein.E.Eingang_Datum;
      end;

      Erx # RecLink(506,501,14,_RecNext);
    END;

    Print('Position', vWE);
  END;
  Print('Summe', vWE); //Summen drucken

  // Löschen der Liste
  Sort_KillList(vTree);

  ListTerm();
end;

//========================================================================