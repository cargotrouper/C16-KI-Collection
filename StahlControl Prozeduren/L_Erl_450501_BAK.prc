@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450501
//
//  Info        Roherträge für Brockhaus
//
//
//
//  17.10.2018  ST  Erstellung der Prozedur
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

define begin
  cPrintAuftragYN      : GV.Logic.10
  cPrintKundenSummeYN  : GV.Logic.11
  cPrintWgrSummeYN     : GV.Logic.12
    
  cSum_Gew_Gesamt     :  1
  cSum_Gew_Kunde      :  2
  cSum_Gew_Warengr    :  3
  
  cSum_Preis_Gesamt   :  4
  cSum_Preis_Kunde    :  5
  cSum_Preis_Warengr  :  6

  cSum_RohGes_Gesamt  :  7
  cSum_RohGes_Kunde   :  8
  cSum_RohGes_Warengr :  9

  cSum_DB2_Gesamt     :  10
  cSum_DB2_Kunde      :  11
  cSum_DB2_Warengr    :  12
  
  cSum_Fix_Gesamt     :  13
end;

local begin
  g_Empty             : int; // Handles für die Zeilenelemente
  g_Sel1              : int;
  g_Header1           : int;
  g_Header2           : int;
  
  g_Auftrag           : int;
  g_Material          : int;
  g_SumKunde          : int;
  g_SumWgr            : int;
  g_FixHeader         : int;
  g_FixPos            : int;
  g_FixSum            : int;
  g_Gesamt            : int;

  g_Leselinie         : logic;
 
  gvFrachtKosten    : float;
  // gvProdKosten      : float;
   
  gCteMats      : int;
  gvProdKette   : alpha;
  gvProdKostMat : float;
  
  
  // Auftragspositionsdaten
  gvRohTOhneFracht   : float;
  gvRohTMitFracht    : float;
  gvRohGesamt        : float;
  gvProdKosten       : float;
  gvDB2              : float;
  gvDB2t             : float;

  // Summenübertrag
  gvLastWgr : int;
  gvLastKnd : alpha;
  
  
  // Fixkosten
  gvFixPos  : float;
  gvLastFix : alpha;
  
end;



//========================================================================
//  sub getProdkost(aKette : alpha; aGew : float);
//    Ermittelt die Produktionskosten pro Arbeitsgang und gibt die Kosten
//========================================================================
sub getProdkost(aKette : alpha(4000); aGew : float; aLohngeschaft : logic;) : float
local begin
  vI                : int;
  vBAGP             : alpha;
  vKostenProPos     : float;
  vEinsatzGewProPos : float;
  
  vMatKosten        : float;
end;
begin
  
  vI # 1;
  FOR   vBAGP # Str_Token(aKette,';',vI);
  LOOP  begin inc(vI); vBAGP # Str_Token(aKette,';',vI) end;
  WHILE vBAGP  <> '' DO BEGIN
    Bag.P.Nummer    # CnvIa(Str_Token(vBAGP,'/',1));
    Bag.P.Position  # CnvIa(Str_Token(vBAGP,'/',2));
    RecRead(702,1,0);
    
    // hier ggf. Zeiten-cache einbauen
    // Zeiten loopen
    FOR   Erg # RecLink(709,702,6,_RecFirst)
    LOOP  Erg # RecLink(709,702,6,_RecNext)
    WHILE Erg <= _rLocked DO BEGIN
      vKostenProPos # vKostenProPos + BAG.Z.GesamtkostenW1;
    END;
 
    if (aLohngeschaft = false) then begin

      // Hier ggf. Einsatzmengen-Cache einbauen
      // Einsatzgewicht ermitteln
      FOR   Erg # RecLink(701,702,2,_RecFirst)
      LOOP  Erg # RecLink(701,702,2,_RecNext)
      WHILE Erg <= _rLocked DO BEGIN
        if (BAG.FM.Materialnr <> 0) then
          vEinsatzGewProPos # vEinsatzGewProPos + BAG.IO.Ist.In.GewN;
      END;

      if (vEinsatzGewProPos <> 0.0) then
        vMatKosten # vMatKosten + ((aGew * vKostenProPos) / vEinsatzGewProPos);
    end else begin
      // Eigenes Lohngeschäft
      vMatKosten # vMatKosten + vKostenProPos;
    end;
  
  
  END;
  
  RETURN vMatKosten;
end;




//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  RecBufClear(999);

  List_FontSize           # 7;
  
  Sel.bis.Datum          # today;
  Sel.Fin.bis.Rechnung   # 9999999;
  Sel.Auf.Bis.Nummer     # 9999999;

  cPrintAuftragYN       # true;
  cPrintKundenSummeYN   # true;
  cPrintWgrSummeYN      # true;
 
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450501',here+':AusSel');
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
  vLine       : int;
  vObf        : alpha(120);
  vRohertrag  : float;
  vVK_EK      : float;
  vVM_VK_EK    : float;
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

      // Instanzieren...
      List_Spacing[ 1]  # 25.0; // Rechnung
      List_Spacing[ 2]  # 25.0; // Datum
      List_Spacing[ 3]  # 25.0; // Auftragnr
      List_Spacing[ 4]  # 25.0; // Auftragpos
      List_Spacing[ 5]  # 25.0; // Kunde
      List_Spacing[ 6]  # 25.0; // Warengruppe
      List_Spacing[ 7]  # 25.0; // Qualität
      List_Spacing[ 8]  # 25.0; // Dicke
      List_Spacing[ 9]  # 25.0; // Breite
      List_Spacing[10]  # 25.0; // Gewicht
      List_Spacing[11]  # 25.0; // Netto
      
      List_Spacing[12]  # 25.0; // Roh/t ohne Fracht
      List_Spacing[13]  # 25.0; // Roh/t mit Fracht
      List_Spacing[14]  # 25.0; // Fracht / t
      List_Spacing[15]  # 25.0; // Rohgesamt
      List_Spacing[16]  # 25.0; // Prodk./t
      List_Spacing[17]  # 25.0; // DB2 / t
      List_Spacing[18]  # 25.0; // DB2
      List_Spacing[19]  # 25.0; // Materialnr
      List_Spacing[20]  # 25.0; // BA Historie
      List_Spacing[21]  # 25.0; // FM Gew Brutto
      List_Spacing[22]  # 25.0; // FM Gew Netto
      List_Spacing[23]  # 25.0; // FM Kosten Mat
      List_Spacing[24]  # 25.0; // FM Kosten Gesamt
      List_Spacing[25]  #  0.1; // Ende
      Lib_List2:ConvertWidthsToSpacings( 26 ); // Spaltenbreiten konvertieren


      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set( 1, 'Rechnung'          ,y , 0);
      LF_Set( 2, 'Datum'             ,y , 0);
      LF_Set( 3, 'Auftragnr'         ,y , 0);
      LF_Set( 4, 'Auftragpos'        ,y , 0);
      LF_Set( 5, 'Kunde'             ,n , 0);
      LF_Set( 6, 'Warengruppe'       ,y , 0);
      LF_Set( 7, 'Qualität'          ,n , 0);
      LF_Set( 8, 'Dicke'             ,y , 0);
      LF_Set( 9, 'Breite'            ,y , 0);
      LF_Set(10, 'Gewicht'           ,y , 0);
      LF_Set(11, 'Netto'             ,y , 0);
      LF_Set(12, 'Roh/t ohne Fracht' ,y , 0);
      LF_Set(13, 'Roh/t mit Fracht'  ,y , 0);
      LF_Set(14, 'Fracht / t'        ,y , 0);
      LF_Set(15, 'Rohgesamt'         ,y , 0);
      LF_Set(16, 'Prodk./t'          ,y , 0);
      LF_Set(17, 'DB2 / t'           ,y , 0);
      LF_Set(18, 'DB2'               ,y , 0);
      LF_Set(19, 'Materialnr'        ,y , 0);
      LF_Set(20, 'BAG Historie'      ,n , 0);
      LF_Set(21, 'FM Gew Brutto'     ,y , 0);
      LF_Set(22, 'FM Gew Netto'      ,y , 0);
      LF_Set(23, 'FM Kosten Mat'     ,y , 0);
      LF_Set(24, 'FM Kosten Gesamt'  ,y , 0);
    end;



    'AUFTRAG' : begin
    
      if (aPrint) then begin
        Lf_Text(12,Anum(gvRohTOhneFracht ,2));
        Lf_Text(13,Anum(gvRohTMitFracht  ,2));
        Lf_Text(14,Anum(gvFrachtKosten  ,2));
        Lf_Text(15,Anum(gvRohGesamt      ,2));
        Lf_Text(16,Anum(gvProdKosten     ,2));
        Lf_Text(17,Anum(gvDB2t           ,2));
        Lf_Text(18,Anum(gvDB2            ,2));
        RETURN;
      end;
        

      LF_Set( 1, '@Erl.K.Rechnungsnr'   ,y , _LF_IntNG);
      LF_Set( 2, '@Erl.K.Rechnungsdatum',y , _LF_Date);
      LF_Set( 3, '@Erl.K.Auftragsnr'    ,y , _LF_IntNG);
      LF_Set( 4, '@Erl.K.Auftragspos'   ,y , _LF_IntNG);
      LF_Set( 5, '@Erl.KundenStichwort' ,n , 0);
      LF_Set( 6, '@Erl.K.Warengruppe'   ,y , _LF_IntNG);
      LF_Set( 7, '@Erl.K.Güte'          ,n , 0);
      LF_Set( 8, '@Auf.P.Dicke'         ,y , _LF_Num3, Set.Stellen.Dicke);
      LF_Set( 9, '@Auf.P.Breite'        ,y , _LF_Num3, Set.Stellen.Breite);
      LF_Set(10, '@Erl.K.Gewicht'       ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '@Erl.K.BetragW1'      ,y , _LF_Wae);
      
      
      
      
      LF_Set(12, '#Roh/t ohne Fracht'   ,y , _LF_Wae);  // cPosRohTOhneFracht # Ums.A.Einzelpreis - vEK - vFracht;
      LF_Set(13, '#Roh/t mit Fracht'    ,y , _LF_Wae);  // cPosRohTMitFracht # Ums.A.Einzelpreis - vEK;
      LF_Set(14, '#Fracht/t'            ,y , _LF_Wae);  // alt: vFracht auf Vorkalkulation / neu: EchteFrachtkosten
      LF_Set(15, '#Rohgesamt'           ,y , _LF_Wae);  // cPosRohGesamt # cPosRohTOhneFracht * (Ums.A.Gewicht.Brutto / 1000);
      LF_Set(16, '#Prodk./t'            ,y , _LF_Wae);  // vRechPrdKostGes
      LF_Set(17, '#DB2 / t'             ,y , _LF_Wae);  // cPosDB2T  #  Fix(cPosDB2 / (Ums.A.Gewicht.Brutto / 1000),2);
      LF_Set(18, '#DB2'                 ,y , _LF_Wae);  // cPosDB2  # cPosRohGesamt - vRechPrdKostGes;
    end;

    'MATERIAL' : begin
      if (cPrintAuftragYN = false) then
        RETURN;
      
      if (aPrint) then begin
        Lf_Text(20,gvProdKette);
        Lf_Text(23,ANum(gvProdKostMat,2));
        Lf_Text(24,ANum(gvProdKosten,2));
        RETURN;
      end;
      
      // Druck im Auftragsbereich
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '' ,n , 0);
      LF_Set( 6, '' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '' ,y , 0);
      LF_Set(11, '' ,y , 0);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '' ,y , 0);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '' ,y , 0);
      
      LF_Set(19, '@Mat.Nummer'          ,y , _LF_IntNG);
      LF_Set(20, '#BagPositionen'       ,n , 0);
      LF_Set(21, '@BAG.FM.Gewicht.Brutt',y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(22, '@BAG.FM.Gewicht.Netto',y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(23, '#FmKostenMat'         ,y , 0);
      LF_Set(24, '#FmKostenGesamt'      ,y , 0);
    end;


    'SUM_KUNDE' : begin
      if (aPrint) then begin
        Lf_Text(5, gvLastKnd);
        LF_Sum(10, cSum_Gew_Kunde, Set.Stellen.Gewicht);
        LF_Sum(11, cSum_Preis_Kunde , 2);
        LF_Sum(15, cSum_RohGes_Kunde , 2);
        LF_Sum(18, cSum_DB2_Kunde, 2);
        RETURN;
      end;
                
      // Instanzieren...
      if (cPrintAuftragYN) then
        LF_Format(_LF_OverLine + _LF_Bold);
        
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '#Kunde'      ,n,0);
      LF_Set( 6, '' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '#Gewicht'    ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '#NettoW1'    ,y , _LF_Wae);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '#RohGesamt'  ,y , _LF_Wae);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '#DB2'        ,y , _LF_Wae);
    end;
    

    'SUM_WGR' : begin
      if (aPrint) then begin
        Lf_Text(6, Aint(gvLastWgr));
        LF_Sum(10, cSum_Gew_Warengr, Set.Stellen.Gewicht);
        LF_Sum(11, cSum_Preis_Warengr , 2);
        LF_Sum(15, cSum_RohGes_Warengr , 2);
        LF_Sum(18, cSum_DB2_Warengr, 2);
        RETURN;
      end;
                
      // Instanzieren...
      if (cPrintAuftragYN) then
        LF_Format(_LF_OverLine + _LF_Bold);

      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '' ,n , 0);
      LF_Set( 6, '#Wgr'        ,y, _LF_IntNG);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '#Gewicht'    ,y, _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '#NettoW1'    ,y, _LF_Wae);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '#RohGesamt'  ,y, _LF_Wae);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '#DB2'        ,y, _LF_Wae);
    end;
    
    'FIX_HEADER' : begin
      if (aPrint) then begin
        Lf_Text(5, 'Erlösschmälerungen');
        Lf_Text(6, 'Betrag');
        RETURN;
      end;
                
      // Instanzieren...
      LF_Format(_LF_Underline + _LF_Bold);
        
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '#Kunde'  ,n,0);
      LF_Set( 6, '#Betrag' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '' ,y , 0);
      LF_Set(11, '' ,y , 0);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '' ,y , 0);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '' ,y , 0);
    end;
        

    'FIX_POS' : begin
      if (aPrint) then begin
        Lf_Text(5, gvLastFix);
        Lf_Text(6, Anum(gvFixPos,2));
        RETURN;
      end;
                
      // Instanzieren...
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '#Bez'   ,n,0);
      LF_Set( 6, '#Betrag' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '' ,y , 0);
      LF_Set(11, '' ,y , 0);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '' ,y , 0);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '' ,y , 0);
    end;

    'FIX_SUM' : begin
      if (aPrint) then begin
        Lf_Text(5, 'Korrektur gesamt');
        Lf_Sum( 6, cSum_Fix_Gesamt,2   );
        Lf_Text(18, ANum(GetSum(cSum_DB2_Gesamt) - GetSum(cSum_Fix_Gesamt),2)) ;
        RETURN;
      end;
                
      LF_Format(_LF_OverLine + _LF_Bold);
                
      // Instanzieren...
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '#Bez'   ,n,0);
      LF_Set( 6, '#Betrag' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '' ,y , 0);
      LF_Set(11, '' ,y , 0);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '' ,y , 0);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '' ,y , _LF_Wae);
    end;
    

    'SUM_GESAMT' : begin
      if (aPrint) then begin
        LF_Sum(10, cSum_Gew_Gesamt, Set.Stellen.Gewicht);
        LF_Sum(11, cSum_Preis_Gesamt, 2);
        LF_Sum(15, cSum_RohGes_Gesamt, 2);
        LF_Sum(18, cSum_DB2_Gesamt, 2);
        RETURN;
      end;
                
      // Instanzieren...
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set( 1, '' ,y , 0);
      LF_Set( 2, '' ,y , _LF_Date);
      LF_Set( 3, '' ,y , 0);
      LF_Set( 4, '' ,y , 0);
      LF_Set( 5, '' ,n , 0);
      LF_Set( 6, '' ,y , 0);
      LF_Set( 7, '' ,n , 0);
      LF_Set( 8, '' ,y , 0);
      LF_Set( 9, '' ,y , 0);
      LF_Set(10, '#Gewicht'            ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11, '#NettoW1'            ,y , _LF_Wae);
      LF_Set(12, '' ,y , 0);
      LF_Set(13, '' ,y , 0);
      LF_Set(14, '' ,y , 0);
      LF_Set(15, '#RohGesamt'          ,y , _LF_Wae);
      LF_Set(16, '' ,y , 0);
      LF_Set(17, '' ,y , 0);
      LF_Set(18, '#DB2'                ,y , _LF_Wae);
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
  LF_Print(g_Header2);
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
  vSel          : int;
  vFlag         : int;        // Datensatzlese option
  vSelName      : alpha;
  vItem         : int;
  vKey          : int;
  vMFile,vMID   : int;
  vOK           : logic;
  vTree         : int;
  vSortKey      : alpha;
  vQ450         : alpha(4000);
  vQ451         : alpha(4000);
  vProgress     : handle;

  v200  : int;
  v204  : int;
  
  vProdKette    : alpha(4000);
  vProdKostMat  : float;
  vTmp : alpha(4000);
    
  vNode : int;
  vI    : int;
  
  vCheckDate : date;
  
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vQ451  # '';
  Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Rechnungsnr',    Sel.Fin.von.Rechnung ,  Sel.Fin.bis.Rechnung);
  Lib_Sel:QVonBisD(var vQ451, 'Erl.K.Rechnungsdatum', Sel.von.Datum ,         Sel.bis.Datum);
  Lib_Sel:QVonBisI(var vQ451, 'Erl.K.Auftragsnr',     Sel.Auf.von.Nummer ,    Sel.Auf.bis.Nummer);
  if (Sel.Adr.von.KdNr <> 0) then
    Lib_Sel:QInt(var vQ451, 'Erl.K.Kundennummer',     '=' ,    Sel.Adr.von.KdNr);
  if (Sel.Adr.von.Vertret <> 0) then begin
    vQ450  # '';
    Lib_Sel:QInt(var vQ450, 'Erl.Vertreter',     '=' ,    Sel.Adr.von.Vertret);
    vQ451   #  vQ451 + ' AND LinkCount(Erl) > 0';
  end;
      
  // Hauptsel
  vSel # SelCreate(451, 1);
  vSel->SelAddLink('', 450, 451, 1, 'Erl');
        
  Erg # vSel->SelDefQuery('', vQ451);
  if (Erg<>0) then Lib_Sel:QError(vSel);

  // SubSels
  Erg # vSel->SelDefQuery('Erl', vQ450);
  if (Erg<>0) then Lib_Sel:QError(vSel);
   
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init('Sortierung', RecInfo(451, _recCount, vSel));
  FOR   Erg # RecRead(451, vSel, _recFirst);
  LOOP  Erg # RecRead(451, vSel, _recNext);
  WHILE (Erg <= _rLocked) DO BEGIN
    if (!vProgress->Lib_Progress:Step()) then begin     // Progress
      SelClose(vSel);
      SelDelete(451, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    
    RekLink(100,451,6,0);   // Kunde lesen

    vSortKey #  Lib_Strings:IntForSort(Erl.K.Warengruppe) +
                StrFmt(Adr.Stichwort,20,_StrEnd)  +
                Lib_Strings:IntForSort(Erl.K.Rechnungsnr) +
                Lib_Strings:IntForSort(Erl.K.Auftragsnr) +
                Lib_Strings:IntForSort(Erl.K.Auftragspos);
                
    Sort_ItemAdd(vTree, vSortKey, 451, RecInfo(451,_RecId));
  END;
  SelClose(vSel);
  SelDelete(451, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Header1   # LF_NewLine('HEADER1');
  g_Header2   # LF_NewLine('HEADER2');

  g_Auftrag   # LF_NewLine('AUFTRAG');
  g_Material  # LF_NewLine('MATERIAL');
  g_SumKunde  # LF_NewLine('SUM_KUNDE');
  g_SumWgr    # LF_NewLine('SUM_WGR');
  g_FixHeader # LF_NewLine('FIX_HEADER');
  g_FixPos    # LF_NewLine('FIX_POS');
  g_FixSum    # LF_NewLine('FIX_SUM');
  g_Gesamt    # LF_NewLine('SUM_GESAMT');
  
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape

  FOR   vItem # Sort_ItemFirst(vTree) // RAMBAUM
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    if ( !vProgress->Lib_Progress:Step() ) then begin // Progress
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);

    // -----------------------------------------------------
    // Kunden Oder WGR Wechsel, Summendruck
    // -----------------------------------------------------
    RekLink(450,451,1,0);    // Erlös lesen
    if (gvLastKnd  <> Erl.KundenStichwort) AND (gvLastKnd <> '') then begin
      if (cPrintKundenSummeYN) then begin
        LF_Print(g_SumKunde);
        if (cPrintAuftragYN) then
          LF_Print(g_Empty);
      end;
      
      ResetSum(cSum_Gew_Kunde);
      ResetSum(cSum_Preis_Kunde);
      ResetSum(cSum_RohGes_Kunde);
      ResetSum(cSum_DB2_Kunde);
    end;

    
    if (gvLastWgr <> Erl.K.Warengruppe) AND (gvLastWgr <> 0) then begin
      if (cPrintWgrSummeYN) then begin
        LF_Print(g_SumWgr);
        if (cPrintAuftragYN) then
          LF_Print(g_Empty);
      end;
      
      ResetSum(cSum_Gew_Warengr);
      ResetSum(cSum_Preis_Warengr);
      ResetSum(cSum_RohGes_Warengr);
      ResetSum(cSum_DB2_Warengr);
    end;
    

    // -----------------------------------------------------
    // Auftragsdruck
    // -----------------------------------------------------
    RekLink(450,451,1,0);    // Erlös lesen
    Auf_Data:Read(Erl.K.Auftragsnr, Erl.K.Auftragspos, true);
    RekLink(835,451,5,0); // Auftragsart lesen

    gCteMats # CteOpen(_CteNode);
    
    gvFrachtKosten  # 0.0;
    gvProdKosten    # 0.0;
    gvProdKostMat   # 0.0;
    
    // Materialien ermitteln
    FOR   Erg # RecLink(404,451,7,_RecFirst)
    LOOP  Erg # RecLink(404,451,7,_RecNext)
    WHILE Erg = _rOK DO BEGIN
    
      if (Auf.A.MaterialNr = 0) then
        CYCLE;
        
      Erg # Mat_Data:Read(Auf.A.MaterialNr);
      if (Erg < 200) then
        CYCLE;


      // ------------------------------------------------
      // direkte Frachtkosten aus Material ermitteln
      // ------------------------------------------------
      FOR     Erg # RekLink(204,200,14,_RecFirst)
      LOOP    Erg # RekLink(204,200,14,_RecNext)
      WHILE Erg <= _rLocked DO BEGIN
        if (Mat.A.Aktionstyp <> c_Akt_Aufpreis) then
          CYCLE;
      

        gvFrachtKosten # gvFrachtKosten + (Mat.Bestand.Gew/1000.0 * Mat.A.Kosten2W1);

      END;
    
      // ------------------------------------------------
      // Produktionskosten aus BAG Ermitteln
      // ------------------------------------------------
      if (Mat.Nummer = 5296) then
        debug('');

      
      vProdKette # '';
      RekLink(707,200,28,0);    // FM gelesen
     
      //getProdkette(Mat.Nummer, var vProdKette);
      SFX_BSP_MAt:LiesProdKette(Mat.Nummer, var vProdKette);
      
      // Gesamtkosten der Prodkette ermitteln
      vProdKostMat # getProdkost(vProdKette,Mat.Bestand.Gew, (AAr.Berechnungsart >= 700));
      gvProdKosten # gvProdKosten  + vProdKostMat;
      
      vTmp  # vProdKette + '|' + Anum(vProdKostMat,2);
      gCteMats->CteInsertNode(Aint(Mat.Nummer),Mat.Nummer,vtmp);
   
    END;
         
    // ----------------------------------------------
    // Wertermittlung und Summierung
    // ----------------------------------------------
    gvRohTOhneFracht  # 0.0;
    gvRohTMitFracht   # 0.0;
    gvRohGesamt       # 0.0;
    //gvProdKosten      # 0.0;
    gvDB2             # 0.0;
    gvDB2t            # 0.0;
    if (Erl.K.Gewicht <> 0.0) then begin
      
      //gvRohTOhneFracht # (Erl.K.BetragW1 - Erl.K.EKPreisSummeW1) / (Erl.K.Gewicht/1000.0);
      //gvRohTMitFracht  # (Erl.K.BetragW1 - Erl.K.EKPreisSummeW1 + gvFrachtKosten) / (Erl.K.Gewicht/1000.0);
      gvRohTMitFracht  # (Erl.K.BetragW1 + Erl.K.EKPreisSummeW1 - gvFrachtKosten) / (Erl.K.Gewicht/1000.0);
      
      gvRohGesamt      # gvRohTOhneFracht * (Erl.K.Gewicht / 1000.0);
      gvProdKosten     # gvProdKosten / (Erl.K.Gewicht/1000.0);
      gvDB2            # gvRohGesamt - gvProdKosten;
      gvDB2t           # Rnd(gvDB2 / (Erl.K.Gewicht / 1000.0),2);
    end;
        
    AddSum(cSum_Gew_Gesamt     , Erl.K.Gewicht);
    AddSum(cSum_Gew_Kunde      , Erl.K.Gewicht);
    AddSum(cSum_Gew_Warengr    , Erl.K.Gewicht);
    AddSum(cSum_Preis_Gesamt   , Erl.K.BetragW1 );
    AddSum(cSum_Preis_Kunde    , Erl.K.BetragW1);
    AddSum(cSum_Preis_Warengr  , Erl.K.BetragW1);
    AddSum(cSum_RohGes_Gesamt  , gvRohGesamt);
    AddSum(cSum_RohGes_Kunde   , gvRohGesamt);
    AddSum(cSum_RohGes_Warengr , gvRohGesamt);
    AddSum(cSum_DB2_Gesamt     , gvDB2);
    AddSum(cSum_DB2_Kunde      , gvDB2);
    AddSum(cSum_DB2_Warengr    , gvDB2);
    
    // AUSGABE
    if (cPrintAuftragYN) then begin
      LF_Print(g_Auftrag);
    
      FOR   vNode # gCteMats->CteRead(_CteFirst)
      LOOP  vNode # gCteMats->CteRead(_CteNext,vNode)
      WHILE vNode <> 0 DO BEGIN
      
        Mat.Nummer   # vNode->spID;
        gvProdKette   # Str_Token(vNode->spValueAlpha,'|',1);
        gvProdKostMat # CnvFa(Str_Token(vNode->spValueAlpha,'|',2));
       
        LF_Print(g_Material);
      END;
             
    end;
    CteClose(gCteMats);
 
    gvLastWgr # Erl.K.Warengruppe;
    gvLastKnd # Erl.KundenStichwort;
  END;

  if (cPrintKundenSummeYN) then begin
    LF_Print(g_SumKunde);
    if (cPrintAuftragYN) then
      LF_Print(g_Empty);
  end;

  if (cPrintWgrSummeYN) then begin
    LF_Print(g_SumWgr);
    if (cPrintAuftragYN) then
      LF_Print(g_Empty);
  end;
 
  
  LF_Print(g_Gesamt);

  LF_Print(g_Empty);
  LF_Print(g_Empty);
  
  LF_Print(g_FixHeader);

  // Erlösschmälerungen ausgeben
  gvLastFix  # '';
  FOR   Erg # RecRead(558,1,_RecFirst)
  LOOP  Erg # RecRead(558,1,_RecNext)
  WHILE Erg = _rOK DO BEGIN
    if (StrCnv(FxK.Text1,_StrUpper) <> 'DB1LISTE') then
      CYCLE;
          
    if (gvLastFix  <> '') AND (gvLastFix <> FxK.Text2) then begin
      LF_Print(g_FixPos);
      gvFixPos # 0.0;
    end;

          
    // Monatsangaben summieren
    gvFixPos # 0.0;
    FOR   vI # 1
    LOOP  inc(vI)
    WHILE (vI <= 12) DO BEGIN
      if (FxK.Zahltag = 0) then
        FxK.Zahltag # 15;
    
      vCheckDate # DateMake(FxK.Zahltag,vI,FxK.Jahr);
      if (vCheckDate >= Sel.von.Datum) AND (vCheckDate <= Sel.bis.Datum) then
        gvFixPos # gvFixPos  + FldFloat(558,1,vI+5);
    
    END;
    AddSum(cSum_Fix_Gesamt,gvFixPos);

    gvLastFix # FxK.Text2;
  END;
  LF_Print(g_FixPos);
  LF_Print(g_FixSum);



  Sort_KillList(vTree); // Löschen der Liste
  
  vProgress->Lib_Progress:Term(); // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header1);
  LF_FreeLine(g_Header2);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Auftrag);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_SumKunde);
  LF_FreeLine(g_SumWgr);
  LF_FreeLine(g_FixHeader);
  LF_FreeLine(g_FixPos);
  LF_FreeLine(g_FixSum);
  LF_FreeLine(g_Gesamt);
end;

//========================================================================
