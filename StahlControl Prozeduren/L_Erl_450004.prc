@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450004
//                    OHNE E_R_G
//  Info        Artikelumsatz
//
//
//  31.01.2007  AI  Erstellung der Prozedur
//  24.07.2008  DS  QUERY
//  03.08.2009  ST  Anpassung auf Querdruck
//  08.09.2016  AH  neue Selektion "Vorgangsart"
//  14.12.2021  AH  Cust für BCS
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List

define begin
  dMenge  : Gv.Num.01
  dUms    : Gv.Num.02
  dEK     : Gv.Num.03
  dRG     : Gv.Num.04
  dSumH   : Gv.Num.05
end;

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vMDI : int;
end;
begin
  RecBufClear(998);
  Sel.bis.Datum           # today;
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Auf.bis.AufArt      # 9999;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450004',here+':AusSel');
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

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');

  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Artikelgruppe');
  vHdl2->WinLstDatLineAdd('Warengruppe');
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();

  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end
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

//  List_Spacing[ 1]  #  0.0;
//  List_Spacing[ 2]  # 150.0;
//  List_Spacing[ 3]  # 170.0;
//  List_Spacing[ 4]  # 190.0;
//  StartLine();
//  WriteTitel(1,Lfm.Name, n, _LF_Titel );
//  Write(2,'Datum :' ,n,0);
//  Write(3,'Seite :' ,n,0);
//  EndLine();

  WriteTitel();
  StartLine();
  EndLine();

  if (aSeite=1) then begin
    StartLine();
    Write(1,'Zeitraum: '+cnvad(Sel.von.Datum)+' bis '+cnvad(Sel.bis.Datum) ,n , 0);
    EndLine();
    StartLine();
    Write(1,'Artikelnummer: '+Sel.Art.von.ArtNr+' bis '+Sel.Art.bis.ArtNr ,n , 0);
    EndLine();
    StartLine();
    Write(1,'Artikelgruppe: '+AInt(Sel.Art.von.ArtGR)+' bis '+AInt(Sel.Art.bis.ArtGR),n , 0);
    EndLine();
    StartLine();
    Write(1,'Warengruppe  : '+AInt(Sel.Art.von.WGR)+' bis '+AInt(Sel.Art.bis.WGR) ,n ,0);
    EndLine();
    StartLine();
    Write(1,'Auftragsart: '+aint(Sel.Auf.von.AufArt)+' bis '+aint(Sel.Auf.Bis.AufArt) ,n , 0);
    EndLine();
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 50.0;
  List_Spacing[ 3]  # 100.0;
  List_Spacing[ 4]  # 130.0;
  List_Spacing[ 5]  # 140.0;
  List_Spacing[ 6]  # 165.0;
  List_Spacing[ 7]  # 175.0;
  List_Spacing[ 8]  # 210.0;
  List_Spacing[ 9]  # 240.0;
  List_Spacing[10]  # 270.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Artikelnummer'                  ,n , 0);
  Write(2, 'Stichwort'                      ,n , 0);
  Write(3, 'Wgr.'                           ,y , 0, 2.0);
  Write(4, 'Agr.'                           ,y , 0, 2.0);
  Write(5, 'Menge'                          ,y , 0, 2.0);
  Write(6, 'MEH'                            ,n , 0, 2.0);
  Write(7, 'Umsatz '+"Set.Hauswährung.Kurz" ,y , 0, 2.0);
  Write(8, 'EKWert '+"Set.Hauswährung.Kurz" ,y , 0, 2.0);
  Write(9, 'RG '+"Set.Hauswährung.Kurz"     ,y , 0, 2.0);
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
      Write(1, Art.Nummer                       ,n , 0);
      Write(2, Art.Stichwort                    ,n , 0);
      Write(3, ZahlI(Art.Warengruppe)           ,y , _LF_INT, 2.0);
      Write(4, ZahlI(Art.Artikelgruppe)         ,y , _LF_INT, 2.0);
      Write(5, ZahlF(dMenge,2)                  ,y , _LF_WAE, 2.0);
      Write(6, Art.MEH                          ,n , 0, 2.0);
      Write(7, ZahlF(dUms,2)                    ,y , _LF_WAE, 2.0);
      Write(8, ZahlF(dEK,2)                     ,y , _LF_WAE, 2.0);
      Write(9, ZahlF(dRG,2)                     ,y , _LF_WAE, 2.0);
      EndLine();
      AddSum(1,dUms)
      AddSum(2,dEK);
      AddSum(3,dRG);
      AddSum(11,dUms);
      AddSum(12,dEK);
      AddSum(13,dRG);

    end;


    'WgrSumme' : begin

      StartLine(_LF_Overline);
      Write(1, Wgr.Bezeichnung.L1                 ,y , 0, 2.0);
      Write(7, ZahlF(GetSum(11),2)                ,y , _LF_WAE, 2.0);
      Write(8, ZahlF(GetSum(12),2)                ,y , _LF_WAE, 2.0);
      Write(9, ZahlF(GetSum(13),2)                ,y , _LF_WAE, 2.0);
      EndLine();

      ResetSum(11);
      ResetSum(12);
      ResetSum(13);
      StartLine();
      EndLine();

    end;


    'AgrSumme' : begin

      StartLine(_LF_Overline);
      Write(1, Agr.Bezeichnung.L1                 ,y , 0, 2.0);
      Write(7, Zahlf(GetSum(11),2)                ,y , _LF_WAE, 2.0);
      Write(8, ZahlF(GetSum(12),2)                ,y , _LF_WAE, 2.0);
      Write(9, ZahlF(GetSum(13),2)                ,y , _LF_WAE, 2.0);
      EndLine();

      ResetSum(11);
      ResetSum(12);
      ResetSum(13);
      StartLine();
      EndLine();

    end;

  end; // CASE

end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
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
  tErx        : int;
  tErx2       : int;
end;
begin
  dSumH # 0.0;
  
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 404
  vQ # '';
  Lib_Sel:QAlpha( var vQ, 'Auf.A.Artikelnr', '>', '' );
  Lib_Sel:QInt( var vQ, 'Auf.A.Rechnungsnr', '>', 0 );
  if ( Sel.Art.von.ArtNr != '' ) or ( Sel.Art.bis.ArtNr != 'zzz' ) then
    Lib_Sel:QVonBisA( var vQ, 'Auf.A.ArtikelNr', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Artikel) > 0 ';

  // Selektionsquery für 250
  if ( Sel.Art.von.WGr != 0 ) or ( Sel.Art.bis.WGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr );
  if ( Sel.Art.von.ArtGr != 0 ) or ( Sel.Art.bis.ArtGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr );

/***
SELECT Auf_Aktionen.Auf_A_Nummer, Auf_Aktionen.Auf_A_Position, Auf_Aktionen.Auf_A_Aktion, Auf_Aktionen.Auf_A_Aktionsnr, Auf_Aktionen.Auf_A_Aktionspos, Auf_Aktionen.Auf_A_ArtikelNr,
Art_Artikel.Art_Nummer, Art_Artikel.Art_Stichwort

FROM Art_Artikel Art_Artikel, Auf_Aktionen Auf_Aktionen

WHERE Auf_Aktionen.Auf_A_ArtikelNr = Art_Artikel.Art_Nummer AND
((Auf_Aktionen.Auf_A_ArtikelNr>='01-007') AND (Auf_Aktionen.Auf_A_Rechnungsnr>0) AND (Art_Artikel.Art_Stichwort<'T'))

ORDER BY Art_Artikel.Art_Stichwort

oder

SELECT Art_Nummer, Art_Stichwort, Art_Warengruppe, Wgr_Bezeichnung_L1
FROM Art_Artikel, Wgr_Warengruppen
WHERE (Art_Warengruppe=Wgr_Nummer) AND (NOT Wgr_Bezeichnung_L1 LIKE '%Arti%')

oder


SELECT Art_Nummer, Art_Stichwort, Art_Warengruppe, Wgr_Bezeichnung_L1
FROM Art_Artikel INNER JOIN Wgr_Warengruppen
ON (Art_Artikel.Art_Warengruppe=Wgr_Warengruppen.Wgr_Nummer)
WHERE (Art_Warengruppe=Wgr_Nummer) AND (NOT Wgr_Bezeichnung_L1 LIKE '%Arti%')

***/

  // Selektion starten...
  vSel # SelCreate( 404, 0 );
  vSel->SelAddSortFld(2,1,_KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,4,_KeyFldAttrUpperCase);
  vSel->SelAddLink('', 250, 404, 3, 'Artikel');
  tErx # vSel->SelDefQuery('', vQ );
  tErx2 # vSel->SelDefQuery('Artikel', vQ2 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // Selektion öffnen
  //vSelName # Sel_Build(vSel, 404, 'LST.450004',y,0);

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vFlag # _RecFirst;
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecLink(250,404,3,_recFirst);   // Artikel holen
    if (aSort=1) then
      vSortKey # Art.Nummer;
    if (aSort=2) then
      vSortkey # Cnvai(Art.Artikelgruppe,_FmtNumNoGroup|_FmtNumLeadZero,0,5);
    if (aSort=3) then
      vSortKey # Cnvai(Art.Warengruppe,_FmtNumNoGroup|_FmtNumLeadZero,0,5);
    Sort_ItemAdd(vTree,vSortKey,404,RecInfo(404,_RecId));
  END;

  // Selektion löschen
  SelClose(vSel);
  SelDelete(404,vSelName);
  vSel # 0;


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // AUSGABE ---------------------------------------------------------------

  ListInit(true); // Landscape

  dMenge  # 0.0;
  dEK     # 0.0;
  dUms    # 0.0;
  dRG     # 0.0;
  RecBufClear(250);
  RecBufClear(826);
  RecBufClear(819);
  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    // ab 08.09.2016:
    if (Sel.Auf.Von.AufArt<>0) or (Sel.Auf.Bis.AufArt<>9999) then begin
      Auf_Data:Read(Auf.A.Nummer, Auf.A.Position, false);
      if (Auf.P.Auftragsart<Sel.Auf.Von.AufArt) or (Auf.P.Auftragsart>Sel.Auf.Bis.AufArt) then begin
        vTree->Ctedelete(vItem);
        vItem # Sort_ItemFirst(vTree);
        CYCLE;
      end;
    end;


    if (Auf.A.Artikelnr<>Art.Nummer) then begin
      if (Art.Nummer<>'') then begin

        Print('Artikel');
        if (Set.Installname='BCS') and (Art.MEH='h') then dSumH # dSumH + dMenge;

        dMenge  # 0.0;
        dEK     # 0.0;
        dUms    # 0.0;
        dRG     # 0.0;
      end;
      RecLink(250,404,3,_recFirst);   // Artikel holen
      if (aSort=3) and (Wgr.Nummer<>Art.Warengruppe) and (Wgr.Nummer<>0) then Print('WgrSumme');
      if (aSort=2) and (Agr.Nummer<>Art.Artikelgruppe) and (Agr.Nummer<>0) then Print('AgrSumme');

      RecLink(826,250,11,_recFirst);  // AGr holen
      RecLink(819,250,10,_recfirst);  // Wgr holen
    end;

    dMenge  # dMenge  + Auf.A.Menge;
    dEK     # dEK     + (Auf.A.EKPreisSummeW1);
    dUms    # dUms    + (Auf.A.RechPreisW1); // * Auf.A.Menge);
    dRG     # dUms - dEK;

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree)
  END;

  if (Art.Nummer<>'') then begin
    Print('Artikel');
    if (aSort=3) then Print('WgrSumme');
    if (aSort=2) then Print('AgrSumme');
  end;



  StartLine(_LF_Overline);
  if (Set.Installname='BCS') then begin
    Write(2, 'Stundensumme'                   ,y , _LF_Bold + _LF_Wae,2.0);
    Write(5, Zahlf(dSumH,2)                   ,y , _LF_Bold + _LF_Wae,2.0);
    Write(6, 'h'                              ,n , 0, 2.0);
  end;
  Write(7, Zahlf(GetSum(1),2)                ,y , _LF_Bold + _LF_Wae,2.0);
  Write(8, ZahlF(GetSum(2),2)                ,y , _LF_Bold + _LF_Wae,2.0);
  Write(9, ZahlF(GetSum(3),2)                ,y , _LF_Bold + _LF_Wae,2.0);
  EndLine();

  ListTerm();


  // Löschen der Liste
  Sort_KillList(vTree);

end;
//========================================================================
