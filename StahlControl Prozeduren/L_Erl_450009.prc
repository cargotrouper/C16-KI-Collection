@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450009
//                    OHNE E_R_G
//  Info        Artikelumsatz Kunde
//
//
//  28.02.2008  DS  Erstellung der Prozedur
//  25.07.2008  DS  QUERY
//  22.01.2014  AH  neue Spalte "Grundpreis"
//  07.03.2014  ST  Dargestellte Menge ist jetzt Rechnungsmenge, nicht Aktionsmenge Projekt 1482/24
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//    Sub Print(aName : alpha);
//    sub SeitenKopf(aSeite : int);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.bis.Datum           # today;
  Sel.Auf.Kundennr        # 0;
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450009',here+':AusSel');
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
  vSort : int;
  vSortName : alpha;
end;
begin

  //Kunde ist Pflichtfeld
  if (Sel.Auf.Kundennr = 0) then begin
    Msg(001200, 'Kunde', _WinIcoWarning, _WinDialogOk,0);
    Call('L_Erl_450009');
    RETURN;
  end;

  // Rechnungsdatum bis Pflichtfeld
  if (Sel.bis.Datum = 0.0.0) then begin
    Msg(001200, 'Rechnungsdatum bis', _WinIcoWarning, _WinDialogOk,0);
    Call('L_Erl_450009');
    RETURN;
  end;

  Adr.KundenNr # Sel.Auf.Kundennr;
  if (Adr.KundenNr > 0) then
  RecRead(100,2,0);


  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');

  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->WinLstDatLineAdd('Artikelnummer*Rechnungsdatum');
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
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

  WriteTitel();
  StartLine();
  EndLine();
  if (aSeite=1) then begin

    StartLine();
    Write(1,'Kunde: '+AInt(Sel.Auf.Kundennr)+' '+Adr.Stichwort ,n , 0);
    EndLine();
    StartLine();
    Write(1,'Zeitraum: '+cnvad(Sel.von.Datum)+' bis '+cnvad(Sel.bis.Datum) ,n , 0);
    EndLine();
    StartLine();
    Write(1,'Artikelgruppe: '+AInt(Sel.Art.von.ArtGR)+' bis '+AInt(Sel.Art.bis.ArtGR),n , 0);
    EndLine();
    StartLine();
    Write(1,'Warengruppe: '+AInt(Sel.Art.von.WGR)+' bis '+AInt(Sel.Art.bis.WGR) ,n ,0);
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 25.0;
  List_Spacing[ 3]  # 55.0;
  List_Spacing[ 4]  # 75.0;
  List_Spacing[ 5]  # 95.0;
  List_Spacing[ 6]  # 115.0;
  List_Spacing[ 7]  # 125.0;
  List_Spacing[ 8]  # 150.0;
  List_Spacing[ 9]  # 180.0;
  List_Spacing[10]  # 210.0;
  List_Spacing[11]  # 230.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Artikel-Nr.'                         ,n , 0);
  Write(2, 'Stichwort'                           ,n , 0);
  Write(3, 'AuftragsNr.'                         ,n , 0);
  Write(4, 'Re-Datum'                            ,y , 0);
  Write(5, 'Menge'                               ,y , 0, 2.0);
  Write(6, 'MEH'                                 ,n , 0, 2.0);
  Write(7, 'Grundpreis '+"Set.Hauswährung.Kurz"  ,y , 0);
  Write(8, 'eff.'+"Set.Hauswährung.Kurz"+' VK / MEH',y , 0);
  Write(9, 'VKWert '+"Set.Hauswährung.Kurz"      ,y , 0);
  Write(10, 'RG '+"Set.Hauswährung.Kurz"         ,y , 0);
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
Sub Print(aName : alpha);
begin

  case aName of

    'Artikel' : begin
      StartLine();
      Write(1, Art.Nummer                                      ,n , 0);
      Write(2, Art.Stichwort                                   ,n , 0);
      Write(3, ZahlI(Auf.A.Nummer)+ '/ '+ZahlI(Auf.A.Position) ,n , 0);
      Write(4, DatS(Auf.A.Rechnungsdatum)                      ,y , _LF_DATE);
      Write(5, ZahlF(Auf.A.Menge.Preis,2)                   ,y , _LF_WAE, 2.0);    // ST 2014-03-07: vorher Auf.A.Menge
      Write(6, Art.MEH                                         ,n , 0, 2.0);

      if (Erl.K.Menge<>0.0) then
        Write(7, ZahlF(Erl.K.Betrag/Erl.K.Menge,2)         ,y , _LF_WAE)
      else
        Write(7, ZahlF(0.0,2)                                 ,y , _LF_WAE);

      if (Auf.A.Menge > 0.0) then
        Write(8, ZahlF(Auf.A.RechPreisW1/Auf.A.Menge,2)         ,y , _LF_WAE)
      else
        Write(8, ZahlF(0.0,2)                                 ,y , _LF_WAE);
      Write(9, ZahlF(Auf.A.RechPreisW1,2)                      ,y , _LF_WAE);
      Write(10, ZahlF(Auf.A.RechPreisW1-Auf.A.EKPreisSummeW1,2) ,y , _LF_WAE);
      EndLine();
      AddSum(1,Auf.A.RechPreisW1);
      AddSum(2,Auf.A.RechPreisW1-Auf.A.EKPreisSummeW1);
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
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
end;
begin

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 404
  vQ # '';
  Lib_Sel:QAlpha( var vQ, 'Auf.A.Artikelnr', '>', '' );
  Lib_Sel:QInt( var vQ, 'Auf.A.Rechnungsnr', '>', 0 );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Artikel) > 0 AND LinkCount(Kunde) > 0 ';

  // Selektionsquery für 250
  if ( Sel.Art.von.WGr != 0 ) or ( Sel.Art.bis.WGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr );
  if ( Sel.Art.von.ArtGr != 0 ) or ( Sel.Art.bis.ArtGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr );

  // Selektionsquery für 100
  Lib_Sel:QInt( var vQ3, 'Adr.KundenNr', '=', Sel.Auf.Kundennr );


  // Selektion starten...
  vSel # SelCreate( 404, 0 );
  vSel->SelAddSortFld(2,1,_KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,4,_KeyFldAttrUpperCase);
  vSel->SelAddLink('', 250, 404, 3, 'Artikel');
  vSel->SelAddLink('', 100, 404, 2, 'Kunde');
  vSel->SelDefQuery('', vQ );
  vSel->SelDefQuery('Artikel', vQ2 );
  vSel->SelDefQuery('Kunde', vQ3 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450009',y,0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vFlag # _RecFirst;
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecLink(250,404,3,_recFirst);   // Artikel holen
    if (aSort=1) then
      vSortKey # Cnvai(Cnvid(Auf.A.Rechnungsdatum));
    if (aSort=2) then
      vSortkey # Art.Nummer+Cnvai(Cnvid(Auf.A.Rechnungsdatum));
    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(404,vSelName);
  vSel # 0;


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // AUSGABE ---------------------------------------------------------------

  ListInit(y);  // Landscape

  RecBufClear(250);
  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    RecLink(250,404,3,_recFirst);   // Artikel holen

    RecBufClear(451);
    Erx # RecLink(450,404,9,_recFirst);   // Rechnung holen
    if (Erx<=_rLocked) then begin
      FOR Erx # RecLink(451,450,1,_RecFirst);   // Konten loopen
      LOOP Erx # RecLink(451,450,1,_RecNext);
      WHILE (Erx<=_rLocked) do begin
        // Grundpreis?
        if (Erl.K.Bemerkung=Translate('Grundpreis')) then BREAK;
      END;
      if (Erx>_rLocked) then RecBufClear(451);
    end;

    Print('Artikel');

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree)
  END;

  StartLine(_LF_Overline);
  Write(9, ZahlF(GetSum(1),2)                ,y , _LF_Bold + _LF_Wae);
  Write(10,ZahlF(GetSum(2),2)                ,y , _LF_Bold + _LF_Wae);
  EndLine();

  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================