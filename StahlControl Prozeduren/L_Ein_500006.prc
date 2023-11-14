@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500006
//                    OHNE E_R_G
//  Info        Lieferantenbeurteilung nach Termin
//
//
//  03.09.2007  NH  Erstellung der Prozedur
//  30.07.2008  DS  QUERY
//  16.10.2013  AH  Anfragenx
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile :  501
  cSel  : 'LST.500005_6'
  cMask : 'SEL.LST.500005_6'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.bis.Datum     # today;

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
  vHdl2->WinLstDatLineAdd(Translate('Bestellnr'));
  vHdl2->WinLstDatLineAdd(Translate('Güte * Abmessungen'));
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
local begin
  Erx   : int;
  vFlag : int;
end;
begin

  WriteTitel();   // Drucke grosse Überschrift
  StartLine();
  EndLine();
  if (aSeite=1) then begin
    List_Spacing[ 1]  #   0.0;
    List_Spacing[ 2]  #   100.0;

    Adr.LieferantenNr # Sel.Adr.von.LiNr;
    Erx # RecRead(100, 3, 0); // Lieferanten holen
    if(Erx > _rMultiKey) then
      RecBufClear(100);

    if(Adr.LieferantenNr <> 0) then begin
      StartLine();
      Write( 1, 'Lieferant: ' + Adr.Stichwort                         ,n , 0);
      EndLine();
    end;

    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  # 0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 15.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 23.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 20.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 55.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 35.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 48.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 18.0;
  List_Spacing[10]  # List_Spacing[ 9] + 18.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Bestellnr.'                           ,y , 0);
  Write(2,  'Pos.'                                 ,y , 0, 3.0);
  Write(3,  'Best.Dat'                             ,n , 0);
  Write(4,  'Güte'                                 ,n , 0);
  Write(5,  'Abmessungen'                          ,y , 0);
  Write(6,  'Wunschdatum'                          ,y , 0);
  Write(7,  'Letzt. Wareneing.'                    ,y , 0);
  Write(8,  'zu früh'                              ,y , 0);
  Write(9,  'zu spät'                              ,y , 0);
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
local begin
  vdat : int;
  vFlag : int;
end;
begin
   case aName of

    'Position' : begin
      StartLine();
      Write(1, ZahlI(Ein.P.Nummer)                                                                                                                                        ,y , _LF_INT);
      Write(2, ZahlI(Ein.P.Position)                                                                                                                                      ,y , _LF_INT, 3.0);
      RecLink(500,501,3,_RecFirst);
      Write(3, DatS(Ein.Datum)                                                                                                                                           ,n , 0);
      Write(4,  "Ein.P.Güte"                                                                                                                                              ,n , 0);
      Write(5, ZahlF(Ein.P.Dicke,Set.Stellen.Dicke) + ' x ' +  ZahlF(Ein.P.Breite,Set.Stellen.Breite) + ' x ' + ZahlF("Ein.P.Länge","Set.Stellen.Länge")                  ,y , 0);

      vFlag # _RecFirst;
      WHILE (RecLink(506,501,14,vFlag) <= _rLocked ) DO BEGIN
        vFlag # _RecNext;
          if ( Ein.E.VSBYN = y ) then
            if ( vdat < cnvID(Ein.E.VSB_Datum) ) then vdat # cnvID(Ein.E.VSB_Datum);
          if (Ein.E.EingangYN = y) then
            if ( vdat < cnvID(Ein.E.Eingang_Datum) ) then vdat # cnvID(Ein.E.Eingang_Datum);
          if (Ein.E.AusfallYN = y) then
            if ( vdat < cnvID(Ein.E.Ausfall_Datum) ) then vdat # cnvID(Ein.E.Ausfall_Datum );
      END;

      Write(6,  DatS(Ein.P.Termin1Wunsch)                                                                                    ,y , _LF_Date);
      Write(7,  DatS(cnvDI(vdat))                                                                                      ,y , _LF_Date);

      vdat # vdat - cnvID(Ein.P.Termin1Wunsch)
      if vdat < 0 then
        Write(8,  AInt(abs(vdat))  ,y , 0);
      else if vdat > 0 then
        Write(9, AInt(vdat)   ,y , 0);
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
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery 501
  vQ # '';
  if(Sel.Adr.von.LiNr <> 0) then
    Lib_Sel:QInt( var vQ, 'Ein.P.Lieferantennr', '=', Sel.Adr.von.LiNr );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Ein.P.Termin1Wunsch', Sel.von.Datum, Sel.bis.Datum );
  Lib_Sel:QAlpha( var vQ, '"Ein.P.Löschmarker"', '=', '*' );

  // Selektion starten...
  vSel # SelCreate( 501, 1 );
  vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  // BESTAND-Selektion öffnen
  //vSelName # Sel_Build(vSel, 501, cSel,y,0);

  FOR Erx # RecRead(501,vSel,_recfirst)
  LOOP Erx # RecRead(501,vSel,_recNext)
  WHILE (Erx <= _rLocked ) DO BEGIN

    RekLink(500,501,3,_recFirst); // Kopf holen
    if ("Ein.Vorgangstyp"<>c_Bestellung) then CYCLE;
    RecLink(506,501,14,_RecFirst);
    if (aSort=1) then vSortKey # cnvai(Ein.E.Eingangsnr,_FmtNumLeadZero,0,9);
    if (aSort=2) then vSortKey # "Ein.P.Güte" + cnvaf(Ein.P.Dicke,_FmtNumLeadZero|_FmtNumNoGroup,0,3,8) + cnvaf(Ein.P.Breite,_FmtNumLeadZero|_FmtNumNoGroup,0,2,10) + cnvaf("Ein.P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);;
    Sort_ItemAdd(vTree,vSortKey,501,RecInfo(501,_RecId));
  END;
  SelClose(vSel);
  SelDelete(501, vSelName);
  vSel # 0;

  // ABLAGE-Selektion öffnen

  // Selektionsquery 511
  vQ # '';
  Lib_Sel:QInt( var vQ, '"Ein~P.Lieferantennr"', '=', Sel.Adr.von.LiNr );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, '"Ein~P.Termin1Wunsch"', Sel.von.Datum, Sel.bis.Datum );
  Lib_Sel:QAlpha( var vQ, '"Ein~P.Löschmarker"', '=', '*' );

  // Selektion starten...
  vSel # SelCreate( 511, 1 );
  vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 511, cSel,y,0);
//  16.10.2013  AH  Anfragenx
  FOR Erx # RecRead(511,vSel,_recfirst)
  LOOP Erx # RecRead(511,vSel,_recNext)
  WHILE (Erx <= _rLocked ) DO BEGIN
    RekLink(510,511,3,_recFirst); // Kopf holen
    if ("Ein~Vorgangstyp"<>c_Bestellung) then CYCLE;
    RecLink(506,511,14,_RecFirst);
    if (aSort=1) then vSortKey # cnvAI(Ein.E.Eingangsnr,_FmtNumLeadZero,0,9);
    if (aSort=2) then vSortKey # "Ein~P.Güte" + cnvaf("Ein~P.Dicke",_FmtNumLeadZero|_FmtNumNoGroup,0,3,8) + cnvaf("Ein~P.Breite",_FmtNumLeadZero|_FmtNumNoGroup,0,2,10) + cnvaf("Ein~P.Länge",_FmtNumLeadZero|_FmtNumNoGroup,0,0,12);;
    Sort_ItemAdd(vTree,vSortKey,511,RecInfo(511,_RecId));
  END;
  SelClose(vSel);
  SelDelete(511, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape


//  List_FontSize # 7;  FONTGRÖSSE ÄNDERN!

  // Durchlaufen und löschen
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    If (CnvIA(vItem->spCustom)=511) then RecBufCopy(511,501);

    Print('Position');
  END;

  // Löschen der Liste
  Sort_KillList(vTree);
  ListTerm();
end;

//========================================================================