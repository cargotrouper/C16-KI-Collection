@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460006
//                    OHNE E_R_G
//  Info        Offene Posten Gesamtliste OHNE MWST
//
//
//  02.08.2010  AI  Erstellung der Prozedur
//  14.04.2015  TM  Korrektur: NettoW1 Summe enthielt auch Rechnungen mit Restwert €0,00
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint: logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
declare AusSel();
declare StartList(aSort : int; aSortName : alpha);

local begin
  g_Empty     : int;
  g_Alpha01   : int;
  g_Header    : int;
  g_Posten    : int;
  g_Summe1    : int;
  g_Summe2    : int;
  g_Summe3    : int;
end;

define begin
  cSumGesGesamtNetto    : 6
  cSumKdNetto           : 7

end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);
  Sel.Adr.von.KdNr          # 0;
  Sel.von.Datum             # 0.0.0;
  Sel.bis.Datum             # today;
  Sel.von.Datum2            # 0.0.0;
  Sel.bis.Datum2            # 31.12.2020;
  "Sel.Fin.!GelöschteYN"    # y;
  "Sel.Fin.GelöschteYN"     # n;
  Sel.Fin.nurMarkeYN        # n;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.460006',here + ':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
  RETURN;
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
  vHdl2->WinLstDatLineAdd('Rechnungsnummer');
  vHdl2->WinLstDatLineAdd('Fälligkeit');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
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
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx     : int;
  vLine   : int;
  vReTage : int;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'HEADER' : begin
      if (aPrint) then RETURN;

      List_Spacing[ 1] #  0.0;
      List_Spacing[ 2] # List_Spacing[ 1] + 40.0; // KundenSW
      List_Spacing[ 3] # List_Spacing[ 2] + 00.0; // Länderkennzeichen
      List_Spacing[ 4] # List_Spacing[ 3] + 15.0; // KuNr
      List_Spacing[ 5] # List_Spacing[ 4] + 25.0; // Kreditvers.
      List_Spacing[ 6] # List_Spacing[ 5] + 25.0; // intern KV
      List_Spacing[ 7] # List_Spacing[ 6] + 20.0; // ReNr
      List_Spacing[ 8] # List_Spacing[ 7] + 20.0; // ReDat
      List_Spacing[ 9] # List_Spacing[ 8] + 18.0; // ReTage
      List_Spacing[10] # List_Spacing[ 9] + 18.0; // Fälligkeit
      List_Spacing[11] # List_Spacing[10] + 13.0; // ü.Tage
      List_Spacing[12] # List_Spacing[11] + 30.0; // ReBetrag
      List_Spacing[13] # List_Spacing[12] + 30.0; // offen
      List_Spacing[14] # List_Spacing[13] + 12.0; // Vertreter
      List_Spacing[15] # List_Spacing[14] + 12.0; // Stufe
      List_Spacing[16] # List_Spacing[15] + 30.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1, 'Kundenstichwort'                      ,n , 0);
      if (List_XML) then
        LF_Set(2, 'LKZ'                               ,n , 0);
      LF_Set(3, 'Ku.Nr.'                               ,y , 0);
      LF_Set(4, 'Kreditvers.'+"Set.Hauswährung.Kurz"   ,y , 0);
      LF_Set(5, 'int.Limit.'+"Set.Hauswährung.Kurz"    ,y , 0);
      LF_Set(6, 'Re.Nr'                                ,y , 0);
      LF_Set(7, 'Re.Datum'                             ,y , 0);
      LF_Set(8, 'Re. Tage'                             ,y , 0);
      LF_Set(9, 'Fälligkeit'                           ,y , 0);
      LF_Set(10, 'ü.Tage'                               ,y , 0);
      LF_Set(11,'Nettobetrag ' + "Set.Hauswährung.Kurz"  ,y , 0);
      LF_Set(12, 'off.Betrag ' + "Set.Hauswährung.Kurz" ,y , 0);
      LF_Set(13,'Vertr.'                               ,y , 0);
      LF_Set(14,'Stufe'                                ,y , 0);
    end;


    'POSTEN' : begin
      if (aPrint) then begin
        Erx # RecLink(100,460,4,_recFirst);     // Kunde holen
        if(Erx > _rLocked) then
          RecBufClear(100);
        Erx # RecLink(103,100,14,_recFirst);    // Kreditlimit holen
        if(Erx > _rLocked) then
          RecBufClear(103);

        GV.alpha.01  # OfP.KundenStichwort;

        if(Adr.K.KurzLimit.Dat >= today) then
          LF_Text(4, ZahlF(Adr.K.KurzLimitW1,0));
        else
          LF_Text(4, ZahlF(Adr.K.VersichertW1,0));


        //if (Adr.K.InternLimit>0.0) then
          if(Adr.K.InternKurz.Dat >= today) then
            LF_Text(5, ZahlF(Adr.K.InternKurz,0));
          else
            LF_Text(5, ZahlF(Adr.K.InternLimit,0));
        //if (OfP.Rechnungsdatum<>0.0.0) then
          LF_Text(7, DatS(OfP.Rechnungsdatum));

        vReTage # cnvID(today) - cnvID(OfP.Rechnungsdatum);
        LF_Text(8, ZahlI(vReTage));

        //if (OfP.Zieldatum<>0.0.0) then
          LF_Text(9, DatS(OfP.Zieldatum));
        //if(OfP.Zieldatum <> 0.0.0) then
          LF_Text(10, ZahlI(cnvID(today) - cnvID(OfP.Zieldatum)));

        RETURN;
      end;


      LF_Set(1, '@OfP.KundenStichwort'        ,n , 0);
      if (List_XML) then
        LF_Set(2, '@Adr.Lkz'                  ,n , 0);
      LF_Set(3, '@OfP.Kundennummer'           ,y , _LF_INT);
      LF_Set(4, '#Adr.K.VersichertW1'         ,y , _LF_WAE);
      LF_Set(5, ''                            ,y , _LF_WAE);
      LF_Set(6, '@OfP.Rechnungsnr'            ,y , _LF_INT);
      LF_Set(7, ''                            ,y , _LF_Date);
      LF_Set(8, '0'                           ,y , _LF_Int);
      LF_Set(9,''                             ,y , _LF_Date);
      LF_Set(10,''                            ,y , _LF_Int);
      LF_Set(11,'@OfP.NettoW1'                ,y , _LF_WAE);
      LF_Set(12,'@OfP.RestW1'                 ,y , _LF_WAE);
      LF_Set(13,'@OfP.Vertreter'              ,y , _LF_INT);
      LF_Set(14,'@OfP.Mahnstufe'              ,y , _LF_INT);
    end;


    'SUMME1' : begin
      if (aPrint) then begin
        LF_Sum(11 ,cSumKdNetto, 2);
        LF_Sum(12 ,3, 2);
        Resetsum(3);
        Resetsum(cSumKdNetto);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(8, Gv.alpha.01   ,n,0);
      LF_Set(11,'SUM'         ,y, _LF_NUM);
      LF_Set(12,'SUM'         ,y, _LF_NUM);
    end;


    'SUMME2' : begin
      if (aPrint) then begin

        LF_Sum(11 ,cSumGesGesamtNetto, 2);
        LF_Sum(12 ,1, 2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(8, 'Gesamt:'                          ,n , 0);
      LF_Set(11,'SUM'                              ,y , _LF_WAE);
      LF_Set(12,'SUM'                              ,y , _LF_WAE);
    end;


    'SUMME3' : begin
      if (aPrint) then begin
        LF_Sum(12 ,2, 2);
        RETURN;
      end;

      LF_Set(8, 'Fällig:'                           ,n , 0);
      LF_Set(12, 'SUM'                              ,y , _LF_Wae);
    end;


  end;

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
    GV.alpha.01 # 'Rechnungsdatum: '+cnvad(Sel.von.Datum) +' bis '+cnvad(Sel.bis.Datum);
    LF_Print(g_Alpha01);
    LF_Print(g_Empty);
  end;

  LF_Print(g_Header);

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
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option

  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFIle,vMID : int;
  vOk         : logic;

  vKu         : int;
  vI          : int;
  vTree       : int;
  cSel        : int;
  vSortKey    : alpha;
  vQ          : alpha(4000);
  vQ100       : alpha(4000);
  vProgress   : int;
end;
begin

  // Selektionsquery
  vQ # '';
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'OfP.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.von.Datum2 != 0.0.0) or (Sel.bis.Datum2 != 31.12.2020) then
    Lib_Sel:QVonBisD(var vQ, 'OfP.Zieldatum', Sel.von.Datum2, Sel.bis.Datum2);
  if (Sel.Adr.von.Kdnr != 0)then
    Lib_Sel:QInt(var vQ, 'OfP.Kundennummer', '=', Sel.Adr.von.Kdnr);
  if (Sel.Adr.von.Vertret != 0)then
    Lib_Sel:QInt(var vQ, 'OfP.Vertreter', '=', Sel.Adr.von.Vertret);
  if (Sel.Adr.von.Verband != 0)then
    Lib_Sel:Qint(var vQ, 'OfP.Verband', '=', Sel.Adr.von.Verband);
  if ("Sel.Fin.GelöschteYN") and ("Sel.Fin.!GelöschteYN")then
    vQ # vQ
  else if ("Sel.Fin.GelöschteYN") and ("Sel.Fin.!GelöschteYN" = n)then
    Lib_Sel:QAlpha(var vQ, '"OfP.Löschmarker"', '=', '*');
  else if ("Sel.Fin.GelöschteYN" = n) and ("Sel.Fin.!GelöschteYN") then
    Lib_Sel:QAlpha(var vQ, '"OfP.Löschmarker"', '=', '');

  if(vQ <> '') then
    vQ # vQ + ' AND LinkCount(Kunde) > 0';
  else
    vQ # vQ + 'LinkCount(Kunde) > 0';

  vQ100 # '';
  if(Sel.Adr.von.Sachbear <> '') then
    Lib_Sel:QAlpha(var vQ100, 'Adr.Sachbearbeiter', '=' , Sel.Adr.von.Sachbear);

  // Sortierung setzen
  if (aSort=1) then vKey # 1;   // Rechnungsnummer
  if (aSort=2) then vKey # 4;   // Fälligkeit
  if (aSort=3) then vKey # 3;   // Kundenstichwort

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  //Bestand-Selektionr
  If (Sel.Fin.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate(460, vKey);
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->SelRead(460,_SelLock,vSelName);   // Selektion laden

    //vSelName # Sel_Build(vSel, 460, 'LST.460001',n,vKey);

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 460) then begin
        RecRead(460,0,_RecId,vMID);
        //SelRecInsert(vTree,460);
        if (aSort=1) then vSortKey # cnvAI("OfP.Rechnungsnr");   // Rechnungsnummer
        if (aSort=2) then vSortKey # cnvAI(cnvID("OfP.Zieldatum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);   // Fälligkeit
        if (aSort=3) then vSortKey # "OfP.KundenStichwort";   // Kundenstichwort
        Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin

    // Bestand
    // Selektion starten...
    vSel # SelCreate(460, vKey);
    vSel->SelAddLink('', 100, 460, 4, 'Kunde');
    vSel->SelDefQuery('', vQ);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    vSel->SelDefQuery('Kunde', vQ100);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);

    vSelName # Lib_Sel:SaveRun(var vSel, 0);

    // Bestand
    //vSelName # Sel_Build(vSel, 460, 'LST.460001',y,vKey);
    vFlag # _RecFirst;
    WHILE (RecRead(460,vSel,vFlag) <= _rLocked)DO BEGIN
      if (vFlag=_RecFirst) then vFlag # _RecNext;
      if (aSort=1) then vSortKey # cnvAI("OfP.Rechnungsnr");   // Rechnungsnummer
      if (aSort=2) then vSortKey # cnvAI(cnvID("OfP.Zieldatum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);   // Fälligkeit
      if (aSort=3) then vSortKey # "OfP.KundenStichwort";   // Kundenstichwort
      Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));
    END;
    SelClose(vSel);
    SelDelete(460, vSelName);
    vSel # 0;


    //Ablage
    if ("Sel.Fin.GelöschteYN") then begin

      // Selektionsquery
      vQ # '';
      if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
        Lib_Sel:QVonBisD(var vQ, '"OfP~Rechnungsdatum"', Sel.von.Datum, Sel.bis.Datum);
      if (Sel.Adr.von.Kdnr != 0)then
        Lib_Sel:QInt(var vQ, '"OfP~Kundennummer"', '=', Sel.Adr.von.Kdnr);
      if (Sel.von.Datum2 != 0.0.0) or (Sel.bis.Datum2 != 31.12.2020) then
        Lib_Sel:QVonBisD(var vQ, 'OfP~Zieldatum', Sel.von.Datum2, Sel.bis.Datum2);
      if (Sel.Adr.von.Vertret != 0)then
        Lib_Sel:QInt(var vQ, 'OfP~Vertreter', '=', Sel.Adr.von.Vertret);
      if (Sel.Adr.von.Verband != 0)then
        Lib_Sel:Qint(var vQ, 'OfP~Verband', '=', Sel.Adr.von.Verband);
      if ("Sel.Fin.GelöschteYN") and ("Sel.Fin.!GelöschteYN")then
        vQ # vQ
      else if ("Sel.Fin.GelöschteYN") and ("Sel.Fin.!GelöschteYN" = n)then
        Lib_Sel:QAlpha(var vQ, '"OfP~Löschmarker"', '=', '*');
      else if ("Sel.Fin.GelöschteYN" = n) and ("Sel.Fin.!GelöschteYN") then
        Lib_Sel:QAlpha(var vQ, '"OfP~Löschmarker"', '=', '');

      if(vQ <> '') then
        vQ # vQ + ' AND LinkCount(KundeAbl) > 0';
      else
        vQ # vQ + 'LinkCount(KundeAbl) > 0';


      // Selektion starten...
      vSel # SelCreate(470, 1);
      vSel->SelAddLink('', 100, 470, 4, 'KundeAbl');
      vSel->SelDefQuery('', vQ);
      if (Erx <> 0) then
        Lib_Sel:QError(vSel);
      vSel->SelDefQuery('KundeAbl', vQ100);
      if (Erx <> 0) then
        Lib_Sel:QError(vSel);
      vSelName # Lib_Sel:SaveRun(var vSel, 0);

      //vSelName # Sel_Build(vSel, 470, 'LST.460001',y,0);
      vFlag # _RecFirst;
      WHILE (RecRead(470,vSel,vFlag) <= _rLocked)DO BEGIN
        if (vFlag=_RecFirst) then vFlag # _RecNext;
        if (aSort=1) then vSortKey # cnvAI("OfP~Rechnungsnr");   // Rechnungsnummer
        if (aSort=2) then vSortKey # cnvAI(cnvID("OfP~Zieldatum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);   // Fälligkeit
        if (aSort=3) then vSortKey # "OfP~KundenStichwort";   // Kundenstichwort
        Sort_ItemAdd(vTree,vSortKey,470,RecInfo(470,_RecId));
      END;
      SelClose(vSel);
      SelDelete(470, vSelName);
      vSel # 0;
    end;

  end;


  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Alpha01   # LF_NewLine('ALPHA01');
  g_Header    # LF_NewLine('HEADER');
  g_Posten    # LF_NewLine('POSTEN');
  g_Summe1    # LF_NewLine('SUMME1');
  g_Summe2    # LF_NewLine('SUMME2');
  g_Summe3    # LF_NewLine('SUMME3');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  vKu # -1;
  vI  # 0;
  vFlag # _RecFirst;
  GV.alpha.01 # '';

  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    // Ablage?
    if (CnvIA(vItem->spCustom)=470) then
      RecBufCopy(470,460);

    if (aSort=3) and (vKu<>OfP.Kundennummer) and (vKu<>-1) then begin
      if (vI>0) and (GetSum(3)<>0.0) then
        LF_Print(g_Summe1);
      LF_Print(g_Empty);
      vI # 0;
    end;
    vKu # OfP.Kundennummer;

    vI # vI + 1;

    // if... durch if...begin getauscht - 2015-04-14 TM
    // if (Rnd(OfP.RestW1,2) <> 0.0) then
    //   LF_Print(g_Posten);


    if (Rnd(OfP.RestW1,2) <> 0.0) then begin
      LF_Print(g_Posten);

      AddSum(1,OfP.RestW1)
      AddSum(3,OfP.RestW1);
      AddSum(cSumGesGesamtNetto, OfP.NettoW1);
      AddSum(cSumKdNetto, OfP.NettoW1);

      if (OfP.Zieldatum<today) then begin
        AddSum(2,OfP.RestW1)
      end;
    end; // 2015-04-14 TM

  END;

  // Löschen der Liste
  Sort_KillList(vTree);

  if (aSort=3) and (vI>1) and (GetSum(3)<>0.0) then begin
    LF_Print(g_Summe1);
  end;


  LF_Print(g_Summe2);
  LF_Print(g_Summe3);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Alpha01);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Posten);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);
  LF_FreeLine(g_Summe3);

end;

//========================================================================