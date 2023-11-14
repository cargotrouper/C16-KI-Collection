@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450013
//                    OHNE E_R_G
//  Info      Rechnungsausgangsliste NEU
//
//
//  09.04.2009  MS  Erstellung der Prozedur
//  09.04.2009  MS  QUERY
//  17.12.2012  AI  + Vertreterstichwort bei XML (Prj.1377/68)
//  26.02.2013  ST  Selektion Vorgangsart und GutSchrift/Bel. entfernt (Prg. 1427/22)
//  13.06.2022  AH  ERX
//  16.03.2023  TM  "Sicheres" Lesen Erlösontierung, wenn keine vorhd. ist: ERL überspringen (Prj. 2400/3)
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


  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450013',here+':AusSel');
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
      gRohgewinn # Erl.NettoW1 - GetSum(cSumEKGes);

      StartLine();
      Write(1,  ZahlI(Erl.Rechnungsnr)                     ,y , _LF_Int);
      if (Erl.Rechnungsdatum <> 0.0.0) then
        Write(2, Dats(Erl.Rechnungsdatum)                 ,n , _LF_Date, 3.0);
      Write(3,  ZahlI(Erl.Rechnungstyp)                    ,y , _LF_Int);
      Write(4,  ZahlI(Auf.P.Nummer)                       ,y , _LF_Int);
      Write(5,  ZahlI(Auf.P.Projektnummer)                ,y , _LF_Int);
      Write(6,  Erl.KundenStichwort                       ,n , 0, 3.0);
      Write(7,  ZahlF(Erl.Gewicht,Set.Stellen.Gewicht)    ,y , _LF_Num);
      Write(8,  ZahlF(Erl.NettoW1,2)                      ,y , _LF_Num);
      Write(9,  ZahlF(Erl.BruttoW1,2)                     ,y , _LF_Num);
      Write(10, ZahlF(gRohgewinn,2)                       ,y , _LF_Num);
      if(Erl.NettoW1 <> 0.0) then
        Write(11, ZahlF(gRohgewinn / Erl.NettoW1 * 100.0,2)           ,y , _LF_Num);

      if (List_XML) then begin
        Erx # RekLink(110,450,7,_recFirst); // Vertreter holen
        Write(12, Ver.Stichwort          ,n , 0);
      end;
      EndLine();

      AddSum(cSumNetto,   Erl.NettoW1);
      AddSum(cSumBrutto,  Erl.BruttoW1);
      AddSum(cSumRohgew,  gRohgewinn);
      AddSum(cSumGewicht, Erl.Gewicht);
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
  Write(5,  '1. PrjNr.'                         ,y , 0);
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

  vQ203       : alpha(4000);
  vQ450       : alpha(4000);
  vQ451       : alpha(4000);
  vQ401       : alpha(4000);
  vQ411       : alpha(4000);

end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ450 # '';
  Lib_Sel:QVonBisD(var vQ450, 'Erl.Rechnungsdatum',Sel.von.Datum ,Sel.bis.Datum);
  if(Sel.Fin.bis.Rechnung  <>  9999999) and (Sel.Fin.von.Rechnung  <> 0) then
    Lib_Sel:QVonBisI(var vQ450, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung , Sel.Fin.bis.Rechnung);

/*
  vQ401 # '';
  vQ411 # '';
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ401, 'Auf.P.Auftragsart', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);
  if (Sel.Auf.von.AufArt != 0) or (Sel.Auf.bis.AufArt != 9999) then
    Lib_Sel:QVonBisI(var vQ411, '"Auf~P.Auftragsart"', Sel.Auf.von.AufArt, Sel.Auf.bis.AufArt);

  if(vQ401 + vQ411 <> '') then begin
    Lib_Strings:Append(var vQ450, '(LinkCount(ErlK) > 0)', ' AND ');
    Lib_Strings:Append(var vQ451, '((LinkCount(AufPos) > 0 OR LinkCount(AufPosA) > 0))', ' AND ');
  end;
*/
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(450, 1);
/*
  vSel->SelAddLink('', 451, 450, 1, 'ErlK');
  vSel->SelAddLink('ErlK', 401, 451, 8, 'AufPos');
  vSel->SelAddLink('ErlK', 411, 451, 9, 'AufPosA');
*/
  erx # vSel->SelDefQuery('', vQ450);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
/*
  er xvSel->SelDefQuery('ErlK', vQ451);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPos',    vQ401);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('AufPosA',   vQ411);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
*/
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  Erx # RecRead(450,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN // Material loopen


    if (Sel.Fin.LiefGutBelYN=false) then begin

      case Erl.Rechnungstyp of
        415,    // LF-Gutschrift
        418,    // LF-Stornogutschrift
        425,    // LF-Belastung
        428     // LF-Stornorbelastung
        : begin
          Erx # RecRead(450,vSel,_recNext);
          CYCLE;
        end;

      end;

/*
      Erx # RecLink(451,450,1,_RecFirst);   // 1.Erloeskonto holen
      if (Erx<=_rLocked) then begin
        Auf.Nummer # Erl.K.Auftragsnr;
        Erx # RecRead(400,1,0);             // Auftrag holen
        if (Erx > _rLocked) then begin
          "Auf~Nummer" # Erl.K.Auftragsnr;
          Erx # RecRead(410,1,0);             // Auftrag holen
          if (Erx > _rLocked) then RecBufClear(400)
          else RecbufCopy(410,400);
        end;
        if (Auf.Vorgangstyp=c_Gut_LF) or (Auf.Vorgangstyp=c_Bel_LF) then begin
          Erx # RecRead(450,vSel,_recNext);
          CYCLE;
        end;
      end;
*/
    end;


    if (aSort = 1) then
      vSortKey # StrFmt(Erl.KundenStichwort, 20, _StrEnd);

    if (aSort = 2) then
      vSortKey # cnvAI(cnvID(Erl.Rechnungsdatum), _FmtNumNoGroup | _FmtNumLeadZero, 0, 6);

    if (aSort = 3) then
      vSortKey # cnvAI(Erl.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero, 0, 8);




    Sort_ItemAdd(vTree,vSortKey,450,RecInfo(450,_RecId));
    Erx # RecRead(450,vSel,_recNext);
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(450, vSelName);




  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin


    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID


    // Sichers lesen ersten Kontierung und der Auftragsdaten; Erlöse ohne Kontierung sind defekt und werden übersprungen.
    Erx # RecLink(451,450,1,_RecFirst);   // Erloeskonto holen
    if (Erx <= _rMultikey) then begin
      Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true);
    end
    else CYCLE;


    Erx # RecLink(460,450,2,_RecFirst);   // Offene Posten holen !
    if (Erx > _rLocked) then begin
      Erx # RecLink(470,450,11,_RecFirst);
      if (Erx > _rLocked) then begin
        RecBufClear(460);
        RecBufClear(470);
      end
      else
        RecBufCopy(470,460);
    end;

    FOR Erx # RecLink(451,450,1,_RecFirst);   // Erloeskonto holen
    LOOP Erx # RecLink(451,450,1,_RecNext);
    WHILE(Erx <= _rLocked) DO BEGIN
      AddSum(cSumEKGes, Erl.K.EKPreisSummeW1 + Erl.K.InterneKostW1);
    END;

    Erx # RecLink(401,451,8,0);
    if Erx > _rlocked then begin
      Erx # RecLink(411,451,9,0);
      if Erx > _rlocked then begin
        recBufClear(401);
      end
      else begin
        recbufcopy(411,410);
      end;
    end;
    PRINT('Pos');

  END;  // loop

  Print('GesamtSumme');



  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================