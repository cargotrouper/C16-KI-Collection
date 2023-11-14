@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450021
//                    OHNE E_R_G
//  Info      Rechnungsausgangsliste NEU
//
//
//  26.02.2013  ST  Erstellung der Prozedur ( Übernahme von 450013 Laut Projekt 1427/22)
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

define begin
  cSumNetto   : 1
  cSumBrutto  : 2
  cSumEKGes   : 3
  cSumRohgew  : 4
  cSumGewicht : 5
end;

local begin
  vItem       : int;
  gRohgewinn  : float;
  gBrutto     : float;
end;

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

  RecBufClear(998);
  Sel.bis.Datum # today;
  Sel.Fin.bis.Rechnung # 9999999;
  Sel.Auf.bis.AufArt   # 9999;


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450021',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd('Kunde');
  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->WinLstDatLineAdd('Rechnungsnummer');
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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  Erx   : int;
  vSum  : float;
  vSum2 : float;
  vAbmessung : alpha;
end;
begin

  case aName of

    'Pos' : begin

      RekLink(813,451,10,0);    // Steuerschlüssel lesen

      gRohgewinn # Erl.K.BetragW1 - GetSum(cSumEKGes);
      gBrutto    # Erl.K.BetragW1 + (Erl.K.BetragW1 / 100.0 * StS.Prozent);

      StartLine();
      Write(1,  ZahlI(Erl.K.Rechnungsnr)                     ,y , _LF_Int);
      if (Erl.Rechnungsdatum <> 0.0.0) then
        Write(2, Dats(Erl.K.Rechnungsdatum)                 ,n , _LF_Date, 3.0);
      Write(3,  ZahlI(Erl.Rechnungstyp)                    ,y , _LF_Int);
      Write(4,  ZahlI(Auf.P.Nummer)                       ,y , _LF_Int);
      Write(5,  ZahlI(Auf.P.Projektnummer)                ,y , _LF_Int);
      Write(6,  Erl.KundenStichwort                       ,n , 0, 3.0);
      Write(7,  ZahlF(Erl.K.Gewicht,Set.Stellen.Gewicht)    ,y , _LF_Num);
      Write(8,  ZahlF(Erl.K.BetragW1,2)                      ,y , _LF_Num);  // Ist Netto

      Write(9,  ZahlF(gBrutto,2)                     ,y , _LF_Num);

      Write(10, ZahlF(gRohgewinn,2)                       ,y , _LF_Num);
      if(Erl.K.BetragW1 <> 0.0) then
        Write(11, ZahlF(gRohgewinn / Erl.K.BetragW1 * 100.0,2)           ,y , _LF_Num);

      if (List_XML) then begin
        Erx # RekLink(110,450,7,_recFirst); // Vertreter holen
        Write(12, Ver.Stichwort          ,n , 0);
      end;
      EndLine();

      AddSum(cSumNetto,   Erl.K.BetragW1);
      AddSum(cSumBrutto,  gBrutto);
      AddSum(cSumRohgew,  gRohgewinn);
      AddSum(cSumGewicht, Erl.K.Gewicht);
      ResetSum(cSumEKGes);
    end;



    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      List_Spacing[ 6]  # List_Spacing[ 5] + 35.0;
      Write(5, 'GESAMT SUMME:'                                            ,y, 0);
      List_Spacing[ 6]  # List_Spacing[ 5] + 17.0;
      Write(7, ZahlF(GetSum(cSumGewicht),Set.Stellen.Gewicht)             ,y , _LF_Num);
      Write(8, ZahlF(GetSum(cSumNetto),2)                                 ,y, _LF_Num);
      Write(9, ZahlF(GetSum(cSumBrutto),2)                                ,y, _LF_Num);
      Write(10, ZahlF(GetSum(cSumRohgew),2)                               ,y, _LF_Num);
      if(GetSum(cSumNetto) > 0.0) then
        Write(11, ZahlF(GetSum(cSumRohgew) / GetSum(cSumNetto) * 100.0,2)   ,y, _LF_Num);
      EndLine();
     end; // Summe

  end; // CASE
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
    EndLine();

  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 25.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 17.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 17.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 17.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 46.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 30.0;
  List_Spacing[12]  # List_Spacing[11] + 15.0;
  List_Spacing[13]  # List_Spacing[12] + 25.0;
  List_Spacing[14]  # List_Spacing[13] + 25.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'BelegNr.'                       ,y , 0);
  Write(2,  'BelegDat.'                      ,n , 0, 3.0);
  Write(3,  'BelegArt'                       ,y , 0);
  Write(4,  'AufNr.'                         ,y , 0);
  Write(5,  'PrjNr.'                         ,y , 0);
  Write(6,  'Kunde'                          ,n , 0, 3.0);
  Write(7,  'Gewicht'                        ,y , 0);
  Write(8,  'Netto €'                        ,y , 0);
  Write(9,  'Brutto €'                       ,y , 0);
  Write(10,  'Rohgewinn €'                    ,y , 0);
  Write(11,  '%'                              ,y , 0);
  if (List_XML) then
    Write(12,  'Vertreter'                    ,n , 0);
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
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vKey        : int;
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vPrinted    : logic;
  vZAu        : int;
  vWgr        : int;
  vAbmessung     : alpha(120);
  vWarengruppe   : int;
  vAbmessungALT  : alpha(120);
  vDicke      : float;
  vFirst      : logic;
  vTage       : int;
  vAuftragsGew : float;

  vQ451       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);
end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ451 # '';

  // Re. Datumsbereich
  Lib_Sel:QVonBisD(var vQ451, 'Erl.K.Rechnungsdatum',Sel.von.Datum ,Sel.bis.Datum);

  // Rechnungsnummerbereich
  if(Sel.Fin.bis.Rechnung  <>  9999999) and (Sel.Fin.von.Rechnung  <> 0) then
    Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Rechnungsnr', Sel.Fin.von.Rechnung , Sel.Fin.bis.Rechnung);


  vQ401 # '';
  vQ411 # '';
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ411, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);

  Lib_Strings:Append(var vQ451, '((LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0))', ' AND ');

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(451, 1);
  vSel->SelAddLink('', 401, 451, 8, 'AufPos');
  vSel->SelAddLink('', 411, 451, 9, 'AufPosA');

  ERx # vSel->SelDefQuery('', vQ451);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  Erx # vSel->SelDefQuery('AufPos',    vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA',   vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  FOR   Erx # RecRead(451,vSel,_recFirst);
  LOOP  Erx # RecRead(451,vSel,_recNext);
  WHILE (Erx <= _rLocked) DO BEGIN // Material loopen

    // Erlös zum Konto lesen
    Erx # RekLink(450,451,1,0);

    if (Sel.Fin.LiefGutBelYN=false) then begin

      // Auftrag aus Bestand oder Ablage lesen
      Erx # Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true);

      if (Erx = _rNoRec) or (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then
        CYCLE;

    end;

    if (aSort = 1) then
      vSortKey # StrFmt(Erl.KundenStichwort, 20, _StrEnd);

    if (aSort = 2) then
      vSortKey # cnvAI(cnvID(Erl.K.Rechnungsdatum), _FmtNumNoGroup | _FmtNumLeadZero, 0, 6);

    if (aSort = 3) then
      vSortKey # cnvAI(Erl.K.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero, 0, 8);


    Sort_ItemAdd(vTree,vSortKey,451,RecInfo(451,_RecId));
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;

  SelDelete(451, vSelName);



  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    // Erlös lesen
    RekLink(450,451,1,0);

    // Auftrag lesen
    Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, false);

    // OFP lesen
    OFP_Data:Read(Erl.K.Rechnungsnr);

    AddSum(cSumEKGes, Erl.K.EKPreisSummeW1 + Erl.K.InterneKostW1);

    PRINT('Pos');

  END;  // loop

  Print('GesamtSumme');


  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================