@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450007
//                    OHNE E_R_G
//  Info        Intrastatliste Material VERKAUF
//
//
//  13.08.2007  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
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
  g_IntraAuf  : logic;
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
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450007',here+':AusSel');
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
  vSort       : int;
  vSortName   : alpha;
end;
begin
  g_IntraAuf # Sel.Mat.EigenYN;
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
      List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;  // Kunde
      List_Spacing[ 3]  # List_Spacing[ 2] + 14.0;  // KLKZ
      List_Spacing[ 4]  # List_Spacing[ 3] + 22.0;  // USt.ID.
      List_Spacing[ 5]  # List_Spacing[ 4] + 14.0;  // Lief.Nr
      List_Spacing[ 6]  # List_Spacing[ 5] + 25.0;  // Lieferant
      List_Spacing[ 7]  # List_Spacing[ 6] + 14.0;  // LLKZ
      List_Spacing[ 8]  # List_Spacing[ 7] + 13.0;  // ReNr
      List_Spacing[ 9]  # List_Spacing[ 8] + 20.0;  // Warencode
      List_Spacing[10]  # List_Spacing[ 9] + 22.0;  // Gewicht
      List_Spacing[11]  # List_Spacing[10] + 22.0;  // Wert

      List_FontSize # 7;
      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Kunde'                                        ,n , 0);
      LF_Set(2,  'KLKZ'                                         ,n , 0);
      LF_Set(3,  'USt.ID.'                                      ,n , 0);
      LF_set(4,  'Lief.Nr'                                      ,y , 0);
      LF_set(5,  'Lieferant'                                    ,n , 0);
      LF_set(6,  'LLKZ'                                         ,n , 0);
      LF_set(7,  'RG-Nr.'                                       ,y , 0);
      LF_set(8,  'Warencode'                                    ,n , 0);

      if (List_XML) then begin
        LF_Set(9, 'Bezeichnung'                                   ,n , 0);
        LF_set(10,  'Gewicht kg'                                   ,y , 0);
        LF_set(11, 'VK-Betrag ' + "Set.Hauswährung.Kurz"          ,y , 0);
        end
      else begin
        LF_set(9,  'Gewicht kg'                                   ,y , 0);
        LF_set(10,  'VK-Betrag ' + "Set.Hauswährung.Kurz"          ,y , 0);
      end;
     end;


    'MATERIAL' : begin

      if (aPrint) then begin

        Gv.ALpha.02 # '';
        if (Erl.Kundennummer <> 0)  then begin
          Erx # RecLink(100,450,5,0) // Kunde holen
          if(Erx > _rLocked) then
            RecBufClear(100);
          LF_Text(1, StrCut(Erl.KundenStichwort, 1, 11));
//          LF_Text(2, Adr.LKZ);
          GV.Alpha.02 # GetBLand(Adr.LKZ, Adr.PLZ);
          LF_Text(3, Adr.USIdentNr);
        end;

        vGew  # Auf.A.Gewicht;
        vWert # Auf.A.RechPreisW1;
        if ( list_XML ) then begin
          LF_Text(10, ZahlF(vGew           ,Set.Stellen.Gewicht));
          LF_Text(11, ZahlF(vWert,2));
        end
        else begin
          LF_Text(9, ZahlF(vGew           ,Set.Stellen.Gewicht));
          LF_Text(10, ZahlF(vWert,2));
        end;
        AddSum(1, vGew);
        AddSum(2, vWert);

        RecLink(100,200,3,_recFirst); // Erzeuger holen
        GV.Alpha.03 # GetBLand(Adr.LKZ, Adr.PLZ);

        if (List_XML) then begin
          MSL.Strukturtyp # '';
          MSL.Intrastatnr # Mat.Intrastatnr;
          // Materialstrukturliste lesen
          Erx # RecRead(220,2,0);
          if(Erx > _rMultiKey) then
            RecBufClear(220);
        end;

        Adr.Stichwort # StrCut(Adr.Stichwort, 1, 11);
        RETURN;
      end;

      LF_Set(1, ''                                          ,n, 0);
      LF_Set(2, '@Gv.ALpha.02'                              ,n, 0);
      LF_Set(3, 'USt.ID.'                                      ,n , 0);
      LF_Set(4, '@Adr.Lieferantennr'                        ,y, _LF_Int);
      LF_Set(5, '@Adr.Stichwort'                            ,n, 0);
      LF_Set(6, '@Gv.Alpha.03'                              ,n, 0);
      LF_Set(7, '@Erl.Rechnungsnr'                          ,y, _LF_Int);
      LF_Set(8, '@Mat.Intrastatnr'                          ,n, 0);

      if (List_XML) then begin
        LF_Set(9, '@MSL.Bezeichnung'                          ,y, _LF_Num);
        LF_Set(10, '#GEW'                                       ,y, _LF_Num);
        LF_Set(11,'#WERT'                                      ,y, _LF_Wae);
        end
      else begin
        LF_Set(9, '#GEW'                                       ,y, _LF_Num);
        LF_Set(10, '#WERT'                                      ,y, _LF_Wae);
      end;

    end;


    'SUMME' : begin

      if (aPrint) then begin
        vGew  # GetSum(1);
        vWert # GetSum(2);
        if (List_XML) then begin
          LF_Text(10, ZahlF(vGew,Set.Stellen.Gewicht));
          LF_Text(11,ZahlF(vWert,2));
          end
        else begin
          LF_Text(9, ZahlF(vGew,Set.Stellen.Gewicht));
          LF_Text(10, ZahlF(vWert,2));
        end;

        AddSum(3, GetSum(1) );
        AddSum(4, GetSum(2) );
        ResetSum(1);
        ReSetSum(2);
        RETURN;
      end;

      LF_Format(_LF_Overline);
      if(List_XML) then begin
        LF_Set(10, '#GEW'                                            ,y, _LF_Num);
        LF_Set(11,'#WERT'                                           ,y, _LF_Wae);
        end
      else begin
        LF_Set(9, '#GEW'                                            ,y, _LF_Num);
        LF_Set(10, '#WERT'                                           ,y, _LF_Wae);
      end;
    end;


    'GESAMT' : begin
      if (aPrint) then begin
        if (List_XML) then begin
          LF_Sum( 10, 3, Set.Stellen.Gewicht );
          LF_Sum( 11, 4, 2 );
        end
        else begin
          LF_Sum( 9, 3, Set.Stellen.Gewicht );
          LF_Sum( 10, 4, 2 );
        end;
        RETURN;
      end;

      LF_Format(_LF_Overline);
      if(List_XML) then begin
        LF_Set(10, '#GEW'                                            ,y, _LF_Num);
        LF_Set(11,'#WERT'                                           ,y, _LF_Wae);
      end
      else begin
        LF_Set(9, '#GEW'                                            ,y, _LF_Num);
        LF_Set(10, '#WERT'                                           ,y, _LF_Wae);
      end;
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
  vBuf450     : int;
  vA,vB       : alpha;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vProgress   : handle;
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
  vQ2 # '';
  Lib_Sel:QInt( var vQ2, 'Erl.Adr.Steuerschl', '=', Sel.Fin.Steuerschl2 );


  // Selektion starten...
  vSel # SelCreate( 404, 0 );
  vSel->SelAddSortFld(2,1,_KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,4,_KeyFldAttrUpperCase);
  vSel->SelAddLink('', 450, 404, 9, 'ERL');
  vSel->SelDefQuery('', vQ );
  vSel->SelDefQuery('ERL', vQ2 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  //vSelName # Sel_Build(vSel, 404, 'LST.450007',y,vKey);
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;        // Aktionen loopen
  WHILE (RecRead(404,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    vDatei # Mat_Data:Read(Auf.A.Materialnr);
    if (vDatei<200) then begin
      CYCLE;
    end;

    Erx # RecLink(450,404,9,_recFirst); // Erlös holen
    Erx # RecLink(100,200,3,_recFirst); // Erzeuger holen
    if (Erx<=_rLocked) then begin
      if ("Adr.Steuerschlüssel"=Sel.Fin.Steuerschl1) then begin

        vStart # GetBLand(Adr.LKZ, Adr.PLZ);
        // Material passt !!!
        Erx # RecLink(100,450,5,_recFirst); // Kunde holen
        vZiel # GetBLand(Adr.LKZ, Adr.PLZ);

        if (g_IntraAuf) then begin
          Auf_data:Read(Auf.A.Nummer, Auf.A.Position, n);
          Mat.Intrastatnr # Auf.P.Intrastatnr;
        end;

        vSortKey # vZiel +
          StrFmt(Mat.Intrastatnr,16,_StrEnd)+
          vStart +
          cnvai(Erl.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero,0,8);

        Sort_ItemAdd(vTree,vSortKey, vDatei, RecInfo(vDatei,_RecId));
      end;
    end;

  END;  // Aktionen

  SelClose(vSel);
  vSel # 0;
  SelDelete(404,vSelName);


  // GUTSCHRIFTEN SUCHEN ************************************
  // Selektionsquery
  vQ # '';
  if ( Sel.Fin.von.Rechnung != 0 ) or ( Sel.Fin.bis.Rechnung != 99999999 ) then
    Lib_Sel:QVonBisI( var vQ, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung, Sel.Fin.bis.Rechnung );
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Erl.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if (vQ<>'') then vQ # vQ + ' AND';
  vQ # vQ + ' (Erl.Rechnungstyp = '+cnvai(c_Erl_REKOR,_Fmtnumnogroup)+' OR '+
              'Erl.Rechnungstyp = '+cnvai(c_Erl_BoGut,_Fmtnumnogroup)+' OR '+
              'Erl.Rechnungstyp = '+cnvai(c_Erl_Gut,_Fmtnumnogroup)+')';
  Lib_Sel:QInt( var vQ, 'Erl.Adr.Steuerschl', '=', Sel.Fin.Steuerschl2 );

  // Selektion starten...
  vSel # SelCreate( 450, 1 );
  vSel->SelDefQuery( '', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 450, 'LST.450007',y,vKey);
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFlag # _RecFirst;        // Aktionen loopen
  WHILE (RecRead(450,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Erx # RecLink(451,450,1,_recFirst);     // Konten loopen
    WHILE (Erx<=_rLocked) do begin

//Erl.K.Gegen.ReNr # 2560;
      if (Erl.K.Gegen.ReNr<>0) then begin
        vBuf450 # RekSave(450);
        Erl.Rechnungsnr # Erl.K.Gegen.ReNr;
        Erx # RecLink(404,450,4,_RecFirst);   // Aktionen loopen
        WHILE (Erx<=_rLocked) do begin
          if (Auf.A.MaterialNr<>0) then begin
            vDatei # Mat_Data:Read(Auf.A.Materialnr);
            if (vDatei<200) then begin
              Erx # RecLink(404,450,4,_RecNext);
              CYCLE;
            end;

            Erx # RecLink(100,200,3,_recFirst); // Erzeuger holen
            if (Erx<=_rLocked) then begin
              if ("Adr.Steuerschlüssel"=Sel.Fin.Steuerschl1) then begin
                vStart   # GetBLand(Adr.LKZ, Adr.PLZ);
                // Material passt !!!
                Erx # RecLink(100,450,5,_recFirst); // Kunde holen
                vZiel   # GetBLand(Adr.LKZ, Adr.PLZ);

                if (g_IntraAuf) then begin
                  Auf_data:Read(Auf.A.Nummer, Auf.A.Position, n);
                  Mat.Intrastatnr # Auf.P.Intrastatnr;
                end;

                vSortKey # vZiel +
                  StrFmt(Mat.Intrastatnr,16,_StrEnd)+
                  vStart +
                  cnvai(vBuf450->Erl.Rechnungsnr,_FmtNumNoGroup|_FmtNumLeadZero,0,8);
                Sort_ItemAdd(vTree,vSortKey, vDatei+1000, RecInfo(vDatei,_RecId));
                BREAK;
              end;
            end;

          end;

          Erx # RecLink(404,450,4,_RecNext);
        END;

        RekRestore(vBuf450);
      end;

      Erx # RecLink(451,450,1,_recNext);
    END;
  END;  // Erlöse

  SelClose(vSel);
  vSel # 0;
  SelDelete(450,vSelName);




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
    if (CnvIA(vItem->spCustom)>1000) then
      RecRead(CnvIA(vItem->spCustom)-1000,0,0,vItem->spID)  // Custom=Dateinr, ID=SatzID
    else
      RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);      // Custom=Dateinr, ID=SatzID
    if (CnvIA(vItem->spCustom)=210) or (CnvIA(vItem->spCustom)=1210) then RecBufCopy(210,200);


    if (g_IntraAuf) then begin
      vA # StrCut(vItem->spname,1+9,16);
      Mat.Intrastatnr # vA;
    end;

    // GUTSCHRIFT???
    if (CnvIA(vItem->spCustom)>1000) then begin
      vA # StrCut(vItem->spname,16+9+9+1,8);
      Erl.Rechnungsnr # cnvia(vA);
      Recread(450,1,0);                     // Rechnungs holen
      Erx # RecLink(100,450,5,_RecFirst);   // Kunde holen
      Erx # RecLink(404,450,4,_RecFirst);   // 1.Aktion holen
      end

    else begin    // RECHNUNG ??? ************

      Erx # RecLink(450,200,23,_recFirst);  // Erlös holen
  //    Erx # RecLink(100,200,3,_recFirst);   // Erzeuger holen
      Erx # RecLink(404,200,24,_recFirst);  // Aufaktionen loopen
      Erx # RecLink(100,450,5,_RecFirst);   // Kunde holen
      WHILE (Erx<=_rLocked) do begin
        if (Auf.A.Rechnungsnr=Erl.Rechnungsnr) then BREAK;
        Erx # RecLink(404,200,24,_recNext);
      END;
      if (Erx>_rLocked) then RecBufClear(404);
    end;

    vA # StrCut(vItem->spname,1,16+9+9);
    if (vFirst=n) and (vSortKey<>vA) then begin
      LF_Print(g_Summe);
      LF_Print(g_Empty);
    end;
    vFirst    # n;
    vSortKey  # vA;
    if (Erl.StornoRechNr =0) then
      LF_Print(g_Material);

    vTree->Ctedelete(vItem);
    vItem # Sort_ItemFirst(vTree)
  END;
  LF_Print(g_Summe);
  LF_Print(g_Empty );
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