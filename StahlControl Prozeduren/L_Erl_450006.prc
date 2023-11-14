@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450006
//                    OHNE E_R_G
//  Info        Intrastatliste Material EINKAUF
//
//
//  13.08.2007  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  26.05.2014  AH  Von Lieferant ODER Erzeuger
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB GetBLand(aLKZ : alpha; aPLZ : alpha) : alpha
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2

declare StartList(aSort : int; aSortName : alpha);

local begin
  g_Empty     : int;
  g_Alpha     : int;
  g_Header    : int;
  g_Material  : int;
  g_Summe     : int;
  g_Gesamt    : int;
  g_Leselinie : logic;
end;

define begin
  AlsLieferant : Sel.Adr.nurMarkeYN
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
  AlsLieferant            # true;
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450006',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);
end;


//========================================================================
//  GetBLand
//
//========================================================================
Sub GetBLand(aLKZ : alpha; aPLZ : alpha) : alpha
local begin
  Erx : int;
end;
begin
  RecBufClear(847);
  Ort.LKZ # aLKZ;
  Ort.PLZ # aPLZ;
  Erx # RecRead(847,1,0);
  if (Erx=_rNoRec) or (Ort.LKZ<>aLKZ) or (Ort.PLZ<>aPLZ) then
    RecBufClear(847);

//debugx('KEY450 '+StrFmt(aLKZ,3,_strEnd)+' '+StrFmt(Ort.Bundesland,5,_strEnd));
  RETURN StrFmt(aLKZ,3,_strEnd)+' '+StrFmt(Ort.Bundesland,5,_strEnd);
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
  Erx   : int;
  vWert : float;
  vGew  : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'ALPHA' : begin
      if (aPrint) then RETURN;
      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   220.0;
      LF_Set(1,  '@GV.Alpha.01'      ,n , 0);
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 24.0;  // Kunde
      List_Spacing[ 3]  # List_Spacing[ 2] + 15.0;  // KLKZ
      List_Spacing[ 4]  # List_Spacing[ 3] + 14.0;  // Lief.Nr
      List_Spacing[ 5]  # List_Spacing[ 4] + 33.0;  // Erzeuger
      List_Spacing[ 6]  # List_Spacing[ 5] + 15.0;  // LLKZ
      List_Spacing[ 7]  # List_Spacing[ 6] + 13.0;  // ReNr
      List_Spacing[ 8]  # List_Spacing[ 7] + 23.0;  // Warencode
      List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;  // Gewicht
      List_Spacing[10]  # List_Spacing[ 9] + 25.0;  // Wert

      List_FontSize # 7;
      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Kunde'                                        ,n , 0);
      LF_Set(2,  'KLKZ'                                         ,n , 0);
      LF_set(3,  'Lief.Nr'                                      ,y , 0);
      LF_set(4,  'Erzeuger'                                     ,n , 0);
      LF_set(5,  'LLKZ'                                         ,n , 0);
      LF_set(6,  'RG-Nr.'                                       ,y , 0);
      LF_set(7,  'Warencode'                                    ,n , 0);
      LF_set(8,  'Gewicht kg'                                   ,y , 0);
      LF_set(9,  'EK-Betrag ' + "Set.Hauswährung.Kurz"          ,y , 0);
    end;


    'MATERIAL' : begin

      if (aPrint) then begin
        if (Erl.Kundennummer <> 0)  then begin
          RecLink(100,450,5,0) // Kunde holen
          LF_Text(1, StrCut(Erl.KundenStichwort, 1, 11));
//          LF_Text(2, Adr.LKZ);
          GV.Alpha.02 # GetBLand(Adr.LKZ, Adr.PlZ);
        end;

        vGew  # Auf.A.Gewicht;
        vWert # Rnd(vGew * "Mat.EK.Preis" / 1000.0,2);
        LF_Text(8, ZahlF(vGew           ,Set.Stellen.Gewicht));
        LF_Text(9, ZahlF(vWert,2));
        AddSum(1, vGew);
        AddSum(2, vWert);

        // 26.05.2014:
        if (alsLieferant) then begin
          Erx # RekLink(100,200,4,_recFirst); // Lieferant holen
          GV.Alpha.03 # GetBLand(Adr.LKZ, Adr.PLZ);
        end
        else begin
          RecLink(100,200,3,_recFirst); // Erzeuger holen
          GV.Alpha.03 # GetBLand(Adr.LKZ, Adr.PLZ);
        end;
        Adr.Stichwort # StrCut(Adr.Stichwort, 1, 11);
        RETURN;
      end;

      LF_Set(1, ''                                          ,n, 0);
      LF_Set(2, '@Gv.ALpha.02'                              ,n, 0);
      LF_Set(3, '@Adr.Lieferantennr'                        ,y, _LF_Int);
      LF_Set(4, '@Adr.Stichwort'                            ,n, 0);
      LF_Set(5, '@Gv.Alpha.03'                              ,n, 0);
      LF_Set(6, '@Erl.Rechnungsnr'                          ,y, _LF_Int);
      LF_Set(7, '@Mat.Intrastatnr'                          ,n, 0);
      LF_Set(8, 'GEW'                                       ,y, _LF_Num);
      LF_Set(9, 'WERT'                                      ,y, _LF_Wae);
    end;


    'SUMME' : begin

      if (aPrint) then begin
        vGew  # GetSum(1);
        vWert # GetSum(2);
        LF_Text(8, ZahlF(vGew,Set.Stellen.Gewicht));
        LF_Text(9, ZahlF(vWert,2));
        AddSum( 3, GetSum( 1 ) );
        AddSum( 4, GetSum( 2 ) );
        ResetSum(1);
        ReSetSum(2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(8, '#GEW'                                            ,y, _LF_Num);
      LF_Set(9, '#WERT'                                           ,y, _LF_Wae);
    end;

    'GESAMT' : begin
      if (aPrint) then begin
        LF_Sum( 8, 3, Set.Stellen.Gewicht );
        LF_Sum( 9, 4, 2 );
        RETURN;
      end;

      LF_Format(_LF_Overline);
      LF_Set(8, '#GEW'                                            ,y, _LF_Num);
      LF_Set(9, '#WERT'                                           ,y, _LF_Wae);
    end;

  end; // CASE

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
    LF_Print(g_Empty);
    Gv.Alpha.01 # 'Rechnung    ' + AInt(Sel.Fin.von.Rechnung) + '  bis  ' + AInt(Sel.Fin.bis.Rechnung);
    LF_Print(g_Alpha);
    Gv.Alpha.01 # 'Zeitraum    ' + CnvAD(Sel.von.Datum) + '  bis  ' + CnvAd(Sel.bis.Datum);
    LF_Print(g_Alpha);
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
  vDatei      : int;
  vOK         : logic;
  vSortKey    : alpha;
  vFirst      : logic;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vProgress   : Handle;
  vA          : alpha;
  vStart      : alpha;
  vZiel       : alpha;
end;
begin

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery für 404
  vQ # '';
  if ( Sel.Fin.von.Rechnung != 0 ) or ( Sel.Fin.bis.Rechnung != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Auf.A.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Auf.A.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  Lib_Sel:QInt( var vQ, 'Auf.A.Rechnungsnr', '>=', 1 );
  Lib_Sel:QInt( var vQ, 'Auf.A.Materialnr', '>', 0 );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(ERL) > 0 ';
  // Selektionsquery für 450
  Lib_Sel:QInt( var vQ2, 'Erl.Adr.Steuerschl', '=', Sel.Fin.Steuerschl2 );


  // Selektion starten...
  vSel # SelCreate( 404, 0 );
  vSel->SelAddSortFld(2,1,_KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,4,_KeyFldAttrUpperCase);
  vSel->SelAddLink('', 450, 404, 9, 'ERL');
  vSel->SelDefQuery('', vQ );
  vSel->SelDefQuery('ERL', vQ2 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  //vSelName # Sel_Build(vSel, 404, 'LST.450006',y,vKey);
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;        // Aktionen loopen
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    vDatei # Mat_Data:Read(Auf.A.Materialnr);
    if (vDatei<200) then begin
      CYCLE;
    end;

    Erx # RecLink(450,404,9,_recFirst); // Erlös holen

    // 26.05.2014:
    if (alsLieferant) then begin
      Erx # RekLink(100,200,4,_recFirst); // Lieferant holen
    end
    else begin
      Erx # RecLink(100,200,3,_recFirst); // Erzeuger holen
    end;

    if (Erx<=_rLocked) then begin
      if ("Adr.Steuerschlüssel"=Sel.Fin.Steuerschl1) then begin
        // Material passt !!!
        vStart  # GetBLand(Adr.LKZ, Adr.PLZ);
        RecLink(100,450,5,0) // Kunde holen
        vZiel   # GetBLand(Adr.LKZ, Adr.PLZ);
        vSortKey # vStart+
          StrFmt(Mat.Intrastatnr,16,_StrEnd)+
          vZiel+
          cnvai(Erl.Rechnungsnr);

        Sort_ItemAdd(vTree,vSortKey, vDatei, RecInfo(vDatei,_RecId));

      end;
    end;

  END;  // Aktionen

  SelClose(vSel);
  vSel # 0;
  SelDelete(404,vSelName);



  // Ausgabe ----------------------------------------------------------------
  vProgress # Lib_Progress:Init( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Alpha     # LF_NewLine('ALPHA');
  g_Header    # LF_NewLine('HEADER');
  g_Material  # LF_NewLine('MATERIAL');
  g_Summe     # LF_NewLine('SUMME');
  g_Gesamt    # LF_NewLine('GESAMT');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(n);    // KEIN Landscape

  vFirst    # y;
  vSortkey  # '';

  // Durchlaufen und löschen
  vItem # Sort_ItemFirst(vTree)
  WHILE (vItem != 0) do begin

    // Progress
    if ( !vProgress->Lib_Progress:Step() ) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;



    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID
    if (CnvIA(vItem->spCustom)=210) then RecBufCopy(210,200);

    Erx # RecLink(450,200,23,_recFirst);  // Erlös holen

    Erx # RecLink(404,200,24,_recFirst);  // Aufaktionen loopen
    WHILE (Erx<=_rLocked) do begin
      if (Auf.A.Rechnungsnr=Erl.Rechnungsnr) then BREAK;
      Erx # RecLink(404,200,24,_recNext);
    END;
    if (Erx>_rLocked) then RecBufClear(404);

    vA # StrCut(vItem->spname,1,16+9+9);
    if (vFirst=n) and (vA<>vSortKey) then begin
      LF_Print(g_Summe);
      LF_Print(g_Empty);
    end;
    vFirst    # n;
    vSortkey  # vA;

    LF_Print(g_Material);

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree)
  END;
  LF_Print(g_Summe);
  LF_Print(g_Empty);
  LF_Print(g_Gesamt);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Alpha);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Summe);
  LF_FreeLine(g_Gesamt);

end;

//========================================================================