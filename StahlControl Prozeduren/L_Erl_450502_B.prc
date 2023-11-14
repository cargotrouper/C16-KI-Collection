@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450502_B        (Variante aus Orignal Testdaten)
//
//  Info        Wareneinsatzliste für Tagesbericht
//
//
//
//  15.08.2019  ST  Erstellung der Prozedur
//  10.12.2019  AH  WIP
//  11.12.2019  AH  Fertig
//  17.01.2020  ST  Übergabe der Tagesmengen
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
  cSum_MatEkeffWert : 2
  cSum_ErlGew       : 3
  cSum_ErlWert      : 4
  cSum_Aufpreise    : 5


end;


local begin
  g_Empty             : int; // Handles für die Zeilenelemente
  g_Sel1              : int;
  g_Header1           : int;
  g_Lieferung         : int;
  g_Gesamt            : int;

  gMatEkGew     : float;
  gMatEkGpWert  : float;
  gMatEkeffWert : float;
  gAufpreise    : float;
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
      List_Spacing[ 4]  # 15.0; // Lfs
      List_Spacing[ 5]  # vX * 3.0;   // Qualität
      List_Spacing[ 6]  # vX * 2.0;   // Warengruppe
      List_Spacing[ 7]  # 15.0; // Geliefertes Gewicht + Schrott
      List_Spacing[ 8]  # 15.0; // EK Preis / to
      List_Spacing[ 9]  # 15.0; // Fremdlohnkosten
      List_Spacing[10]  # 15.0; // EK Preis eff
      List_Spacing[11]  # 15.0; // Summe
      List_Spacing[12]  # 15.0; // % Schrott
      List_Spacing[13]  # 15.0; // VK / Tonne
      List_Spacing[14]  # 15.0; // VK Preis/To
      List_Spacing[15]  # 15.0; // Summe
      List_Spacing[16]  # 18.0; // Rohertrag
      List_Spacing[17]  # 18.0; // Rohertrag/to
      List_Spacing[18]  # 15.0; // Kunde
      List_Spacing[19]  # 18.0; // Aufpreise
      List_Spacing[20]  # 00.1; // Ende

      Lib_List2:ConvertWidthsToSpacings( 20 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set( 1, 'Datum'             ,y , 0);
      LF_Set( 2, 'Rechnung'          ,y , 0);
      LF_Set( 3, 'Auftrag'           ,y , 0);
      LF_Set( 4, 'Lfs'               ,y , 0);
      LF_Set( 5, 'Güte'              ,n , 0);
      LF_Set( 6, 'WGr.'              ,y , 0);
      LF_Set( 7, 'EG (t)'            ,y , 0);
      LF_Set( 8, 'EK-Preis/t'        ,y , 0);
      LF_Set( 9, 'FLK inkl.Fracht/t' ,y , 0);
      LF_Set(10, 'EK-Preis/eff'      ,y , 0);
      LF_Set(11, 'Summe'             ,y , 0);
      LF_Set(12, '% Schrott'         ,y , 0);
      LF_Set(13, 'VK (t)'            ,y , 0);
      LF_Set(14, 'VK-Preis/t'        ,y , 0);
      LF_Set(15, 'Summe'             ,y , 0);
      LF_Set(16, 'Rohertrag'         ,y , 0);
      LF_Set(17, 'Rohertrag/t'       ,y , 0);
      LF_Set(18, 'Kunde'             ,n , 0);
      LF_Set(19, 'Kopfaufpr.'        ,y , 0);
    end;

    'LIEFERUNG' : begin
      if (aPrint) then begin
        vSchrottProz # gMatEkGew - gErlGew;
        if (vSchrottProz<>0.0) then begin
          if (gMatEkGew<>0.0) then
            vSchrottProz # vSchrottProz * 100.0 / gMatEkGew;
        end;

        vRohWert # gErlWert - gMatEkEffWert - gAufpreise;
        if (gErlGew<>0.0) then begin
          vGP   # gMatEkGpWert / gErlGew * 1000.0;;
          vEff  # gMatEkEffWert / gErlGew * 1000.0;
          vVK   # gErlWert / gErlGew * 1000.0;
          vRoh  # vRohWert / gErlGew * 1000.0;
        end
        vLohn # vEff - vGP;

        Lf_Text(3,aint(Sta.Auf.Nummer)+'/'+aint(Sta.Auf.Position));
        Lf_Text(7,Anum(gMatEkGew, 0));        // EG-t (F)
        Lf_Text(8,Anum(vGP, 2));              // Grundpreis/t
        Lf_Text( 9,Anum(vLohn, 2));           // Lohnkosten/t
        Lf_Text(10,Anum(vEff, 2));            // Effektiv/t
        Lf_Text(11,Anum(gMatEkeffWert, 2));   // Summe EK
        Lf_Text(12,Anum(vSchrottProz, 2));    // Schrottprozent (J)
        Lf_Text(13,Anum(gErlGew, 0));         // Rechungsgewicht (K)
        Lf_Text(14,Anum(vVk, 2));             // VK/t (L)
        Lf_Text(15,Anum(gErlWert, 2));        // Rechnungswert (M)
        Lf_Text(16,Anum(vRohWert, 2));        // Rohertrag (N)
        Lf_Text(17,Anum(vRoh, 2));            // Rohertrag/t (O)
        Lf_Text(19,Anum(gAufpreise, 2));      // Aufpreise VK (Q)
        AddSum(cSum_MatEkGew, gMatEkGew);
        AddSum(cSum_MatEkeffWert, gMatEkeffWert);
        AddSum(cSum_ErlGew, gErlGew);
        AddSum(cSum_ErlWert, gErlWert);
        AddSum(cSum_Aufpreise, gAufpreise);
        RETURN;
      end;
      LF_Set( 1, '@Sta.Re.Datum'        ,y , _LF_Date);
      LF_Set( 2, '@Sta.Re.Nummer'       ,y , _LF_IntNG);
      LF_Set( 3, '#Aufnummer'           ,y , 0);
      LF_Set( 4, '@Sta.Lfs.Nummer'      ,y , _LF_IntNG);
      LF_Set( 5, '@Sta.Auf.Güte'        ,n , 0);
      LF_Set( 6, '@Sta.Auf.Warengruppe' ,y , _LF_IntNG);

      LF_Set( 7, '#EG-TO'               ,y , _LF_Num,0);
      LF_Set( 8, '#Mat.EK.Preis'        ,y , _LF_Wae);
      LF_Set( 9, '#Mat.Kosten'          ,y , _LF_Wae);
      LF_Set(10, '#Mat.EK.Effektiv'     ,y , _LF_Wae);
      LF_Set(11, '#Summe'               ,y , _LF_Wae);
      LF_Set(12, '#Schrott'             ,y , _LF_Num,0);
      LF_Set(13, '#Mat.VK.Gewicht'      ,y , _LF_Num,0);
      LF_Set(14, '#Mat.VK.Preis'        ,y , _LF_Wae);
      LF_Set(15, '#Summe'               ,y , _LF_Wae);
      LF_Set(16, '#Rohertrag'           ,y , _LF_Wae);
      LF_Set(17, '#Rohertrag/to'        ,y , _LF_Wae);
      LF_Set(18, '@Sta.Auf.Kunden.SW'   ,n , 0);
      LF_Set(19, '#Aufpreise EUR'       ,y , _LF_Wae);
    end;


    'SUM_GESAMT' : begin
      if (aPrint) then begin
        vRohWert # GetSum(cSum_ErlWert) - GetSum(cSum_MatEkEffWert) - GetSum(cSum_Aufpreise);
        if (GetSum(cSum_ErlGew)<>0.0) then
           vRoh  # vRohWert / GetSum(cSum_ErlGew) * 1000.0;

        LF_Sum(7, cSum_MatEkGew  , 0);
        LF_Sum(11,cSum_MatEkEffWert, 2);
        LF_Sum(13,cSum_ErlGew, 0);
        LF_Sum(15,cSum_ErlWert, 2);
        Lf_Text(16,anum(vRohWert, 2));
        Lf_Text(17,Anum(vRoh, 2));            // Rohertrag/t (O)
        LF_Sum(19,cSum_Aufpreise, 2);

        gWgrRohReturn # vRoh;
        RETURN;
      end;

      // Instanzieren...
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set( 7, '' ,y , _Lf_Num,0);
      LF_Set(11, '' ,y , _Lf_Wae);
      LF_Set(13, '' ,y , _Lf_Num,0);
      LF_Set(15, '' ,y , _Lf_Wae);
      LF_Set(16, '' ,y , _Lf_Wae);
      LF_Set(17, '' ,y , _Lf_Wae);
      LF_Set(19, '' ,y , _Lf_Wae);
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
  
/*
  if (Sel.Adr.von.KdNr <> 0) then
    Lib_Sel:QInt(var vQ899, 'Sta.Auf.Kunden.Nr',     '=' ,    Sel.Adr.von.KdNr);
  if (Sel.Adr.von.Vertret <> 0) then begin
    Lib_Sel:QInt(var vQ899, 'Sta.Re.Vertreter.Nr',     '=' ,    Sel.Adr.von.Vertret);
  end;

  if (Sel.Auf.von.Wgr <> 0) then
    Lib_Sel:QInt(var vQ899, 'Sta.Auf.Warengruppe',     '=' ,    Sel.Auf.von.Wgr );
*/

  // Hauptsel
  vSel # SelCreate(899, 0);
  vSel->SelAddSortFld(4,3);   // Warengruppe
  
  vSel->SelAddSortFld(3,4);   // KD-Stichwort
  vSel->SelAddSortFld(2,1);   // Re-Nummer
  vSel->SelAddSortFld(3,1);   // AufNr
  vSel->SelAddSortFld(4,1);   // AufPos
//  vSel->SelAddSortFld(2,2);   // Re-Pos
  vSel->SelAddSortFld(5,1);   // LFS-Nummer
  Erg # vSel->SelDefQuery('', vQ899);
  if (Erg<>0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  // Ausgabe ----------------------------------------------------------------
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header1   # LF_NewLine('HEADER1');

  g_Lieferung # LF_NewLine('LIEFERUNG');
  g_Gesamt    # LF_NewLine('SUM_GESAMT');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  vProgress # Lib_Progress:Init('Listengenerieung', RecInfo(899, _recCount, vSel));
  FOR   vErg # RecRead(899, vSel, _recFirst);
  LOOP  vErg # RecRead(899, vSel, _recNext);
  WHILE (vErg <= _rLocked) or ((vErg=_rNoRec) and (vBisherRe<>0)) DO BEGIN

    if (Sta.Re.Nummer= 3004195) then
      debug('chgeck');


    if (vBuf=0) then vBuf # RekSave(899);
    if (vProgress->Lib_Progress:Step() = false) then
      BREAK;
    
//debugx('Re'+aint(Sta.Re.Nummer)+'/'+aint(Sta.Re.Position)+' Auf'+aint(Sta.Auf.Nummer)+'/'+aint(Sta.Auf.Position)+' Lfs'+aint(Sta.Lfs.Nummer)+'/'+aint(Sta.Lfs.Position)+' Mat'+aint(Sta.Lfs.Materialnr));

    // WECHSEL?
    if (vBisherRe<>0) and
      ((vErg=_rNoRec) or (vBisherAuf<>Sta.Auf.Nummer) or (vBisherAufPos<>Sta.Auf.Position) or
      (vBisherRe<>Sta.Re.Nummer) or (vBisherLfs<>Sta.Lfs.Nummer)) then begin

      // DRUCKEN
      vBuf2 # RekSave(899);
      RecBufCopy(vBuf, 899);

      // alle Kopfaufpreise addieren -----------------------------
      // nur am Ende oder Re.Wechsel...
      if (vErg=_rNorec) or (vBisherRe<>Sta.Re.Nummer) then begin
        RecbufClear(451);
        Erl.K.Auftragsnr  # Sta.Auf.Nummer;
        Erl.K.Auftragspos # 0;
        Erg # RecRead(451,2,0);
        WHILE (erg<=_rMultikey) and (Erl.K.Auftragsnr=Sta.Auf.Nummer) and (Erl.K.Auftragspos=0) do begin
          gAufpreise # gAufpreise + Erl.K.BetragW1;
  //debugx('aufpreis KEY451');
          Erg # RecRead(451,2,_RecNext);
        END;
      end;

//  debug('print');
      
      // Lohn  ?????
      AAr.Nummer # Sta.Auf.Auftragsart;
      RecRead(835,1,0);
      
      if (AAr.Berechnungsart >= 700) then begin
      
        // Für Lohn alle BAGS in Auftragsaktion lesen
        // Einsatzmaterialien ermitteln
        // Ausbringungen Ermitteln (Einsatz - Restkarte = FM Gewicht)
        Auf_Data:Read(Sta.Auf.Nummer,Sta.Auf.Position,false);
        
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

            gMatEkGew # gMatEkGew + BAG.IO.Ist.In.Menge;
          END;

        END;

        vGew  # 0.0;
        if (Sta.MEH.VK='kg') then
          vGew # Sta.Menge.VK;
        gErlGew       # gErlGew + vGew;
                
        gErlWert      # gErlWert + (Sta.Betrag.VK + Sta.Aufpreis.VK);
      end;
        
  


      LF_Print(g_Lieferung);
      RekRestore(vBuf2);
      gMatEkGew     # 0.0;
      gMatEkGpWert  # 0.0;
      gMatEkEffWert # 0.0;
      gErlGew       # 0.0;
      gErlWert      # 0.0;
      gAufpreise    # 0.0;
    end;
    if (vErg=_rNorec) then BREAK;


    vBisherRe     # Sta.Re.Nummer;
    vBisherLfs    # Sta.Lfs.Nummer;
    vBisherAuf    # Sta.Auf.Nummer;
    vBisherAufPos # Sta.Auf.Position;
    // Material bestimmen...
    Erg # Mat_Data:Read(Sta.Lfs.Materialnr);
    if (Erg < 200) then CYCLE;
    vGew # 0.0;
    if (Sta.MEH.VK='kg') then
      vGew # Sta.Menge.VK;
//debug('ADD');
    gMatEkGew     # gMatEkGew + BA1_FM_Data:CalcSchrottGewAnteil(Mat.Nummer) + Mat.Bestand.Gew;
    gMatEkGpWert  # gMatEkGpWert + (Mat.EK.Preis * vGew / 1000.0);
    gMatEkeffWert # gMatEkeffWert + (Mat.EK.Effektiv * vGew / 1000.0);
    gErlGew       # gErlGew + vGew;
    gErlWert      # gErlWert + (Sta.Betrag.VK + Sta.Aufpreis.VK);
    RecBufCopy(899, vBuf);

  END;  // Statistik

  if (vBuf<>0) then RecBufDestroy(vBuf);

  SelClose(vSel);
  SelDelete(899, vSelName);
  vSel # 0;

  LF_Print(g_Gesamt);

  // Übergabe an Result
  gMatEkGew # GetSum(cSum_MatEkGew);

  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header1);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Lieferung);
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
  Lib_Json:AddJSONAlpha(vJSON,'KgVormat', ANum(gMatEkGew,0));
  Lib_Json:AddJSONAlpha(vJSON,'Wgr_'+Aint(Sel.Auf.von.Wgr),ANum(gWgrRohReturn,2));

  gBCPS_ResultJson # Lib_Json:ToJsonList(vJson);
end;

//========================================================================
