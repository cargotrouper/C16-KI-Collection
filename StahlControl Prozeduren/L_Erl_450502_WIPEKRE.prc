@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450502
//
//  Info        Wareneinsatzliste für Tagesbericht
//
//
//
//  15.08.2019  ST  Erstellung der Prozedur
//  10.12.2019  AH  WIP
//  11.12.2019  AH  Fertig
//  17.01.2020  ST  Übergabe der Tagesmengen
//  22.04.2020  ST  Bugfix: Ausgabe leer Summen
//  20.05.2020  AH  Fixe
//  25.06.2021  ST  Diverse erweiterungen
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


  cMaxSchrottProz : 6.0
  cNurPositiverSchrott : false

end;


local begin
  g_Empty       : int; // Handles für die Zeilenelemente
  g_Sel1        : int;
  g_Header1     : int;
  g_Lieferung   : int;
  g_Gesamt      : int;

  gMatEkGew     : float;
  gMatEkGpWert  : float;
  gMatEkeffWert : float;
  gAufpreise    : float;
  gErlGew       : float;
  gErlWert      : float;


  gWgrRohReturn : float;
  gErrMark      : alpha;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  List_FontSize           # 7;

  Sel.bis.Datum          # today;
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
//========================================================================
//  CalcSchrottGewAnteil
//      Errechnet das Gewicht von BA-Schrott "auf dem Weg zum Material"
//      das anteilig am FM-Gewicht
//========================================================================
sub CalcSchrottGewAnteil(
  aMat                : int;
  var aLFGutschrPerT  : float;
  var aLohnfremdk     : float;
  aSubProz            : float;
  aBrutto             : logic;
  var aLfGutschMatDict : int;
  var aLfKostMatDict   : int;

  ) : float;
local begin
  Erx       : int;
  v200      : int;
  vIchKG    : float;
  vSchrott  : float;
  vProz     : float;
  vAnteil   : float;
  vX        : float;
  vY        : float;
  vIN, vOUt : float;

  vDebug : alpha(1000);

  v200Ursp  : int;
  vTmp : alpha;

  vFremdLohnK : float;
end;
begin
  v200 # RekSave(200);

  if (Mat.Nummer<>aMat) then begin
    Erg # Mat_Data:Read(aMat);
    if (Erg<200) then begin
      RekRestore(v200);
      RETURN 0.0;
    end;
  end;


  RecBufClear(707);                     // BA-FM leeren

  erx # RecLink(707,200,28,_recFirst);  // FM suchen
  if (erx>=_rLocked) then begin
    if ("Mat.Vorgänger"<>0) then begin
      RekRestore(v200);
      RETURN CalcSchrottGewAnteil("Mat.Vorgänger",var aLFGutschrPerT, var aLohnfremdk,0.0,aBrutto, var aLfGutschMatDict, var aLfKostMatDict);
    end;
    RETURN 0.0;
  end;

  vIchKG  # BAG.FM.Gewicht.Netto;
  if (aBrutto) then
    vIchKG  # BAG.FM.Gewicht.Brutt;

  Erg # RecLink(701,707,9,_recFirst);   // IO-Input holen
  if (erg>_rLocked) then begin
    RekRestore(v200);
    RETURN 0.0;
  end;

  if (BAG.IO.Materialnr=0) then begin
    RekRestore(v200);
    RETURN 0.0;
  end;

  vOUT  # BAG.IO.Ist.Out.GewN;
  vIN   # BAG.IO.Plan.In.GewN;
  if (aBrutto) then begin
    vOUT # BAG.IO.Ist.Out.GewB;
    vIN # BAG.IO.Plan.In.GewB;
  end;


  vProz # Lib_Berechnungen:Prozent(vIchKG, vOut);
  vY # vProz;
  if (aSubProz<>0.0) then begin
    vProz # vProz * (aSubProz / 100.0);
  end;

  vSchrott # vIN - vOut;
  vAnteil   # vSchrott * (vProz / 100.0); // Original

  if (cNurPositiverSchrott) AND (vSchrott < 0.0) then
    vAnteil # 0.0;
    
//  if (gUSername='AH' or (gUsername = 'ST')) and (vAnteil<>1231230.0) then begin
  if (aSubProz=0.0) then begin
    debug('START');
    vDebug # 'KEY200 aus KEY701 nach pos '+Aint(BAG.IO.NachPosition)+' Mat' + Aint(BAG.IO.Materialnr) +
            ' : SumSchrott '+anum(vSchrott,0)+'kg , IN:'+anum(vIN,0)+'kg, FM:'+anum(vIchKG,0)+'kg, Out:'+Anum(vOut,0) + 'kg => '+anum(vProz,3)+'% ===> +'+anum(vAnteil,5)+'kg';
  end else begin
    vDebug # 'KEY200 aus KEY701 nach pos '+Aint(BAG.IO.NachPosition)+' Mat' + Aint(BAG.IO.Materialnr) +
          ' : SumSchrott '+anum(vSchrott,0)+'kg , IN:'+anum(vIN,0)+'kg, FM:'+anum(vIchKG,0)+'kg, Out:'+Anum(vOut,0) + 'kg => '+anum(aSubPRoz,3)+'% von '+anum(vY,3)+'%='+anum(vProz,3)+'% ===> +'+anum(vAnteil,5)+'kg';
  end;

  debug(vDebug);
//  end;

  RekLink(702,701,4,0);
  if (BAG.P.ExternYN) AND (BAG.P.Kosten.Pro <> 0.0) then begin
    vFremdLohnK  # BAG.P.Kosten.Pro * (vIchKG / 1000.0);
    aLohnfremdk # aLohnfremdk + vFremdLohnK;
    debug('   FLK aus KEY702 für ' + Anum(vIchKG,2) + ' kg zu ' + Anum(BAG.P.Kosten.Pro,2) + ' = ' + Anum(vFremdLohnK,2)  + '  ->  Gesamt= ' + Anum(aLohnfremdk,2));
  end;


  // ST 2021-06-17
  // Keine Weitgerverarbeitung -> Dann Prüfung auf Einsatzmat Gutschriften VON Vorgänger
  if (Lib_Dict:Read(var aLfGutschMatDict,Aint(Mat.Ursprung),var vTmp) = false) then begin

    v200Ursp # RecBufCreate(200);
    v200Ursp->Mat.Nummer # Mat.Ursprung;
    Erx # RecRead(v200Ursp, 1,0);
    if (Erx = _rOK) then begin
      FOR   Erx # RecLink(204,v200Ursp,14,_RecFirst)
      LOOP  Erx # RecLink(204,v200Ursp,14,_RecNext)
      WHILE Erx = _rOK DO BEGIN
        if (Mat.A.Aktionstyp <> 'GBMAT') then
          CYCLE;

        aLFGutschrPerT # aLFGutschrPerT + Mat.A.KostenW1;
      END;
      if (aLFGutschrPerT <> 0.0) then begin
        Lib_Dict:Add(var aLfGutschMatDict,Aint(Mat.A.Materialnr), Anum(aLFGutschrPerT,2));
        debug('GBMATSs auf Mat: ' +Aint(v200Ursp->Mat.Nummer)+ '  = '  + Anum(aLFGutschrPerT,2) + ' pro/t');
      end;
    end;
    RecBufDestroy(v200Ursp);
  end;

  // ST 2021-06-25
  // Prüfung auf EFremdlohnkosten
  /*
  aLFGutschrPerT # 0.0;
  aLfkPerT       # 0.0;
  v200Ursp # RecBufCreate(200);
  v200Ursp->Mat.Nummer # Mat.Ursprung;
  Erx # RecRead(v200Ursp, 1,0);
  if (Erx = _rOK) then begin
    FOR   Erx # RecLink(204,v200Ursp,14,_RecFirst)
    LOOP  Erx # RecLink(204,v200Ursp,14,_RecNext)
    WHILE Erx = _rOK DO BEGIN


      if (Mat.A.Aktionstyp = 'GBMAT') AND
        (Lib_Dict:Read(var aLfGutschMatDict,Aint(Mat.Ursprung),var vTmp) = false) then begin
        aLFGutschrPerT # aLFGutschrPerT + Mat.A.KostenW1;
      end;

      if (Mat.A.KostenW1 <> 0.0) AND (Mat.A.Adressnr <> 0) AND
        (Lib_Dict:Read(var aLfKostMatDict,Aint(Mat.Ursprung),var vTmp) = false) then begin
        aLfkPerT # aLfkPerT + Mat.A.KostenW1;
      end;

    END;
    if (aLFGutschrPerT <> 0.0) then begin
      Lib_Dict:Add(var aLfGutschMatDict,Aint(Mat.A.Materialnr), Anum(aLFGutschrPerT,2));
      debug('GBMATSs auf Mat: ' +Aint(v200Ursp->Mat.Nummer)+ '  = '  + Anum(aLFGutschrPerT,2) + ' pro/t');
    end;
    if (aLfkPerT <> 0.0) then begin
      Lib_Dict:Add(var aLfKostMatDict,Aint(Mat.A.Materialnr), Anum(aLfkPerT,2));
      debug('FLK auf Mat: ' +Aint(v200Ursp->Mat.Nummer)+ '  = '  + Anum(aLfkPerT,2) + ' pro/t');
    end;
  end;
  RecBufDestroy(v200Ursp);

  // Prüfung auf EFremdlohnkosten
  aLfkPerT       # 0.0;
  if (Lib_Dict:Read(var aLfKostMatDict,Aint(Mat.Nummer),var vTmp) = false) then begin

    FOR   Erx # RecLink(204,200,14,_RecFirst)
    LOOP  Erx # RecLink(204,200,14,_RecNext)
    WHILE Erx = _rOK DO BEGIN
      if (Mat.A.KostenW1 <> 0.0) AND (Mat.A.Adressnr <> 0) then
        aLfkPerT # aLfkPerT + Mat.A.KostenW1;
    END;

    if (aLfkPerT <> 0.0) then begin
      Lib_Dict:Add(var aLfKostMatDict,Aint(Mat.A.Materialnr), Anum(aLfkPerT,2));
      debug('FLK auf Mat: ' +Aint(Mat.A.Materialnr)+ '  = '  + Anum(aLfkPerT,2) + ' pro/t');
    end;
  end;

  */

  // Wenn MatNr=RestMatNr dann ist die Mat-IO eine Weiterbearbeitung!
  if (BAG.IO.Materialnr=BAG.IO.MaterialRstNr) then begin

    Erg # Mat_Data:Read(BAG.IO.MaterialRstNr);
    if (Erg<200) then begin
      RekRestore(v200);
      RETURN vAnteil;
    end;
    vX # vAnteil + CalcSchrottGewAnteil(Mat.Nummer, var aLFGutschrPerT, var aLohnfremdk, vProz, aBrutto, var aLfGutschMatDict, var aLfKostMatDict);
    RekRestore(v200);
    RETURN vX;
  end else begin
  
   
    if (BAG.IO.VonID = 0) AND (BAG.IO.Materialnr <> 0) AND (BAG.IO.Materialtyp = c_IO_Mat) then begin
      // NBeim Einsatzmaterial angekommen, dann ggf. Einatz aus ggf. vorherigem BA mit betrachten
       Erg # Mat_Data:Read(BAG.IO.Materialnr);
      if (Erg<200) then begin
        RekRestore(v200);
        RETURN vAnteil;
      end;
      vX # vAnteil + CalcSchrottGewAnteil(Mat.Nummer, var aLFGutschrPerT, var aLohnfremdk, vProz, aBrutto, var aLfGutschMatDict, var aLfKostMatDict);
      RekRestore(v200);
      RETURN vX;
    end;
  
  
  end;

  RekRestore(v200);

   // Einsatz ist MATERIAL?
  RETURN vAnteil;
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
      List_Spacing[ 5]  # 15.0; // Lfs
      
      List_Spacing[ 6]  # vX * 3.0;   // Qualität
      List_Spacing[ 7]  # vX * 2.0;   // Warengruppe
      List_Spacing[ 8]  # 15.0; // Geliefertes Gewicht + Schrott
      List_Spacing[ 9]  # 15.0; // EK Preis / to
      List_Spacing[10]  # 15.0; // Fremdlohnkosten
      List_Spacing[11]  # 15.0; // EK Preis eff
      List_Spacing[12]  # 15.0; // Summe
      List_Spacing[13]  # 15.0; // % Schrott
      List_Spacing[14]  # 15.0; // VK / Tonne
      List_Spacing[15]  # 15.0; // VK Preis/To
      List_Spacing[16]  # 15.0; // Summe
      List_Spacing[17]  # 18.0; // Rohertrag
      List_Spacing[18]  # 18.0; // Rohertrag/to
      List_Spacing[19]  # 15.0; // Kunde
      List_Spacing[20]  # 18.0; // Aufpreise
      List_Spacing[21]  # 19.0; // Errormark
      List_Spacing[22]  # 00.1; // Ende

      Lib_List2:ConvertWidthsToSpacings( 22 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set( 1, 'Datum'             ,y , 0);
      LF_Set( 2, 'Rechnung'          ,y , 0);
      LF_Set( 3, 'Auftrag'           ,y , 0);
      LF_Set( 4, 'Lfs'               ,y , 0);
      LF_Set( 5, 'EK RE'             ,y , 0);
      LF_Set( 6, 'Güte'              ,n , 0);
      LF_Set( 7, 'WGr.'              ,y , 0);
      LF_Set( 8, 'EG (kg)'           ,y , 0);
      LF_Set( 9, 'EK-Preis/t'        ,y , 0);
      LF_Set(10, 'FLK inkl.Fracht/t' ,y , 0);
      LF_Set(11, 'EK-Preis/eff'      ,y , 0);
      LF_Set(12, 'Summe'             ,y , 0);
      LF_Set(13, '% Schrott'         ,y , 0);
      LF_Set(14, 'VK (kg)'           ,y , 0);
      LF_Set(15, 'VK-Preis/t'        ,y , 0);
      LF_Set(16, 'Summe'             ,y , 0);
      LF_Set(17, 'Rohertrag'         ,y , 0);
      LF_Set(18, 'Rohertrag/t'       ,y , 0);
      LF_Set(19, 'Kunde'             ,n , 0);
      LF_Set(20, 'Kopfaufpr.'        ,y , 0);
      LF_Set(21, 'SCHROTTABWEICHUNG' ,y , 0);
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
          vGP # gMatEkGpWert  / gMatEkGew * 1000.0;
          vEff  # gMatEkEffWert / gMatEkGew * 1000.0;


          vVK   # gErlWert / gErlGew * 1000.0;
          vRoh  # vRohWert / gErlGew * 1000.0;
        end
        vLohn # vEff - vGP;  // TODO Fehlt noch

        Lf_Text(3,aint(Sta.Auf.Nummer)+'/'+aint(Sta.Auf.Position));
        
        Lf_Text(5,aint(EKK.EingangsreNr));
        
        Lf_Text(7,Anum(gMatEkGew, 0));        // EG-t (F)
        Lf_Text(8,Anum(vGP, 2));              // Grundpreis/t
        Lf_Text(9,Anum(vLohn, 2));           // Lohnkosten/t
        Lf_Text(10,Anum(vEff, 2));            // Effektiv/t
        Lf_Text(11,Anum(gMatEkeffWert, 2));   // Summe EK
        Lf_Text(12,Anum(vSchrottProz, 2));    // Schrottprozent (J)
        Lf_Text(13,Anum(gErlGew, 0));         // Rechungsgewicht (K)
        Lf_Text(14,Anum(vVk, 2));             // VK/t (L)
        Lf_Text(15,Anum(gErlWert, 2));        // Rechnungswert (M)
        Lf_Text(16,Anum(vRohWert, 2));        // Rohertrag (N)
        Lf_Text(17,Anum(vRoh, 2));            // Rohertrag/t (O)
        Lf_Text(19,Anum(gAufpreise, 2));      // Aufpreise VK (Q)
        Lf_Text(20,gErrMark);                  // Fehhlermakr
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
      LF_Set( 5, '#EKReNummer'          ,y , _LF_IntNG);
      
      LF_Set( 6, '@Sta.Auf.Güte'        ,n , 0);
      LF_Set( 7, '@Sta.Auf.Warengruppe' ,y , _LF_IntNG);
      LF_Set( 8, '#EG-TO'               ,y , _LF_Num,0);
      LF_Set( 9, '#Mat.EK.Preis'        ,y , _LF_Wae);
      LF_Set(10, '#Mat.Kosten'          ,y , _LF_Wae);
      LF_Set(11, '#Mat.EK.Effektiv'     ,y , _LF_Wae);
      LF_Set(12, '#Summe'               ,y , _LF_Wae);
      LF_Set(13, '#Schrott'             ,y , _LF_Num,0);
      LF_Set(14, '#Mat.VK.Gewicht'      ,y , _LF_Num,0);
      LF_Set(15, '#Mat.VK.Preis'        ,y , _LF_Wae);
      LF_Set(16, '#Summe'               ,y , _LF_Wae);
      LF_Set(17, '#Rohertrag'           ,y , _LF_Wae);
      LF_Set(18, '#Rohertrag/to'        ,y , _LF_Wae);
      LF_Set(19, '@Sta.Auf.Kunden.SW'   ,n , 0);
      LF_Set(20, '#Aufpreise EUR'       ,y , _LF_Wae);
      LF_Set(21, '#ErrorMark'           ,n , 0);
    end;


    'SUM_GESAMT' : begin
      if (aPrint) then begin
        vRohWert # GetSum(cSum_ErlWert) - GetSum(cSum_MatEkEffWert) - GetSum(cSum_Aufpreise);
        if (GetSum(cSum_ErlGew)<>0.0) then
           vRoh  # vRohWert / GetSum(cSum_ErlGew) * 1000.0;

        LF_Sum(8, cSum_MatEkGew  , 0);
        LF_Sum(12,cSum_MatEkEffWert, 2);
        LF_Sum(14,cSum_ErlGew, 0);
        LF_Sum(16,cSum_ErlWert, 2);
        Lf_Text(17,anum(vRohWert, 2));
        Lf_Text(18,Anum(vRoh, 2));            // Rohertrag/t (O)
        LF_Sum(20,cSum_Aufpreise, 2);

        gWgrRohReturn # vRoh;
        RETURN;
      end;

      // Instanzieren...
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set( 8, '' ,y , _Lf_Num,0);
      LF_Set(12, '' ,y , _Lf_Wae);
      LF_Set(14, '' ,y , _Lf_Num,0);
      LF_Set(16, '' ,y , _Lf_Wae);
      LF_Set(17, '' ,y , _Lf_Wae);
      LF_Set(18, '' ,y , _Lf_Wae);
      LF_Set(20, '' ,y , _Lf_Wae);
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
  Erx           : int;

  vErg          : int;
  vSel          : int;
  vSelName      : alpha;
  vQ899         : alpha(4000);
  vProgress     : handle;

  vBisherKunde  : alpha;
  vBisherRe     : int;
  vBisherLfs    : int;
  vBisherAuf    : int;
  vBisherAufPos : int;
  vBisherEre    : int;

  vGew          : float;
  vBuf          : int;
  vBuf2         : int;

  vI  : int;
  vX  : float;
  vMatEK  : float;
  vMatEff : float;

  vLFGutschrPerT    : float;
  vLfGutschMatDict  : int;

  vItem : int;

  vFremdLohnKosten : float;
  vFremdLohnKostenDict : int;

end;
begin

  vQ899  # '';
  Lib_Sel:QVonBisI(var vQ899, 'Sta.Re.Nummer',    Sel.Fin.von.Rechnung ,  Sel.Fin.bis.Rechnung);
  Lib_Sel:QVonBisD(var vQ899, 'Sta.Re.Datum',     Sel.von.Datum ,         Sel.bis.Datum);
  Lib_Sel:QVonBisI(var vQ899, 'Sta.Auf.Nummer',   Sel.Auf.von.Nummer ,    Sel.Auf.bis.Nummer);
  Lib_Sel:QInt(var vQ899, 'Sta.Auf.Position',   '>' ,    0);    // nur ECHTE Posten
  Lib_Sel:QInt(var vQ899, 'Sta.Re.StornoRechNr',   '=' , 0);
  if (Sel.Adr.von.KdNr <> 0) then
    Lib_Sel:QInt(var vQ899, 'Sta.Auf.Kunden.Nr',     '=' ,    Sel.Adr.von.KdNr);
  if (Sel.Adr.von.Vertret <> 0) then begin
    Lib_Sel:QInt(var vQ899, 'Sta.Re.Vertreter.Nr',     '=' ,    Sel.Adr.von.Vertret);
  end;

  if (Sel.Auf.von.Wgr <> 0) then
    Lib_Sel:QInt(var vQ899, 'Sta.Auf.Warengruppe',     '=' ,    Sel.Auf.von.Wgr );


  // Hauptsel
  vSel # SelCreate(899, 0);
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

  if (gFrmMain > 0) then
    gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape



  vProgress # Lib_Progress:Init('Listengenerierung', RecInfo(899, _recCount, vSel));
  FOR   vErg # RecRead(899, vSel, _recFirst);
  LOOP  vErg # RecRead(899, vSel, _recNext);
  WHILE (vErg <= _rLocked) or ((vErg=_rNoRec) and (vBisherRe<>0)) DO BEGIN
    AAr.Nummer # Sta.Auf.Auftragsart;
    RecRead(835,1,0);
    if (AAr.Berechnungsart > 250) then
      CYCLE;

    if (vBuf=0) then vBuf # RekSave(899);

    if (!vProgress->Lib_Progress:Step()) then begin     // Progress
      SelClose(vSel);
      SelDelete(899, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;


    // WECHSEL?
    if (vBisherRe<>0) and
      ((vErg=_rNoRec) or (vBisherKunde <> Sta.Auf.Kunden.SW) or (vBisherAuf<>Sta.Auf.Nummer) or (vBisherAufPos<>Sta.Auf.Position) or
      (vBisherRe<>Sta.Re.Nummer) or (vBisherLfs<>Sta.Lfs.Nummer) or (vBisherEre <> EKK.EingangsreNr)) then begin

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
      if (vI > 0) then
        LF_Print(g_Lieferung);
      vi # 0;
      RekRestore(vBuf2);
      gMatEkGew     # 0.0;
      gMatEkGpWert  # 0.0;
      gMatEkEffWert # 0.0;
      gErlGew       # 0.0;
      gErlWert      # 0.0;
      gAufpreise    # 0.0;
      gErrMark      # '';

      Lib_Dict:Clear(var vLfGutschMatDict);
      Lib_Dict:Clear(var vFremdLohnKostenDict);


    end;
    if (vErg=_rNorec) then BREAK;


    vBisherKunde  # Sta.Auf.Kunden.SW;
    vBisherRe     # Sta.Re.Nummer;
    vBisherLfs    # Sta.Lfs.Nummer;
    vBisherAuf    # Sta.Auf.Nummer;
    vBisherAufPos # Sta.Auf.Position;
    vBisherEre    # EKK.EingangsreNr;
    
    
    // Material bestimmen...
    Erg # Mat_Data:Read(Sta.Lfs.Materialnr);
    if (Erg < 200) then CYCLE;
    vGew # 0.0;
    if (Sta.MEH.VK='kg') then
      vGew # Sta.Menge.VK;

    RekLink(555,200,32,0);    // EKK Lesen
    

debug('-------------------------------------------------------------------');
debug('KEY200');

if  (Mat.Nummer = 2155674) then
  debug('xxx');


    Erg # RecLink(818,200,10,_RecFirst);    // Verwieungsart holen

    vLFGutschrPerT    # 0.0;
    vFremdLohnKosten # 0.0;
    vX # CalcSchrottGewAnteil(Mat.Nummer, var vLFGutschrPerT, var vFremdLohnKosten, 0.0, VWA.NettoYN=false,var vLfGutschMatDict, var vFremdLohnKostenDict);


    if (vX < 0.0) or ((vX/Mat.Bestand.Gew*100.0)>cMaxSchrottProz) then
      gErrMark # 'ACHTUNG!';

debug('KEY200 = Schrott: '+anum(vX,2)+' kg +  Bestand.Gew: ' +anum(Mat.Bestand.Gew,2) + ' kg');

    gMatEkGew     # gMatEkGew + vX + Mat.Bestand.Gew;

    // 20.05.2020 AH
    //vMatEK  # Sta.Betrag.EK;

    // Lieferantenguitschriften
    vLFGutschrPerT  # 0.0;
    if (vLfGutschMatDict> 0) then begin
      debug('GUTSCHS:');
      FOR   vItem # CteRead(vLfGutschMatDict,_CteFirst);
      LOOP  vItem # CteRead(vLfGutschMatDict,_CteNext,vItem);
      WHILE vItem <> 0 DO BEGIN
        debug('aName   # vItem->spName=' + vItem->spName + '    ' + 'aInhalt # vItem->spCustom=' + vItem->spCustom);
        vLFGutschrPerT  # vLFGutschrPerT + CnvFa(vItem->spCustom);
      END;
    end;

    /*
    vFremdLohnKosten  # 0.0;
    if (vFremdLohnKostenDict> 0) then begin
      debug('FLK:');
      FOR   vItem # CteRead(vFremdLohnKostenDict,_CteFirst);
      LOOP  vItem # CteRead(vFremdLohnKostenDict,_CteNext,vItem);
      WHILE vItem <> 0 DO BEGIN
        debug('aName   # vItem->spName=' + vItem->spName + '    ' + 'aInhalt # vItem->spCustom=' + vItem->spCustom);
        vFremdLohnKosten  # vFremdLohnKosten + CnvFa(vItem->spCustom);
      END;
    end;
    */
    // weil die Lohnkosten keine Internen Kosten sind!
    Sta.Lohnkosten # vFremdLohnKosten;
//    Sta.Lohnkosten # (gMatEkGew / 1000.0) * vFremdLohnKosten;
//debug('KEY200 = FremdLohnkosten: '+anum(vFremdLohnKosten,2)+' EUR/t +  für : ' +anum(gMatEkGew,2) + ' kg = ' + ANum(Sta.Lohnkosten,2));

debug('KEY200 = EK Preis : '+anum(Mat.EK.Preis,2)+' EUR/t +  Gutsch : ' +anum(vLFGutschrPerT,2) + ' EUR/t');
    // ST 2021-06-17: Gutschriftskosten auf Einsatzmaterial beachten
    Mat.EK.Preis # Mat.EK.Preis + vLFGutschrPerT;

    vMatEK # (Mat.EK.Preis * (vX + Mat.Bestand.Gew) / 1000.0);
debug('KEY200 = EK Wert : '+anum(vMatEK ,2)+' EUR');


    vMatEff # vMatEK + Sta.Lohnkosten;
  debug('KEY200 = MatEff = '+anum(vMatEK ,2)+' EUR + ' + ANum(Sta.Lohnkosten,2)+ ' = ' + Anum(vMatEff,2));


    gMatEkGpWert  # gMatEkGpWert + vMatEK;
    gMatEkeffWert # gMatEkeffWert + vMatEff;

    gErlGew       # gErlGew + vGew;
    gErlWert      # gErlWert + (Sta.Betrag.VK + Sta.Aufpreis.VK);
    RecBufCopy(899, vBuf);

    inc(vI);
  END;  // Statistik

  if (vBuf<>0) then RecBufDestroy(vBuf);

  SelClose(vSel);
  SelDelete(899, vSelName);
  vSel # 0;

  LF_Print(g_Gesamt);

  // Übergabe an Result
  gMatEkGew # GetSum(cSum_MatEkGew);
debugx('>>>>>>>>>>>>'+anum(gMatEKgew,0));
  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();


  Lib_Dict:Clear(var vLfGutschMatDict);


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
