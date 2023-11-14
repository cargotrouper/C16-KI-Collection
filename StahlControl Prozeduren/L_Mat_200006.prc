@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200006
//                    OHNE E_R_G
//  Info        Ausgabe der Reservierungen auf Materialkarten
//
//
//  31.07.2008  MS  Erstellung der Prozedur
//  31.07.2008  MS  QUERY
//  14.02.2011  TM  Erweiterung Selektion, Dialog,XML: Bestellnummer
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
@I:Def_aktionen

declare StartList(aSort : int; aSortName : alpha);
declare AusSel();

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort : int;
  vSortName : alpha;
end;
begin

  List_FontSize # 8;

  RecBufClear(998);
  Sel.bis.Datum # today;
  "Sel.Fin.GelöschteYN" # y;
  Sel.Auf.Von.Nummer # 0;
  Sel.Auf.Bis.Nummer # 999999999;
  Sel.Mat.Strukturnr # '';

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200006',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd('Ablaufdatum');
  vHdl2->WinLstDatLineAdd('Kunde');
  vHdl2->wpcurrentint # 1;
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

  List_Spacing[ 1] #  0.0;
  List_Spacing[ 2] # List_Spacing[ 1] + 12.0; // 'MatNr.',
  List_Spacing[ 3] # List_Spacing[ 2] + 13.0; // 'Status',
  List_Spacing[ 4] # List_Spacing[ 3] + 15.0; // 'Güte',
  List_Spacing[ 5] # List_Spacing[ 4] + 15.0; // 'Dicke',
  List_Spacing[ 6] # List_Spacing[ 5] + 18.0; // 'Breite',
  List_Spacing[ 7] # List_Spacing[ 6] + 16.0; // 'Länge',
  List_Spacing[ 8] # List_Spacing[ 7] + 20.0; // 'Kommision',
  List_Spacing[ 9] # List_Spacing[ 8] + 30.0; // 'Kunde',
  List_Spacing[10] # List_Spacing[ 9] + 15.0; // 'PrjNr.',
  List_Spacing[11] # List_Spacing[10] + 12.0; // 'ResStk',
  List_Spacing[12] # List_Spacing[11] + 22.0; // 'ResGew',
  List_Spacing[13] # List_Spacing[12] + 12.0; // 'IstStk',
  List_Spacing[14] # List_Spacing[13] + 22.0; // 'IstGew',
  List_Spacing[15] # List_Spacing[14] + 13.0; // 'FreiStk',
  List_Spacing[16] # List_Spacing[15] + 25.0; // 'FreiGew',
  List_Spacing[17] # List_Spacing[16] + 25.0; // 'Ablaufdatum',
  List_Spacing[18] # List_Spacing[17] + 25.0; // 'Bem.1',
  List_Spacing[19] # List_Spacing[18] + 25.0; // 'Bem.2',
  List_Spacing[20] # List_Spacing[19] + 25.0; // 'Bestellung',
  List_Spacing[21] # List_Spacing[20] + 25.0; // 'Auftragsdat.'


  StartLine(_LF_BOLD | _LF_UNDERLINE);
  Write(1,    'MatNr.',      y, 0);
  Write(2,    'Status',      y, 0, 2.0);
  Write(3,    'Güte',        n, 0);
  Write(4,    'Dicke',       y, 0);
  Write(5,    'Breite',      y, 0);
  Write(6,    'Länge',       y, 0, 2.0);
  Write(7,    'Kommision',   n, 0);
  Write(8,    'Kunde',       n, 0);
  Write(9,    'PrjNr.',      y, 0);
  Write(10,   'ResStk',      y, 0);
  Write(11,   'ResGew',      y, 0);
  Write(12,   'IstStk',      y, 0);
  Write(13,   'IstGew',      y, 0);
  Write(14,   'FreiStk',      y, 0);
  Write(15,   'FreiGew',     y, 0, 2.0);
  Write(16,   'Ablaufdatum', n, 0);
  if (list_XML) then begin
    Write(17, 'Bem.1',       n, 0);
    Write(18, 'Bem.2',       n, 0);
    Write(19, 'Bestellung',  n, 0);
    Write(20, 'Auftragsdat.', n, 0);
  end;

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
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx       : int;
  vSel      : int;
  vTree     : int;
  vItem     : int;
  vSelName  : alpha;
  vSortKey  : alpha;
  vQ        : alpha(2000);
  vQ1       : alpha(2000);
end;
begin
  ListInit(y);
  vTree # CteOpen(_cteTreeCI);

  // Selektion

  vQ  # '';
  Lib_Sel:QAlpha(var vQ, '"Mat.Löschmarker"', '=', '');
  Lib_Sel:QAlpha(var vQ, 'Mat.Bestellnummer', '=*', '*' + Sel.Mat.Strukturnr + '*');

  /*
  If Sel.Mat.Strukturnr <> '' then begin
    vQ # vQ + '"Mat.Bestellnummer" = *"Sel.Mat.Strukturnr"*' ;
  End;
  */

  vQ1 # '';
  Lib_Sel:QVonBisD(var vQ1, 'Mat.R.Ablaufdatum', Sel.von.Datum, Sel.bis.Datum);
  if (!"Sel.Fin.GelöschteYN") then
    Lib_Sel:QAlpha(var vQ1, '"Mat.R.Trägertyp"', '=', '');

  if(vQ1 <> '') then
    Lib_Strings:Append(var vQ, '(LinkCount("Res") > 0)', ' AND ');

  vSel # SelCreate(200, 1);
  vSel->SelAddLink('', 203, 200, 13, 'Res')
  vSel->SelDefQuery('', vQ);
  vSel->SelDefQuery('Res', vQ1);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR  Erx # RecRead(200, vSel, _recFirst);
  LOOP Erx # RecRead(200, vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN

      FOR  Erx # RecLink(203, 200, 13, _recFirst);
      LOOP Erx # RecLink(203, 200, 13, _recNext);
      WHILE (Erx <= _rLocked) DO BEGIn
        if (aSort = 1) then
          vSortKey # CnvAD("Mat.R.Ablaufdatum") + '_' + CnvAI("Mat.Nummer", _fmtNumNoGroup | _fmtNumLeadZero, 0, 15) + '_';
        else if (aSort = 2) then
          vSortKey # "Mat.R.KundenSW" + '_' + CnvAI("Mat.Nummer", _fmtNumNoGroup | _fmtNumLeadZero, 0, 15) + '_';

        Sort_ItemAdd(vTree, vSortKey, 203, RecInfo(203, _recId));
      END;

  END;

  vSel->SelClose();
  SelDelete(200, vSelName);

  /* Ausgabe */
  gFrmMain->winfocusset();

  FOR  vItem # Sort_ItemFirst(vTree);
  loop vItem # Sort_ItemNext(vTree, vItem);
  WHILE (vItem != 0) DO BEGIN
    RecRead(CnvIA(vItem->spCustom), 0, 0, vItem->spID);
    RecLink(200, 203, 1, _recFirst);

    // Bestellung & Bestellposition
    if (RecLink(500, 200, 30, _recFirst) > _rLocked) then begin
      if (RecLink(510, 200, 31, _recFirst) > _rLocked) then begin
        RecBufClear(510);
        RecBufClear(511);
      end
      else if (RecLink(511, 200, 19, _recFirst) > _rLocked) then
        RecBufClear(511);

      RecBufCopy(510, 500);
      RecBufCopy(511, 501);
    end
    else if (RecLink(501, 200, 18, _recFirst) > _rLocked) then
      RecBufClear(501);

    // Steuerschlüssel
    if (RecLink(813, 500, 17, _recFirst) > _rLocked) then
      RecBufClear(813);

    // Auftragsposition holen
    Erx # RecLink(401,203,2,0);

    StartLine();
    Write(1, ZahlI("Mat.R.Materialnr"),                 y, _LF_Int);
    Write(2, ZahlI("Mat.Status"),                       y, _LF_Int, 2.0);
    Write(3, "Mat.Güte", n, 0);
    Write(4, ZahlF("Mat.Dicke", "Set.Stellen.Dicke"),   y, _LF_Num);
    Write(5, ZahlF("Mat.Breite", "Set.Stellen.Breite"), y, _LF_Num);
    Write(6, ZahlF("Mat.Länge", "Set.Stellen.Länge"),   y, _LF_Num, 2.0);
    Write(7, "Mat.R.Kommission",                          n, 0);
    Write(8, "Mat.R.KundenSW",                            n, 0);
    Write(9, AInt(Mat.EK.Projektnr), y, _LF_Int);
    Write(10, ZahlI("Mat.R.Stückzahl"),                  y, _LF_Int);
    Write(11, ZahlF("Mat.R.Gewicht", 2),                 y, _LF_Num);
    Write(12, ZahlI("Mat.Bestand.Stk"),                  y, _LF_Int);
    Write(13, ZahlF("Mat.Bestand.Gew", 2),               y, _LF_Num);
    Write(14, ZahlI("Mat.Verfügbar.Stk")              , y, _LF_Int);
    Write(15, ZahlF("Mat.Verfügbar.Gew", 2)              , y, _LF_Num, 2.0);
    if ("Mat.R.Ablaufdatum" <> 0.0.0) then
      Write(16, Dats("Mat.R.Ablaufdatum"),               n, _LF_Date);

    if (list_XML) then begin
      Write(17, Mat.Bemerkung1, n, 0);
      Write(18, Mat.Bemerkung2, n, 0);
      Write(19, Mat.Bestellnummer, n, 0);
      Write(20, cnvad(Auf.P.Anlage.Datum),n, 0);
    end;

    EndLine();
  END;

  Sort_KillList(vTree);
  ListTerm();
end;

//========================================================================