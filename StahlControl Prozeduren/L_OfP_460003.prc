@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460003
//                    OHNE E_R_G
//  Info        Offene Posten RÜCKWIRKEND
//
//
//  22.04.2008  AI  Erstellung der Prozedur
//  20.05.2008  AI  Korrektur für Stornos + Gutschriften
//  23.07.2008  DS  QUERY
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List
declare AusSel();
declare StartList(aSort : int; aSortName : alpha);

define begin
  cSelName  : 'LST.460003'
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
  //"Sel.Fin.!GelöschteYN"    # y;
  //"Sel.Fin.GelöschteYN"     # n;
  //Sel.Fin.nurMarkeYN        # n;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.460003',here + ':AusSel');
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
    Write(1,'Rechnungsdatum: '+cnvad(Sel.von.Datum) +' bis '+cnvad(Sel.bis.Datum) ,n , 0);
    EndLine();
    StartLine();
    Write(1,'Stichtag: '+cnvad(Sel.von.Datum3) ,n , 0);
    EndLine();
    StartLine();
    EndLine();
  end;
/*
  List_Spacing[ 1]  #  0.0;
  List_Spacing[12]  # 200.0;
  List_Spacing[11]  # List_Spacing[12]  - 15.0; // Stufe
  List_Spacing[10]  # List_Spacing[11]  - 20.0; // Verband
  List_Spacing[ 9]  # List_Spacing[10]  - 15.0; // Vertr.
  List_Spacing[ 8]  # List_Spacing[ 9]  - 25.0; // Rest
  List_Spacing[ 7]  # List_Spacing[ 8]  - 25.0; // Netto
  List_Spacing[ 6]  # List_Spacing[ 7]  - 20.0; // Fälligkeit
  List_Spacing[ 5]  # List_Spacing[ 6]  - 20.0; // Re.Dat
  List_Spacing[ 4]  # List_Spacing[ 5]  - 15.0; // ReNr
  List_Spacing[ 3]  # List_Spacing[ 4]  - 30.0; // Kreditlimit
  List_Spacing[ 2]  # List_Spacing[ 3]  - 15.0; // KuNr
*/


  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Kundenstichwort'
  List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0; //  'Ku.Nr.'
  List_Spacing[ 4]  # List_Spacing[ 3]  + 30.0; //  'Kreditvers.'+"Set
  List_Spacing[ 5]  # List_Spacing[ 4]  + 30.0; //  'Re.Nr'
  List_Spacing[ 6]  # List_Spacing[ 5]  + 20.0; //  'Re.Datum'
  List_Spacing[ 7]  # List_Spacing[ 6]  + 20.0; //  'Fälligkeit'
  List_Spacing[ 8]  # List_Spacing[ 7]  + 30.0; //  'Re.Betrag '+"Set.
  List_Spacing[ 9]  # List_Spacing[ 8]  + 30.0; //  'off.Betrag '+"Set
  List_Spacing[10]  # List_Spacing[ 9]  + 20.0; //  'Vertr.'
  List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Verband'
  List_Spacing[12]  # List_Spacing[11]  + 20.0; //  'Stufe'
  List_Spacing[13]  # List_Spacing[12]  + 20.0; //



  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Kundenstichwort'                ,n , 0);
  Write(2, 'Ku.Nr.'                         ,y , 0);
  Write(3, 'Kreditvers.'+"Set.Hauswährung.Kurz"    ,y , 0);
  Write(4, 'Re.Nr'                          ,y , 0);
  Write(5, 'Re.Datum'                       ,y , 0);
  Write(6, 'Fälligkeit'                     ,y , 0);
  Write(7, 'Re.Betrag '+"Set.Hauswährung.Kurz"    ,y , 0);
  Write(8, 'off.Betrag '+"Set.Hauswährung.Kurz"   ,y , 0);
  Write(9, 'Vertr.'                         ,y , 0);
  Write(10,'Verband'                        ,y , 0);
  Write(11,'Stufe'                          ,y , 0);
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
  Erx : int;
end;
begin

  case aName of

    'Posten' : begin
      Erx # RecLink(100,460,4,_recFirst);     // Kunde holen
      if(Erx > _rLocked) then
        RecBufClear(100);

      Erx # RecLink(103,100,14,_recFirst);    // Kreditlimit holen
      if(Erx > _rLocked) then
        RecBufClear(103);
      StartLine();

//        if(GV.alpha.01<>OfP.KundenStichwort)then
      Write(1, OfP.KundenStichwort            ,n , 0);
      GV.alpha.01  # OfP.KundenStichwort;
      Write(2, ZahlI(OfP.Kundennummer)        ,y , _LF_INT);
      Write(3, ZahlF(Adr.K.VersichertW1,2)    ,y , _LF_WAE, 2.0);
      Write(4, ZahlI(OfP.Rechnungsnr)         ,y , _LF_INT);
      if (OfP.Rechnungsdatum<>0.0.0) then
        Write(5, DatS(OfP.Rechnungsdatum)       ,y , _LF_Date);
      if (OfP.Zieldatum<>0.0.0) then
        Write(6, DatS(OfP.Zieldatum)            ,y , _LF_Date);
      Write(7, ZahlF(OfP.BruttoW1,2)           ,y , _LF_WAE, 2.0);
      Write(8, ZahlF(OfP.RestW1,2)            ,y , _LF_WAE, 2.0);
      Write(9, ZahlI(OfP.Vertreter)           ,y , _LF_INT);
      Write(10,ZahlI(OfP.Verband)           ,y , _LF_INT);
      Write(11,ZahlI(OfP.Mahnstufe)           ,y , _LF_INT);

      EndLine();
    end;

    'Summe' : begin
      StartLine(_LF_Overline);
      Write(6, GV.alpha.01                    ,n , 0);
      Write(8, ZahlF(GetSum(3),2)             ,y , _LF_NUM, 2.0);
      EndLine();
      ResetSum(3);
    end;

    'Summe2' : begin
//      List_Spacing[ 5]  # 145.0;
//      List_Spacing[ 6]  # 160.0;
//      List_Spacing[ 7]  # 180.0;
//      List_Spacing[ 8]  # 190.0;
      StartLine(_LF_Overline);
      Write(6, 'Gesamt:'                          ,n , 0);
      Write(8, ZahlF(GetSum(1),2)                 ,y , _LF_WAE, 2.0);
      endline()

      startline()
      Write(6, 'Fällig:'                           ,n , 0);
      Write(8,  ZahlF(GetSum(2),2)                 ,y , _LF_Wae, 2.0);
      EndLine();
    end;

    'Leerzeile' : begin
      StartLine();
      EndLine();
      end;
  end;
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

  vBetrag     : float;
  vQ          : alpha(4000);
end;
begin

  // Selektionsquery
  vQ # '';
  //if (Sel.von.Datum3 != 0.0.0) then
  Lib_Sel:QDate(var vQ, 'OfP.Rechnungsdatum', '<=', Sel.von.Datum3);
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'OfP.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.von.Datum2 != 0.0.0) or (Sel.bis.Datum2 != 31.12.2020) then
    Lib_Sel:QVonBisD(var vQ, 'OfP.Zieldatum', Sel.von.Datum2, Sel.bis.Datum2);
  if (Sel.Adr.von.Kdnr != 0) then
    Lib_Sel:QInt(var vQ, 'OfP.Kundennummer', '=', Sel.Adr.von.Kdnr);
  if (Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt(var vQ, 'OfP.Vertreter', '=', Sel.Adr.von.Vertret);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ, 'OfP.Verband', '=', Sel.Adr.von.Verband);


  // Sortierung setzen
  if (aSort=1) then vKey # 1;   // Rechnungsnummer
  if (aSort=2) then vKey # 4;   // Fälligkeit
  if (aSort=3) then vKey # 3;   // Kundenstichwort

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Bestand
  // Selektion starten...
  vSel # SelCreate(460, vKey);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  //vSelName # Sel_Build(vSel, 460, cSelName,y,vKey);
  vFlag # _RecFirst;
  WHILE (RecRead(460,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (StrFind(Ofp.Bemerkung,'STORN',1)>0) then CYCLE;

    vBetrag # OfP.BruttoW1;
    Erx # RecLink(461,460,1,_recFirst);   // Zahlungen loopen
    WHILE (Erx<=_rLocked) do begin
      RecLink(465,461,2,_recFirst);       // Zahlungseingang holen
      if (ZEi.Zahldatum<=Sel.von.Datum3) then
        vBetrag  # vBetrag - OfP.Z.BetragW1 - OfP.Z.SkontobetragW1;
      Erx # RecLink(461,460,1,_recNext);
    END;

    if (Rnd(vBetrag,0)<>0.0) then begin
      if (aSort=1) then vSortKey # cnvAI("OfP.Rechnungsnr");   // Rechnungsnummer
      if (aSort=2) then vSortKey # cnvAI(cnvID("OfP.Zieldatum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);   // Fälligkeit
      if (aSort=3) then vSortKey # "OfP.KundenStichwort" + cnvAI("OfP.Rechnungsnr",_FmtNumNoGroup | _FmtNumLeadZero,0,8);   // Kundenstichwort
      Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));
    end;
  END;
  SelClose(vSel);
  SelDelete(460, vSelName);
  vSel # 0;

  //Ablage
  // Selektionsquery
  vQ # '';
  Lib_Sel:QDate(var vQ, 'OfP~Rechnungsdatum', '<=', Sel.von.Datum3);
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'OfP~Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Adr.von.Kdnr != 0) then
    Lib_Sel:QInt(var vQ, 'OfP~Kundennummer', '=', Sel.Adr.von.Kdnr);

  // Selektion starten...
  vSel # SelCreate(470, 1);
  Erx # vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  //vSelName # Sel_Build(vSel, 470, cSelName,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(470,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecBufCopy(470,460);

    if (StrFind(Ofp.Bemerkung,'STORN',1)>0) then CYCLE;

    vBetrag # OfP.BruttoW1;
    Erx # RecLink(461,460,1,_recFirst);   // Zahlungen loopen
    WHILE (Erx<=_rLocked) do begin
      RecLink(465,461,2,_recFirst);       // Zahlungseingang holen
      if (ZEi.Zahldatum<=Sel.von.Datum3) then
        vBetrag  # vBetrag - OfP.Z.BetragW1 - OfP.Z.SkontobetragW1;
      Erx # RecLink(461,460,1,_recNext);
    END;

    if (Rnd(vBetrag,0)<>0.0) then begin
      if (aSort=1) then vSortKey # cnvAI("OfP~Rechnungsnr");   // Rechnungsnummer
      if (aSort=2) then vSortKey # cnvAI(cnvID("OfP~Zieldatum"),_FmtNumNoGroup | _FmtNumLeadZero,0,6);   // Fälligkeit
      if (aSort=3) then vSortKey # "OfP~KundenStichwort" + cnvAI("OfP~Rechnungsnr",_FmtNumNoGroup | _FmtNumLeadZero,0,8);   // Kundenstichwort
      Sort_ItemAdd(vTree,vSortKey,470,RecInfo(470,_RecId));
    end;
  END;
  SelClose(vSel);
  SelDelete(470, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);  // Landscape

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
    If (CnvIA(vItem->spCustom)=470) then RecBufCopy(470,460);

    vBetrag # OfP.BruttoW1;
    Erx # RecLink(461,460,1,_recFirst);   // Zahlungen loopen
    WHILE (Erx<=_rLocked) do begin
      RecLink(465,461,2,_recFirst);       // Zahlungseingang holen
      if (ZEi.Zahldatum<=Sel.von.Datum3) then
        vBetrag  # vBetrag - OfP.Z.BetragW1 - OfP.Z.SkontobetragW1;
      Erx # RecLink(461,460,1,_recNext);
    END;
    OfP.RestW1 # vBetrag;

    if (Rnd(OfP.RestW1,0) = 0.0) then begin
      CYCLE;
    end;

    if (aSort=3) and (vKu<>OfP.Kundennummer) and (vKu<>-1) then begin
      if (vI>0) and (GetSum(3)<>0.0) then
        Print('Summe');
      Print('Leerzeile');
      vI # 0;
    end;
    vKu # OfP.Kundennummer;

    vI # vI + 1;

    Print('Posten')

    AddSum(1,OfP.RestW1)
    AddSum(3,OfP.RestW1);

    if (OfP.Zieldatum<today) then
      AddSum(2,OfP.RestW1)
  END;

  Print('EndSumme');
  // Löschen der Liste
  Sort_KillList(vTree);

  if (aSort=3) and (vI>1) and (GetSum(3)<>0.0) then begin
    Print('Summe');
  end;

  print('Summe2');

  ListTerm();

end;

//========================================================================