@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450001
//                    OHNE E_R_G
//  Info        Rechnungsausgang Propipe
//
//
//  13.04.2006  AI  Erstellung der Prozedur
//  22.07.2008  DS  QUERY
//  27.06.2011  TM  Anpassung an neue Listenprog.
//  26.10.2011  MS  Liste wieder im Querformat
//  26.11.2012  ST  Anpassung für Propipe -> Standard
//  17.12.2012  AI  + Vertreterstichwort bei XML (Prj.1377/68)
//  26.07.2016  AH  Gesamtsumme RohProzent war falsch
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Aktionen

declare StartList(aSort : int; aSortName : alpha);
define begin
  gRoh : Gv.Num.01

  cSumNetto   : 1
  cSumSteuer  : 2
  cSumBrutto  : 3
  cSumRohN    : 4
  cSumInternK : 5
  cSumEK      : 6
  cSumGewicht : 7
  cSumRohProz : 8
//  cSumRohProzCnt : 9
end;

local begin

  // Handles für die Zeilenelemente
  g_Empty       : int;
  g_Sel1        : int;
  g_Sel2        : int;
  g_Sel3        : int;
  g_Header      : int;
  g_Artikel     : int;
  g_Summe1      : int;
  g_Summe2      : int;

  vProgress : handle;

  // zu ermittelnde Listenwerte
  vInterneKosten : float;
  vEK            : float;

  vRohgewProz    : float;

end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Fin.bis.Rechnung    # 99999999;
  Sel.bis.Datum           # today;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450001',here+':AusSel');
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

  vHdl2->WinLstDatLineAdd('Kundennummer');
  vHdl2->WinLstDatLineAdd('Rechnungsnummer');
  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->WinLstDatLineAdd('Stichwort');
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
//  Element
//
//========================================================================
sub Element(
  aName     : alpha;
  aPrint    : logic);
local begin
  Erx : int;
end;
begin

  case aName of


    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 28.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 22.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 22.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 22.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 22.0;

      LF_Set(1, 'Rechnungsdatum:'           ,n,0);
      LF_Set(2, '@Sel.von.Datum'            ,n,0);
      LF_Set(3, 'bis '                    ,n,0);
      LF_Set(4, '@Sel.bis.Datum'          ,n,0);


      LF_Set(5, GV.Alpha.01                 ,n,0);

    End;


    'SEL2' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 28.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 22.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 22.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 22.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 22.0;

      If (Sel.Fin.Von.Rechnung >0 or Sel.Fin.Bis.Rechnung >0) then begin
        LF_Set(1, 'Rechnungsnr.:'           ,n,0);
        LF_Set(2, '@Sel.Fin.Von.Rechnung'   ,n,_LF_Int);
        LF_Set(3, 'bis '                    ,n,0);
        LF_Set(4, '@Sel.Fin.Bis.Rechnung'   ,n,_LF_Int);
        LF_Set(5, '@GV.Alpha.02'            ,n,0);
      End;

    End;


    'SEL3' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 28.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 22.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 22.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 22.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 22.0;

      LF_Set(1, ''              ,n,0);
      LF_Set(2, '@GV.Alpha.03'  ,n,0);
      LF_Set(3, ''              ,n,0);
      LF_Set(4, ''              ,n,0);
      LF_Set(5, '@GV.Alpha.04'  ,n,0);

    End;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;                     // RAND links + RechnungsDatum
      List_Spacing[ 2]  # List_Spacing[ 1]  + 23.0; // RechnungsNummer
      List_Spacing[ 3]  # List_Spacing[ 2]  + 20.0; // KundenNummer
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; // KundenStichwort
      List_Spacing[ 5]  # List_Spacing[ 4]  + 45.0; // € Brutto
      List_Spacing[ 6]  # List_Spacing[ 5]  + 27.0; // € Steuer
      List_Spacing[ 7]  # List_Spacing[ 6]  + 27.0; // € Netto
      List_Spacing[ 8]  # List_Spacing[ 7]  + 27.0; // € EK
      List_Spacing[ 9]  # List_Spacing[ 8]  + 27.0; // € InterneKosten
      List_Spacing[10]  # List_Spacing[ 9]  + 27.0; // € Netto RohErtrag
      List_Spacing[11]  # List_Spacing[ 10] + 27.0; // Vorgangsart
      List_Spacing[12]  # List_Spacing[ 11] + 27.0; // LKZ
      List_Spacing[13]  # List_Spacing[ 12] + 27.0; // Gewicht
      List_Spacing[14]  # List_Spacing[ 13] + 27.0; // Prozent
      List_Spacing[15]  # List_Spacing[ 14] + 27.0; // Vertreter
      List_Spacing[16]  # List_Spacing[ 15] + 27.0; // RAND rechts

      // ab hier XML

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set( 1,  'Re.Datum'                            ,n , 0);  // RechnungsDatum
      LF_Set( 2,  'Re.Nummer'                           ,n , 0);  // RechnungsNummer
      LF_Set( 3,  'Ku.Nr'                               ,y , 0);  // KundenNummer
      LF_Set( 4,  'Stichwort'                           ,n , 0);  // KundenStichwort
      LF_Set( 5,  'Brutto '   + "Set.Hauswährung.Kurz"  ,y , 0);  // € Brutto
      LF_Set( 6,  'Steuer '   + "Set.Hauswährung.Kurz"  ,y , 0);  // € Steuer
      LF_Set( 7,  'Netto '    + "Set.Hauswährung.Kurz"  ,y , 0);  // € Netto
      LF_Set( 8,  'EK '       + "Set.Hauswährung.Kurz"  ,y , 0);  // € EK
      LF_Set( 9,  'IntKost.'  + "Set.Hauswährung.Kurz"  ,y , 0);  // € InterneKosten
      LF_Set(10,  'Roh.Netto' + "Set.Hauswährung.Kurz"  ,y , 0);  // € Netto RohErtrag
      LF_Set(11,  'Vorgangsart'                         ,n , 0);  // Vorgangsart
      LF_Set(12,  'LKZ'                                 ,n , 0);  // LKZ

      LF_Set(13,  'Gewicht'                             ,n , 0);  // Gewicht der Rechnung
      // ST 2012-11-26 (Projekt 1247/9)
      LF_Set(14,  'Rohgewinn %'                         ,n , 0);  // Netto gewinn in %
      if (List_XML) then begin
        LF_Set(15,  'Vertreter'                         ,n , 0);
      end;
      /*
      if (List_XML) then begin
        LF_Set(21, '',n , 0);
      end;
      */
    end;


    'ARTIKEL' : begin
      Lf_Text(8,cnvaf(vEK,0,0,2));
      Lf_Text(9,cnvaf(vInterneKosten,0,0,2));
      Lf_Text(14,cnvaf(vRohgewProz,0,0,2));


      If (aPrint) then RETURN;

      LF_Set( 1, '@Erl.Rechnungsdatum'   , n, _Lf_Date);
      LF_Set( 2, '@Erl.Rechnungsnr'      , y, _LF_Int);
      LF_Set( 3, '@Erl.Kundennummer'     , y, _LF_Int);
      LF_Set( 4, '@Erl.KundenStichwort'  , n, 0);
      LF_Set( 5, '@Erl.BruttoW1'         , y, _LF_Num3, 2);
      LF_Set( 6, '@Erl.SteuerW1'         , y, _LF_Num3, 2);
      LF_Set( 7, '@Erl.NettoW1'          , y, _LF_Num3, 2);
      LF_Set( 8, 'vEK'                   , y, _LF_Num3, 2);
      LF_Set( 9, 'vIK'                   , y, _LF_Num3, 2);
      LF_Set(10, '@GV.Num.01'            , y, _LF_Num3, 2);
      LF_Set(11, '@AAr.Bezeichnung'      ,n , 0);  // Vorgangsart
      LF_Set(12, '@Adr.LKZ'              ,n , 0);  // LKZ
      LF_Set(13,  '@Erl.Gewicht'         ,y , _LF_Num3);  // Gewicht der Rechnung
      LF_Set(14,  'vRohgewProz'          ,y , _LF_Num3, 2);  // Netto gewinn in %
      if (List_XML) then begin
        Erx # RekLink(110,450,7,_recFirst); // Vertreter holen
        LF_Set(15, Ver.Stichwort         ,n , 0);
      end;
   end;

    'SUMME1' : begin

       if (aPrint) then begin
        LF_Sum( 5 , cSumBrutto, 2);
        LF_Sum( 7 , cSumNetto, 2);
        LF_Sum( 9 , cSumInternK, 2);
        LF_Sum( 13 , cSumGewicht , 2);
        RETURN;
      end;

      LF_Format(_LF_Bold);
      LF_Set( 5, 'SUM1'                 ,y , _LF_NUM,2);
      LF_Set( 7, 'SUM3'                 ,y , _LF_NUM,2);
      LF_Set( 9, 'SUM5'                 ,y , _LF_NUM,2);
      LF_Set(13, 'SUM7'                 ,y , _LF_NUM,2);

      LF_Format(_LF_Overline);

    end;


    'SUMME2' : begin

       if (aPrint) then begin

        LF_Sum( 6 , cSumSteuer, 2);
        LF_Sum( 8 , cSumEK, 2);
        LF_Sum(10 , cSumRohN, 2);

        vRohgewProz   # 0.0;
//        if (GetSum(cSumRohProzCnt) <> 0.0) then
//          vRohgewProz     # Rnd(GetSum(cSumRohProz) / GetSum(cSumRohProzCnt),2) ;
    if (GetSum(cSumNetto) <> 0.0) then
      vRohgewProz  # Rnd((GetSum(cSumRohN) / GetSum(cSumNetto) * 100.0),2);

        Lf_Text(14,cnvaf(vRohgewProz,0,0,2));

        RETURN;
      end;

      LF_Format(_LF_Bold);
      LF_Set( 6, 'SUM2'                 ,y , _LF_NUM,2);
      LF_Set( 8, 'SUM4'                 ,y , _LF_NUM,2);
      LF_Set(10, 'SUM6'                 ,y , _LF_NUM,2);
      LF_Set(14, 'vRohgewProz'         ,y , _LF_NUM,2);

    end;

  end; // CASE
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  List_FontSize # 7;

  WriteTitel();   // Drucke grosse Überschrift
  LF_Print(g_Empty);

  if (aSeite=1) then begin
    LF_Print(g_Sel1);
    LF_Print(g_Sel2);
    LF_Print(g_Sel3);
    LF_Print(g_Empty);
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
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vQ          : alpha(4000);
end;
begin

  // Selektionsquery
  vQ # '';
  if (Sel.Fin.von.Rechnung != 0) or (Sel.Fin.bis.Rechnung != 99999999) then
    Lib_Sel:QVonBisI(var vQ, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung);
  if (Sel.von.Datum != 0.0.0) or (Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD(var vQ, 'Erl.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  if (Sel.Adr.von.Kdnr != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Kundennummer', '=', Sel.Adr.von.Kdnr);
  if (Sel.Adr.von.Vertret != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Vertreter', '=', Sel.Adr.von.Vertret);
  if (Sel.Adr.von.Verband != 0) then
    Lib_Sel:QInt(var vQ, 'Erl.Verband', '=', Sel.Adr.von.Verband);

  // Sortierung setzen
  if (aSort=1) then vKey # 3; // KuNr
  if (aSort=2) then vKey # 1; // ReNr
  if (aSort=3) then vKey # 4; // ReDat
  if (aSort=4) then vKey # 2; // Stichwort

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  If (Sel.Fin.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate(450, vKey);
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(450,_SelLock,vSelName);   // Selektion laden
    //vSelName # Sel_Build(vSel, 450, 'LST.450001',n,vKey);

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 450) then begin
        RecRead(450,0,_RecId,vMID);
        SelRecInsert(vSel,450);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin

    // Selektion starten...
    vSel # SelCreate(450, vKey);
    vSel->SelDefQuery('', vQ);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);
    //vSelName # Sel_Build(vSel, 450, 'LST.450001',y,vKey);

  end;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  Gv.Alpha.01 # '';
  Gv.Alpha.02 # '';
  Gv.Alpha.03 # '';
  Gv.Alpha.04 # '';
  if (Sel.Adr.von.KdNr<>0) then begin
    Gv.Alpha.01 # 'nur Kunde: '+AInt(Sel.Adr.von.KdNr);
  end;
  if (Sel.Adr.von.Vertret<>0) then begin
    Gv.Alpha.02 # 'nur Vertreter: '+AInt(Sel.Adr.von.Vertret);
  end;
  if (Sel.Adr.von.Verband<>0) then begin
    Gv.Alpha.03 # 'nur Verband: '+AInt(Sel.Adr.von.Verband);
  end;
  if (Sel.fin.nurMarkeYN) then begin
    Gv.Alpha.04 # 'nur markierte Sätze';
  end;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...

  List_FontSize # 7;
  g_Empty       # LF_NewLine('EMPTY');
  g_Sel1        # LF_NewLine('SEL1');
  g_Sel2        # LF_NewLine('SEL2');
  g_Sel3        # LF_NewLine('SEL3');
  g_Header      # LF_NewLine('HEADER');
  g_Artikel     # LF_NewLine('ARTIKEL');
  g_Summe1      # LF_NewLine('SUMME1');
  g_Summe2      # LF_NewLine('SUMME2');


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(true);    // KEIN Landscape

  FOR Erx # RecRead(450, vSel, _recFirst) // Erlöse loopen
  LOOP Erx # RecRead(450, vSel, _recNext)
  WHILE (Erx <= _rLocked) DO BEGIN

    Erx # RecLink(100, 450, 5, _recFirst); // Kd. holen
    if(Erx > _rLocked) then
      RecBufClear(100);

    Erx # RecLink(451, 450, 1, _recFirst); // erstes Erl.K. holen
    if(Erx > _rLocked) then
      RecBufClear(451);

    Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true); // Auftrag zu Erl.K. holen

    Erx # RecLink(835, 401, 5, _recFirst); // Vorgangsart / Auftragsart
    if(Erx > _rLocked) then
      RecBufClear(835);

    gRoh # Erl.NettoW1;
    vInterneKosten # 0.0;
    vEK # 0.0;
    FOR Erx # RecLink(451,450,1,_recFirst);    // Konten loopen
    LOOP Erx # RecLink(451,450,1,_recNext);
    WHILE (Erx<=_rLocked) do begin
      gRoh            # gRoh - Erl.K.EKPreisSummeW1;
      vEK             # vEK + Erl.K.EKPreisSummeW1;
      vInterneKosten  # vInterneKosten + Erl.K.interneKostW1;
    END;

    gRoh # gRoh - vInterneKosten;


    vRohgewProz  # 0.0;
    if (Erl.NettoW1 <> 0.0) then
      vRohgewProz  # Rnd((gRoh / Erl.NettoW1 * 100.0),2);

    Lf_Print(g_Artikel);

    AddSum(cSumNetto,   Erl.NettoW1)
    AddSum(cSumSteuer,  Erl.SteuerW1);
    AddSum(cSumBrutto,  Erl.BruttoW1);
    AddSum(cSumRohN,    gRoh);
    AddSum(cSumInternK, vInterneKosten);
    AddSum(cSumEK,      vEK);
    AddSum(cSumGewicht , Erl.Gewicht);


    AddSum(cSumRohProz  , vRohgewProz);
//    AddSum(cSumRohProzCnt  , 1.0);
  END;
  Lf_Print(g_Summe1); //Summen drucken 1/2
  Lf_Print(g_Summe2); //Summen drucken 2/2
  ResetSum(1);
  ResetSum(2);
  ResetSum(3);
  ResetSum(4);
  ResetSum(5);
  ResetSum(6);

  ResetSum(7);
  ResetSum(8);
  ResetSum(9);

  // ListTerm();

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(450, vSelName);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Artikel);
  LF_FreeLine(g_Summe1);
  LF_FreeLine(g_Summe2);
end;

//========================================================================