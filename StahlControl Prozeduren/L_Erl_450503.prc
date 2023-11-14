@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450503
//
//  Info        Wareneinsatzliste LOHN für Tagesbericht
//
//
//
//  17.03.2020  ST  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2
@I:Def_Aktionen
@I:Def_BAG

declare StartList(aSort : int; aSortName : alpha);
declare Autogenerate();

define begin
  cSum_MatEkGew     : 1
  cSum_MatAusGew    : 2
  cSum_ErlGew       : 3
  cSum_ErlWert      : 4
end;


local begin
  g_Empty             : int; // Handles für die Zeilenelemente
  g_Sel1              : int;
  g_Header1           : int;
  g_LohnRech          : int;
  g_Gesamt            : int;

  gMatEinsatzGew     : float;
  gMatSchrottGew     : float;
  gMatAusbringGew    : float;


  gErlGew       : float;
  gErlWert      : float;


  gWgrRohReturn : float;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  List_FontSize           # 7;

  Sel.von.Datum          # 01.01.2020;
  Sel.bis.Datum          # 31.01.2020;
  Sel.Fin.bis.Rechnung   # 9999999;
  Sel.Auf.Bis.Nummer     # 9999999;
  Sel.Auf.von.Wgr        # 0;

  if (gUsergroup = 'JOB-SERVER') or (gUserGroup=*^'SOA*') then begin
    Autogenerate();
    RETURN;
  end;

  RecBufClear(999);

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450502',here+':AusSel');
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
  vLine         : int;
  vRoh          : float;
  vRohWert      : float;
  vLohn         : float;
  vEff          : float;
  vGP           : float;
  vSchrottProz  : float;
  vVk           : float;
  vX            : float;

  vVkAuf        : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin
      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   22.0;
      List_Spacing[ 4]  #   30.0;
      List_Spacing[ 5]  #   47.0;
      List_Spacing[ 6]  #   53.0;
      List_Spacing[ 7]  #   80.0;
      List_Spacing[ 8]  #  100.0;
      List_Spacing[ 9]  #  102.0;
      List_Spacing[10]  #  110.0;
      List_Spacing[11]  #  130.0;
      List_Spacing[12]  #  137.0;
      List_Spacing[13]  #  160.0;
      List_Spacing[14]  #  180.0;
      List_Spacing[15]  #  182.0;
      List_Spacing[16]  #  190.0;
      List_Spacing[17]  #  210.0;
      List_Spacing[18]  #  217.0;
      List_Spacing[19]  #  240.0;

      LF_Set(1, 'Warengr'                                           ,n , 0);
      LF_Set(2,  ': '                                               ,n , 0);
      LF_Set(3,  ' von: '                                           ,n , 0);
      if (Sel.Auf.von.Wgr <> 0) then
        LF_Set(4,  ZahlI(Sel.Auf.von.Wgr)                           ,n , _LF_INT);
      LF_Set(5,  ' bis: '                                           ,n , 0);
      if (Sel.Auf.bis.Wgr <> 0) then
        LF_Set(6,  ZahlI(Sel.Auf.bis.Wgr)                           ,y , _LF_INT);
       LF_Set(7, 'Datum'        ,n , 0);
      LF_Set(8, ': '                                                ,n , 0);
      LF_Set(9, 'von: '                                             ,n , 0);
      if(Sel.von.Datum <> 0.0.0) then
        LF_Set(10, DatS(Sel.von.Datum)                         ,n , _LF_Date);
      LF_Set(11, ' bis: '                                           ,n , 0);
      if(Sel.bis.Datum <> 0.0.0) then
        LF_Set(12, DatS(Sel.bis.Datum)                         ,y , _LF_Date);
    end;


    'HEADER1' : begin

      if (aPrint) then RETURN;

      vX # 2.0;
      // Instanzieren...
      List_Spacing[ 1]  # 15.0; // Datum
      List_Spacing[ 2]  # 18.0; // Rechnung
      List_Spacing[ 3]  # 18.0; // Auftrag
      List_Spacing[ 4]  # 18.0; // Kunde
      List_Spacing[ 5]  # 30.0; // Qualität
      List_Spacing[ 6]  # 15.0; // Warengruppe
      List_Spacing[ 7]  # 15.0; // Einsatzgewicht
      List_Spacing[ 8]  # 15.0; // Ausbringungsgewicht
      List_Spacing[ 9]  # 15.0; // Schrott
      List_Spacing[10]  # 15.0; // Schrott %
      List_Spacing[11]  # 15.0; // VK / Tonne
      List_Spacing[12]  # 15.0; // VK Preis/To
      List_Spacing[13]  # 15.0; // Aufpreise
      List_Spacing[14]  # 15.0; // Summe
      List_Spacing[15]  # 15.0; // Rohertrag /to
      List_Spacing[16]  # 00.1; // Ende

      Lib_List2:ConvertWidthsToSpacings( 20 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set( 1, 'Datum'             ,y , 0);
      LF_Set( 2, 'Rechnung'          ,y , 0);
      LF_Set( 3, 'Auftrag'           ,y , 0);
      LF_Set( 4, 'Kunde'             ,n , 0);
      LF_Set( 5, 'Güte'              ,n , 0);
      LF_Set( 6, 'WGr.'              ,y , 0);
      LF_Set( 7, 'EG (kg)'           ,y , 0);
      LF_Set( 8, 'AG (kg)'           ,y , 0);
      LF_Set( 9, 'Schrott (kg)'      ,y , 0);
      LF_Set(10, '% Schrott'         ,y , 0);
      LF_Set(11, 'VK (kg)'           ,y , 0);
      LF_Set(12, 'VK-Preis/t'        ,y , 0);
      LF_Set(13, 'Aufpreise'         ,y , 0);
      LF_Set(14, 'Summe'             ,y , 0);
      LF_Set(15, 'Rohertrag/t'       ,y , 0);
    end;

    'LOHNRECH' : begin
      if (aPrint) then begin
        vVK # 0.0;
        vSchrottProz # gMatEinsatzGew - gMatAusbringGew;
        if (vSchrottProz<>0.0) AND (gMatEinsatzGew <> 0.0)then begin
          if (gMatEinsatzGew<>0.0) then
            vSchrottProz # vSchrottProz * 100.0 / gMatEinsatzGew;
        end;

        if (gErlGew<>0.0) AND (gMatEinsatzGew <> 0.0)then begin
          vVK   # gErlWert / gErlGew * 1000.0;
          vRohWert # gErlWert;
          vRoh  # vRohWert / gMatEinsatzGew * 1000.0;
        end

/*
        gMatEinsatzGew # gMatEinsatzGew/1000.0;
        gMatAusbringGew # gMatAusbringGew/1000.0;
        gErlGew # gErlGew / 1000.0;
*/
        Lf_Text( 3,aint(Sta.Auf.Nummer)+'/'+aint(Sta.Auf.Position));
        Lf_Text( 7,Anum(gMatEinsatzGew , 3));   // EG-t
        Lf_Text( 8,Anum(gMatAusbringGew , 3));  // AG-t
        Lf_Text( 9,Anum(gMatEinsatzGew-gMatAusbringGew, 2));              // Schrott
        Lf_Text(10,Anum(vSchrottProz, 2));    // Schrott %
        Lf_Text(11,Anum(gErlGew, 0));         // Rechungsgewicht (K)
        //Lf_Text(11,Anum(vVk, 2));             // VK/t (L)
        Lf_Text(12,Anum(Auf.P.Grundpreis, 2));             // VK/t aus Auftrag
        Lf_Text(13,Anum(Sta.Aufpreis.VK, 2));             // VK/t aus Auftrag
        Lf_Text(14,Anum(gErlWert, 2));        // Rechnungswert (M)
        Lf_Text(15,Anum(vRoh, 2));            // Rig/T

        AddSum(cSum_MatEkGew, gMatEinsatzGew);
        AddSum(cSum_MatAusGew,gMatAusbringGew);
        AddSum(cSum_ErlGew, gErlGew);
        AddSum(cSum_ErlWert, gErlWert);

        RETURN;
      end;
      LF_Set( 1, '@Sta.Re.Datum'        ,y , _LF_Date);
      LF_Set( 2, '@Sta.Re.Nummer'       ,y , _LF_IntNG);
      LF_Set( 3, '#Aufnummer'           ,y , 0);
      LF_Set( 4, '@Sta.Auf.Kunden.Sw'   ,n , 0);
      LF_Set( 5, '@Sta.Auf.Güte'        ,n , 0);
      LF_Set( 6, '@Sta.Auf.Warengruppe' ,y , _LF_IntNG);
      LF_Set( 7, '#EG-TO'               ,y , _LF_Num,0);
      LF_Set( 8, '#AG-TO'               ,y , _LF_Num,0);
      LF_Set( 9, '#Schrott'             ,y , _LF_Num,0);
      LF_Set(10, '#SchrottProz'         ,y , _LF_Num,0);
      LF_Set(11, '#ReGewicht'           ,y , _LF_Num,0);
      LF_Set(12, '#VK/to'               ,y , _LF_Wae);
      LF_Set(13, '#Aufpreise'           ,y , _LF_Wae);
      LF_Set(14, '#ReWert'              ,y , _LF_Num,0);
      LF_Set(15, '#Roh/to'              ,y , _LF_Wae);
    end;


    'SUM_GESAMT' : begin
      if (aPrint) then begin

        vRohWert # GetSum(cSum_ErlWert);
        
        // ST 2020-04-20 TODO: Hier die Materialkosten aus Statistik vom Erlös abziehen
        
        
        if (GetSum(cSum_MatEkGew)<>0.0) then
           vRoh  # vRohWert / GetSum(cSum_MatEkGew) * 1000.0;


        vSchrottProz # GetSum(cSum_MatEkGew)- GetSum(cSum_MatAusGew);
        if (vSchrottProz<>0.0) AND (GetSum(cSum_MatEkGew) <> 0.0)then begin
          if (GetSum(cSum_MatEkGew)<>0.0) then
            vSchrottProz # vSchrottProz * 100.0 / GetSum(cSum_MatEkGew);
        end;


        LF_Sum(7, cSum_MatEkGew  , 0);
        LF_Sum(8, cSum_MatAusGew  , 0);
        LF_Text(9, Anum(GetSum(cSum_MatEkGew)- GetSum(cSum_MatAusGew),0));
        LF_Text(10, Anum(vSchrottProz,2));
        LF_Sum(11,cSum_ErlGew  , 0);
        LF_Sum(14,cSum_ErlWert, 2);
        LF_Text(15,Anum(vRoh,2)) ;
        gWgrRohReturn # vRoh;
        RETURN;
      end;

      // Instanzieren...
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set(7, ''  ,y , _Lf_Num,0);
      LF_Set(8, ''  ,y , _Lf_Num,0);
      LF_Set(9, ''  ,y , _Lf_Num,0);
      LF_Set(10, '' ,y , _Lf_Num,0);
      LF_Set(11, '' ,y , _Lf_Num,0);
      LF_Set(14, '' ,y , _Lf_Wae);
      LF_Set(15, '' ,y , _Lf_Wae);
    end;

  end;  // case

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
    LF_Print(g_Sel1);
    LF_Print(g_Empty);
    LF_Print(g_Empty);
  end;

  LF_Print(g_Header1);
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
  vErg          : int;
  vSel          : int;
  vSelName      : alpha;
  vQ899         : alpha(4000);
  vProgress     : handle;

  vBisherRe     : int;
  vBisherLfs    : int;
  vBisherAuf    : int;
  vBisherAufPos : int;
  vGew          : float;
  vBuf          : int;
  vBuf2         : int;
end;
begin

  vQ899  # '';
  Lib_Sel:QVonBisI(var vQ899, 'Sta.Re.Nummer',    Sel.Fin.von.Rechnung ,  Sel.Fin.bis.Rechnung);
  Lib_Sel:QVonBisD(var vQ899, 'Sta.Re.Datum',     Sel.von.Datum ,         Sel.bis.Datum);
  Lib_Sel:QVonBisI(var vQ899, 'Sta.Auf.Nummer',   Sel.Auf.von.Nummer ,    Sel.Auf.bis.Nummer);
  Lib_Sel:QInt(var vQ899, 'Sta.Auf.Position',   '>' ,    0);    // nur ECHTE Posten
  Lib_Sel:QInt(var vQ899, 'Sta.Re.StornoRechNr',   '=' , 0);
  if (Sel.Auf.von.Wgr <> 0) then
    Lib_Sel:QInt(var vQ899, 'Sta.Auf.Warengruppe',     '=' ,    Sel.Auf.von.Wgr );

  // Hauptsel
  vSel # SelCreate(899, 0);
  vSel->SelAddSortFld(4,3);   // Warengruppe
  vSel->SelAddSortFld(3,4);   // KD-Stichwort
  vSel->SelAddSortFld(2,1);   // Re-Nummer
  vSel->SelAddSortFld(3,1);   // AufNr
  vSel->SelAddSortFld(4,1);   // AufPos


  Erg # vSel->SelDefQuery('', vQ899);
  if (Erg<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  // Ausgabe ----------------------------------------------------------------
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header1   # LF_NewLine('HEADER1');
  g_Lohnrech  # LF_NewLine('LOHNRECH');
  g_Gesamt    # LF_NewLine('SUM_GESAMT');

  if (gFrmMain > 0) then
    gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  vProgress # Lib_Progress:Init('Listengenerieung', RecInfo(899, _recCount, vSel));
  FOR   vErg # RecRead(899, vSel, _recFirst);
  LOOP  vErg # RecRead(899, vSel, _recNext);
  WHILE (vErg <= _rLocked) or ((vErg=_rNoRec) and (vBisherRe<>0)) DO BEGIN

    if (vProgress->Lib_Progress:Step() = false) then
      BREAK;

    // Nur Lohn
    AAr.Nummer # Sta.Auf.Auftragsart;
    RecRead(835,1,0);
    if (AAr.Berechnungsart < 700) OR (AAr.Berechnungsart > 710) then
      CYCLE;

    // Für Lohn alle BAGS in Auftragsaktion lesen
    // Einsatzmaterialien ermitteln
    // Ausbringungen Ermitteln (Einsatz - Restkarte = FM Gewicht)
    Auf_Data:Read(Sta.Auf.Nummer,Sta.Auf.Position,false);


    gMatEinsatzGew  # 0.0;
    gMatSchrottGew  # 0.0;
    gMatAusbringGew # 0.0;

    FOR   Erg  # RecLink(404,401,12,_RecFirst)
    LOOP  Erg  # RecLink(404,401,12,_RecNext)
    WHILE Erg = _rOK DO BEGIN
      if (Auf.A.Rechnungsnr <> Sta.Re.Nummer) OR (Auf.A.Aktionstyp <> c_Akt_BA) then
        CYCLE;

      // BAG P Lesen
      Bag.P.Nummer    # Auf.A.Aktionsnr;
      Bag.P.Position  # Auf.A.Aktionspos;
      RecRead(702,1,0);

      FOR   Erg  # RecLink(701,702,2,_RecFirst)
      LOOP  Erg  # RecLink(701,702,2,_RecNext)
      WHILE Erg = _rOK DO BEGIN
        if (BAG.IO.Materialtyp <> c_IO_Mat) then
          CYCLE;

        gMatEinsatzGew  #  gMatEinsatzGew + BAG.IO.Ist.In.GewN;
        gMatAusbringGew #  gMatAusbringGew + BAG.IO.Ist.Out.GewN;
      END;

    END;

    vGew  # 0.0;
    if (Sta.MEH.VK='kg') then
      vGew # Sta.Menge.VK;
    gErlGew       # vGew;
    gErlWert      # (Sta.Betrag.VK + Sta.Aufpreis.VK);

    LF_Print(g_LohnRech);

  END;  // Statistik

  SelClose(vSel);
  SelDelete(899, vSelName);
  vSel # 0;

  LF_Print(g_Gesamt);

  // Übergabe an Result
  gMatEinsatzGew # GetSum(cSum_MatEkGew);

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header1);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_LohnRech);
  LF_FreeLine(g_Gesamt);
end;



//========================================================================
//
//========================================================================
sub Autogenerate();
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin

  Sel.von.Datum         # Gv.Datum.01;
  Sel.bis.Datum         # GV.Datum.02;
  if (Gv.Ints.01 <> 0) then
    Sel.Auf.von.Wgr # Gv.Ints.01;

  StartList(0,'');

  // Ergebnis zurück
  vJSON # Lib_Json:OpenJSON();
  Lib_Json:AddJSONAlpha(vJSON,'Wgr_'+Aint(Sel.Auf.von.Wgr),ANum(gWgrRohReturn,2));

  gBCPS_ResultJson # Lib_Json:ToJsonList(vJson);
end;

//========================================================================
