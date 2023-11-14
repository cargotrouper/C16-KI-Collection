@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Adr_100005
//                    OHNE E_R_G
//  Info        Liste Adressen + Kreditlimit Excel
//
//
//
//  27.11.2007  MS  Erstellung der Prozedur
//  07.07.2008  AI  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
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
//  StartList(0,'');  // Liste generieren

  RecBufClear(998);
  Sel.Adr.bis.KdNr # 9999999;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.100005',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;

//========================================================================
//  AusSel
//
//========================================================================
sub AusSel();
local begin
  vHdl,vHdl2 : int;
  vSort      : int;
  vSortName  : alpha;
end;
begin
  gSelected # 0;
/**
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
  vHdl2->WinLstDatLineAdd('Wunschtermin');
  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
**/

  StartList(vSort, vSortname);
end;


//========================================================================
//  Print
//
//========================================================================
sub Print (aName : alpha);
local begin
  Erx : int;
end;
begin
  case aName of

    '100_105' : begin
      StartLine();
      Write(1, ZahlI("Adr.KundenNr"),          y, _LF_INT, 3.0);
      Write(2, "Adr.Name",                       n, 0);
      Write(3, "Adr.Stichwort",                  n, 0);
      Write(4, "Adr.Straße",                     n, 0);
      Write(5, "Adr.PLZ",                        n, 0);
      Write(6, "Adr.Ort",                        n, 0);
      Write(7, "Adr.LKZ",                        n, 0);
      Write(8, "Adr.Sprache",                    n, 0);
      if(Adr.K.VersichertFW <> 0.0) and (Adr.K.KurzLimitFW <> 0.0) and (cnvID(Adr.K.KurzLimit.Dat) >= cnvID(today)) then
        Write(9, ZahlF(Adr.K.KurzLimitFW , 2), y, _LF_NUM, 3.0);
      else
        Write(9, ZahlF(Adr.K.VersichertFW, 2), y, _LF_NUM, 3.0);

      if ("Adr.K.Währung" <> 0) then begin
        Erx # RecLink(814, 103, 2, 0);
        if (Erx <= _rLocked) then
          Write(10, "Wae.Bezeichnung",            n, 0);
      end;

      if ("Adr.K.KurzLimit.Dat" <> 0.0.0) then begin
        Write(11, DatS("Adr.K.KurzLimit.Dat"),  n, _LF_DATE);
      end;

      Write(12, "Adr.K.Referenznr",               n, 0);
      if(List_XML) then begin
        Write(13, ZahlF(Adr.Fin.Vzg.Offset, 2),  y, _LF_Num);
      end;
      EndLine();
    end;

  end;
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin
  WriteTitel();     // Drucke grosse Überschrift
  StartLine();
  EndLine();

  if (aSeite = 1) then begin
    List_Spacing[ 1] # 0.0;
    List_Spacing[ 2] # List_Spacing[ 1] + 15.0
    List_Spacing[ 3] # List_Spacing[ 2] + 50.0
    List_Spacing[ 4] # List_Spacing[ 3] + 35.0
    List_Spacing[ 5] # List_Spacing[ 4] + 35.0
    List_Spacing[ 6] # List_Spacing[ 5] + 12.0
    List_Spacing[ 7] # List_Spacing[ 6] + 30.0
    List_Spacing[ 8] # List_Spacing[ 7] + 10.0
    List_Spacing[ 9] # List_Spacing[ 8] +  8.0
    List_Spacing[10] # List_Spacing[ 9] + 25.0 //22
    List_Spacing[11] # List_Spacing[10] + 15.0
    List_Spacing[12] # List_Spacing[11] + 20.0
    List_Spacing[13] # List_Spacing[12] + 25.0

    StartLine(_LF_BOLD | _LF_UNDERLINE);
    Write(1, 'KdNr.',        y, 0, 3.0);
    Write(2, 'Kundenname',   n, 0);
    Write(3, 'Stichwort',    n, 0);
    Write(4, 'Straße',       n, 0);
    Write(5, 'PLZ',          n, 0);
    Write(6, 'Ort',          n, 0);
    Write(7, 'Land',         n, 0);
    Write(8, 'Spr.',         n, 0);
    Write(9, 'Kreditlimit',  y, 0, 3.0);
    Write(10, 'Währ.',        n, 0);
    Write(11, 'Datum bis',    n, 0);
    Write(12, 'ReferenzNr.',  n, 0);
    if(List_XML) then begin
      Write(13, 'Tage nach Zieldatum',  y, 0);
    end;
    EndLine();
  end;
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss (aSeite : int);
begin
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList (aSort : int; aSortName : alpha);
local begin
  Erx   : int;
  vSelName : alpha;
  vSel     : int;
  vFlag    : int;
  vQ       : alpha(4000);
end;
begin

  // Selektionsquery
  vQ # '';
  if (Sel.Adr.von.KdNr != 0) or (Sel.Adr.bis.KdNr != 9999999) then
    Lib_Sel:QVonBisI(var vQ, 'Adr.Kundennr', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ, 'Adr.Verband', '=', Sel.Adr.von.Verband);

  // Selektion starten...
  vSel # SelCreate(100, 1);
  vSel->SelDefQuery('', vQ);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  //vSelName # Sel_Build(vSel, 100, cSel,y,0); // Selektion oeffnen

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(y);
  vFlag # _RecFirst;
  WHILE (RecRead(100, vSel, vFlag) <= _rLocked) DO BEGIN
    Erx # RecLink(103, 100, 14, 0);
    if(Erx > _rLocked) then
      RecBufClear(103);
    if (vFlag = _RecFirst) then vFlag # _RecNext;
    Print('100_105');
  END;
  ListTerm();

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(100, vSelName);
end;
//========================================================================