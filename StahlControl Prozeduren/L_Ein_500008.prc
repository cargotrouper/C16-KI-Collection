@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500008
//                    OHNE E_R_G
//  Info        Eingangsliste
//
//
//  18.02.2008 MS  Erstellung der Prozedur
//  31.07.2008 DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  16.10.2013  AH  Anfragenx
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
//declare Print(aName : alpha);

define begin
  cFile : 506
  cSel  : 'LST.500008'
  cMask : 'SEL.LST.500008'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Auf.ObfNr2        # 999;
  Sel.Auf.bis.Nummer    # 99999999;
  Sel.Auf.bis.Datum     # today;
  Sel.bis.Datum         # today;
  Sel.Auf.bis.WTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.ZTermin   # DateMake(31,12,DateYear(today));
  Sel.Auf.bis.AufArt    # 999;
  Sel.Auf.bis.WGr       # 9999;
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
  vHdl2->WinLstDatLineAdd(Translate('Bestellnummer'));
  vHdl2->WinLstDatLineAdd(Translate('Lieferanten-Stichwort'));
  vHdl2->WinLstDatLineAdd(Translate('WE-Datum'));
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
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 35.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 35.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;
  List_Spacing[10]  # List_Spacing[ 9] + 20.0;
  List_Spacing[11]  # List_Spacing[10] + 25.0;
  List_Spacing[12]  # List_Spacing[11] + 25.0;
/*
  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 16.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 16.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 15.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 17.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 20.0;
  List_Spacing[12]  # List_Spacing[11] + 25.0;
*/

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'WE-Dat.'                                        ,n ,0);
  Write(2,  'Wgr.'                                           ,y ,0);
  Write(3,  'Bestell-Nr.'                               ,y ,0 ,3.0);
  Write(4,  'Lfr.stichwort'                                  ,n ,0);
  Write(5,  'AB-Nr.'                                         ,y ,0);
  Write(6,  'Prj-Nr.'                                   ,y ,0 ,3.0);
  Write(7,  'Lagerort'                                       ,n ,0);
  Write(8,  'Coil-Nr.'                                       ,n ,0);
  if (List_XML = y)then
    Write(9,  'Gewicht kg'                                   ,y ,0);
  else
    Write(9,  'Gewicht'                                      ,y ,0);
  Write(10, 'E-Preis ' + "Set.Hauswährung.Kurz"              ,y ,0);
  Write(11, 'Gesamt '  + "Set.Hauswährung.Kurz"              ,y ,0);

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
sub Print(aName   : alpha);
local begin
  Erx       : int;
  vEinzel   : float;
  vGesamt   : float;
end;
begin
   case aName of

    'Position' : begin

      Erx # RecLink(501,506,1,_recFirst);
      If (Erx <= _rLocked) then begin
        Erx # RecLink(500,501,3,_recFirst);   // Kopf holen
      end else begin
        Erx # RecLink(511,506,11,_recFirst);
        Erx # RecLink(510,511,3,_recFirst);   // Kopf holen
        RecBufCopy(511,501);
        RecBufCopy(510,500);
      end;
      Erx # RecLink(814,506,16,_recFirst);   // Währung holen


      if ("Ein.WährungFixYN") then Wae.VK.Kurs # "Ein.Währungskurs";

      vGesamt # (Ein.E.Menge * Ein.P.Einzelpreis) / cnvfi(Ein.P.PEH);
      vEinzel # Ein.P.Einzelpreis;

      vEinzel # Rnd(vEinzel / "Wae.VK.Kurs",2)
      vGesamt # Rnd(vGesamt / "Wae.VK.Kurs",2)

      StartLine();
      if (Ein.E.Eingang_Datum <> 0.0.0) then
        Write(1, DatS(Ein.E.Eingang_Datum)                                             ,n , _LF_Date);
      Write(2,  ZahlI(Ein.P.Warengruppe)                                               ,y ,_LF_Int);
      Write(3,  ZahlI(Ein.P.Nummer) +'/ '+ ZahlI(Ein.P.Position)                       ,y ,0 , 3.0);
      Write(4,  Ein.P.LieferantenSW                                                    ,n ,0);
      Write(5,  Ein.AB.Nummer                                                          ,y ,0);
      Write(6,  ZahlI(Ein.P.Projektnummer)                                             ,y ,_LF_Int,3.0);
      if(Ein.E.Lageradresse <>0) then
      RecLink(100,501,11,_recFirst);
      Write(7,  Adr.Stichwort                                                          ,n ,0);
      //Write(7, ZahlI(Ein.E.Lageradresse)                                             ,y ,_LF_Int);
      //Write(8,
      Write(8,  Ein.E.Coilnummer                                                       ,n ,0);
      if (List_XML = y)then
        Write(9,  ZahlF(Ein.E.Gewicht, Set.Stellen.Gewicht)                            ,y ,_LF_NUM);
      else
        Write(9,  ZahlF(Ein.E.Gewicht, Set.Stellen.Gewicht) +' '+ Ein.P.MEH            ,y ,0);
      Write(10, ZahlF(vEinzel,2)                                                       ,y , _LF_NUM);
      Write(11, ZahlF(vGesamt,2)                                                       ,y , _LF_NUM);
      EndLine();

      AddSum(1,vGesamt);
      AddSum(2,Ein.E.Gewicht);
    end;

    'Summe' : begin
      StartLine(_LF_Overline + _LF_Bold);
      Write( 9, ZahlF(GetSum(2),Set.Stellen.Gewicht)                                   ,y , _LF_NUM);
      Write(11, ZahlF(GetSum(1),2)                                                     ,y , _LF_NUM);
      EndLine();
      ResetSum(1);
      ResetSum(2);
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
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vQ4         : alpha(4000);
  vQ5         : alpha(4000);
  vQ6         : alpha(4000);
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion öffnen

  // Selektionsquery für 506
  vQ # '';
  Lib_Sel:QAlpha(var vQ, '"Ein.E.Löschmarker"', '!=', '*');
  if ( Sel.Auf.von.Nummer != 0 ) or ( Sel.Auf.bis.Nummer != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Ein.E.Nummer', Sel.Auf.von.Nummer, Sel.Auf.bis.Nummer );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, '"Ein.E.Eingang_Datum"', Sel.von.Datum, Sel.bis.Datum );
  if ( "Sel.Auf.Güte" != '') then
    Lib_Sel:QAlpha( var vQ, '"Ein.E.Güte"', '=*', "Sel.Auf.Güte" );
  if ( Sel.Auf.von.Dicke != 0.0 ) or ( Sel.Auf.bis.Dicke != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.E.Dicke', Sel.Auf.von.Dicke, Sel.Auf.bis.Dicke );
  if ( Sel.Auf.von.Breite != 0.0 ) or ( Sel.Auf.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, 'Ein.E.Breite', Sel.Auf.von.Breite, Sel.Auf.bis.Breite );
  if ( "Sel.Auf.von.Länge" != 0.0 ) or ( "Sel.Auf.bis.Länge" != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ, '"Ein.E.Länge"', "Sel.Auf.von.Länge", "Sel.Auf.bis.Länge" );
  if ( Sel.Auf.ObfNr != 0) or ( Sel.Auf.ObfNr2 != 999) then begin
    if (vQ != '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Ausf) > 0 ';
  end;
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Kopf) > 0 OR LinkCount(KopfA) > 0 ) ';
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Pos) > 0 OR LinkCount(PosA) > 0 ) ';

  // Selektionsquery für 501
  vQ2 # '';
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ2, 'Ein.P.Lieferantennr', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.Anlage.Datum', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != 01.01.2010) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.TerminZusage', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != 01.01.2010) then
    Lib_Sel:QVonBisD( var vQ2, 'Ein.P.Termin1Wunsch', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Warengruppe', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ2, 'Ein.P.Wgr.Dateinr', '>=', 200 );
  Lib_Sel:QInt( var vQ2, 'Ein.P.Wgr.Dateinr', '<=', 209 );

  // Selektionsquery für 500
  vQ3 # '';
  Lib_Sel:QAlpha(var vQ3, '"Ein.Vorgangstyp"', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ3, 'Ein.Sachbearbeiter', '=', Sel.Auf.Sachbearbeit );

  // Selektionsquery für 511
  vQ4 # '';
  if ( Sel.Auf.Lieferantnr != 0 ) then
    Lib_Sel:QInt( var vQ4, '"Ein~P.Lieferantennr"', '=', Sel.Auf.Lieferantnr );
  if ( Sel.Auf.von.Datum != 0.0.0) or ( Sel.Auf.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.Anlage.Datum"', Sel.Auf.von.Datum, Sel.Auf.bis.Datum );
  if ( Sel.Auf.von.ZTermin != 0.0.0) or ( Sel.Auf.bis.ZTermin != 01.01.2010) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.TerminZusage"', Sel.Auf.von.ZTermin, Sel.Auf.bis.ZTermin );
  if ( Sel.Auf.von.WTermin != 0.0.0) or ( Sel.Auf.bis.WTermin != 01.01.2010) then
    Lib_Sel:QVonBisD( var vQ4, '"Ein~P.Termin1Wunsch"', Sel.Auf.von.WTermin, Sel.Auf.bis.WTermin );
  if ( Sel.Auf.von.Wgr != 0 ) or ( Sel.Auf.bis.Wgr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Warengruppe"', Sel.Auf.von.Wgr, Sel.Auf.bis.Wgr );
  if ( Sel.Auf.von.AufArt != 0 ) or ( Sel.Auf.bis.AufArt != 999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt );
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.bis.Projekt != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ4, '"Ein~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.bis.Projekt );
  Lib_Sel:QInt( var vQ4, '"Ein~P.Wgr.Dateinr"', '>=', 200 );
  Lib_Sel:QInt( var vQ4, '"Ein~P.Wgr.Dateinr"', '<=', 209 );

  // Selektionsquery für 510
  vQ5 # '';
  Lib_Sel:QAlpha(var vQ5, '"Ein~Vorgangstyp"', '=', c_Bestellung);
  if ( Sel.Auf.Sachbearbeit != '') then
    Lib_Sel:QAlpha( var vQ5, '"Ein~Sachbearbeiter"', '=', Sel.Auf.Sachbearbeit );

  //Selektionsquery für 507
  vQ6 # '';
  if ( Sel.Auf.ObfNr != 0 ) or ( Sel.Auf.ObfNr2 != 999 ) then
    Lib_Sel:QVonBisI( var vQ6, 'Ein.E.AF.ObfNr', Sel.Auf.ObfNr, Sel.Auf.ObfNr2 );

  // Selektion starten...
  vSel # SelCreate( 506, 1 );
  vSel->SelAddLink('', 501, 506, 1, 'Pos');
  vSel->SelAddLink('', 500, 506, 2, 'Kopf');
  vSel->SelAddLink('', 511, 506, 11, 'PosA');
  vSel->SelAddLink('', 510, 506, 10, 'KopfA');
  vSel->SelAddLink('', 507, 506, 13, 'Ausf');
  vSel->SelDefQuery('', vQ );
  vSel->SelDefQuery('Pos', vQ2 );
  vSel->SelDefQuery('Kopf',  vQ3 );
  vSel->SelDefQuery('PosA',  vQ4 );
  vSel->SelDefQuery('KopfA', vQ5 );
  vSel->SelDefQuery('Ausf',  vQ6 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // Aufruf Altversion
  //vSelName # Sel_Build(vSel, 506, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(506,vSel,vFlag) <= _rLocked ) DO BEGIN
    Erx # RecLink(501,506,1,_recFirst);
    if (Erx > _rLocked) then begin
      Erx # RecLink(511,506,11,_recFirst);
      if (Erx > _rLocked) then RecBufClear(511);
      RecBufCopy(511,501);
    end;
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    if (aSort=1) then vSortKey # cnvAI(Ein.E.Nummer,_FmtNumLeadZero,0,9);
    if (aSort=2) then vSortKey # Ein.P.LieferantenSW;
    if (aSort=3) then vSortKey # cnvAI(cnvID(Ein.E.Eingang_Datum),_FmtNumNoGroup | _FmtNumLeadZero,0,6);
    Sort_ItemAdd(vTree,vSortKey,506,RecInfo(506,_RecId));
  END;
  SelClose(vSel);
  SelDelete(506, vSelName);
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

    Print('Position');

  END;
  Print('Summe'); //Summen drucken

  // Löschen der Liste
  Sort_KillList(vTree);

  ListTerm();
end;

//========================================================================
