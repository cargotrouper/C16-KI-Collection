@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450022
//                    OHNE E_R_G
//  Info        Material In-Out
//
//
//
//  16.05.2013  AI  Erstellung der Prozedur
//  19.11.2014  AH  Rückrechnnen vom Bestsandsbuch über zentrale Funktion
//  13.06.2022  AH  ERX
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

declare StartList(aSort : int; aSortName : alpha);

// Handles für die Zeilenelemente
local begin
  g_Empty       : handle;
  g_Sel1        : handle;
  g_OutputHeader : handle;
  g_InputHeader : handle;
  g_Input       : handle;
  g_Output      : handle;
  g_Summe       : handle;
  g_Leselinie   : logic;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort       : int;
  vSortName   : alpha;
end
begin

  RecBufClear(998);
  Sel.Mat.von.MatNr   # 0;//3109;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450022',here+':AusSel');
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
  if (Sel.Mat.von.MatNr=0) then RETURN;
  vSort     # 1;
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
  vA          : alpha(4000);
  vEK         : float;
  vVK         : float;
  vDB         : float;
  vVKGew      : float;
  vSchrottGew : float;
  vLagerGew   : float;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'SEL1' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #   30.0;
      List_Spacing[ 2]  #   30.0;
      List_Spacing[ 3]  #   10.0;
      Lib_List2:ConvertWidthsToSpacings( 3 ); // Spaltenbreiten konvertieren

      LF_Set(1, 'Material:'               ,n , 0);
      LF_Set(2,  ZahlI(Sel.Mat.von.MatNr) ,n , _LF_INT);
    end;


    'INPUTHEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  # 15.0; // MatNr
      List_Spacing[ 2]  # 30.0; // Güte
      List_Spacing[ 3]  # 40.0; // Abmessung
      List_Spacing[ 4]  # 20.0; // Eingangsdatum
      List_Spacing[ 5]  # 35.0; // Lieferant
      List_Spacing[ 6]  # 20.0; // Eing.ReNr
      List_Spacing[ 7]  # 30.0; // LF-Eing.ReNr
      List_Spacing[ 8]  # 25.0; // WE Gewicht
      List_Spacing[ 9]  # 17.0; // EK/t
      List_Spacing[10]  # 25.0; // EK gesamt
      List_Spacing[11]  # 20.0;
      Lib_List2:ConvertWidthsToSpacings( 11 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);

      LF_Set(1, 'Input Mat.Nr.' ,y , 0);
      LF_Set(2, 'Güte'          ,n , 0);
      LF_Set(3, 'Abmessung'     ,n , 0);
      LF_Set(4, 'Eingang am'    ,n , 0);
      LF_Set(5, 'Lieferant'     ,n , 0);
      LF_Set(6, 'Eing.ReNr.'    ,y , 0);
      LF_Set(7, 'Lf-Eing.ReNr.' ,n , 0);
      LF_Set(8, 'WE Gew. kg'    ,y , 0);
      LF_Set(9, 'EK/t'          ,y , 0);
      LF_Set(10,'EK gesamt'     ,y , 0);
    end;


    'INPUT' : begin
      if (aPrint) then begin
        vA # anum(Mat.Dicke, Set.Stellen.Dicke);
        if (Mat.Breite<>0.0) and ("Mat.Länge"=0.0) then vA # vA + ' x '+anum(Mat.Breite, Set.Stellen.Breite)
        else
        if ("Mat.Länge"=0.0) then vA # vA + ' x '+anum(Mat.Breite, Set.Stellen.Breite) + ' x '+anum("Mat.Länge", "Set.Stellen.Länge");
        LF_Text(3, vA);
        LF_Text(10, anum(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0 , 2) );
        RETURN;
      end;
      LF_Set(1, '@Mat.Nummer'           ,y , _LF_Int);
      LF_Set(2, '@Mat.Güte'             ,n , 0);
      LF_Set(3, '#Abmessung'            ,n , 0);
      LF_Set(4, '@Mat.Eingangsdatum'    ,n , _LF_Date);
      LF_Set(5, '@Mat.LieferStichwort'  ,n , 0);
      LF_Set(6, '@Mat.EK.RechNr'        ,y , _LF_int);
      LF_Set(7, '@ERe.Rechnungsnr'      ,n , _LF_int);
      LF_Set(8, '@Mat.Bestand.Gew'      ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(9, '@Mat.EK.Preis'         ,y , _LF_Wae);
      LF_Set(10,'#EK gesamt'            ,y , _LF_Wae);
    end;


    'OUTPUTHEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  # 15.0; // MatNr
      List_Spacing[ 2]  # 20.0; // Kommi
      List_Spacing[ 3]  # 35.0; // Kunde
      List_Spacing[ 4]  # 20.0; // RechNr
      List_Spacing[ 5]  # 15.0; // Status
      List_Spacing[ 6]  # 22.0; // kg Lager
      List_Spacing[ 7]  # 22.0; // kg Verkauf
      List_Spacing[ 8]  # 22.0; // kg Schrott
      List_Spacing[ 9]  # 17.0; // eff.EK/t
      List_Spacing[10]  # 17.0; // VK/t
      List_Spacing[11]  # 25.0; // VK gesamt
      List_Spacing[12]  # 25.0; // EK Gesmat
      List_Spacing[13]  # 25.0; // DB Gesamt
      List_Spacing[14]  # 5.0;
      Lib_List2:ConvertWidthsToSpacings( 14 ); // Spaltenbreiten konvertieren

      LF_Format(_LF_UnderLine + _LF_Bold);

      LF_Set(1, 'Output Mat.Nr.'  ,y , 0);
      LF_Set(2, 'Kommis.'         ,n , 0);
      LF_Set(3, 'Kunde'           ,n , 0);
      LF_Set(4, 'VK ReNr.'        ,y , 0);
      LF_Set(5, 'Status'          ,y , 0);
      LF_Set(6, 'Lager kg'        ,y , 0);
      LF_Set(7, 'Verkauf kg'      ,y , 0);
      LF_Set(8, 'Schrott kg'      ,y , 0);
      LF_Set(9, 'eff.EK/t'        ,y , 0);
      LF_Set(10,'VK/t'            ,y , 0);
      LF_Set(11,'VK Gesamt'       ,y , 0);
      LF_Set(12,'eff.EK Ges.'     ,y , 0);
      LF_Set(13,'DB Gesamt'       ,y , 0);
    end;


    'OUTPUT' : begin
      if (aPrint) then begin
        vVK # Rnd(Mat.VK.Preis * Mat.Bestand.Gew / 1000.0, 2);
        vEK # Rnd(Mat.EK.Effektiv * Mat.Bestand.Gew / 1000.0,2);
        if ("Mat.Löschmarker"='*') then begin
          if (Mat.VK.Rechnr<>0) or (Mat.Status=c_Status_Verkauft) or (Mat.Status=c_Status_geliefert) then begin
            vVKGew # Mat.Bestand.Gew;
            vDB # vVK - vEK;
            end
          else begin
            vSchrottGew # Mat.Bestand.Gew;
            vDB # vVK - vEK;
          end;
          end
        else begin
          vLagerGew # Mat.Bestand.Gew;
        end;
        LF_Text(5, aint(Mat.Status)+"Mat.Löschmarker");
        LF_Text(6, Cnvaf(vLagerGew, 0,0,Set.Stellen.Gewicht));
        LF_Text(7, cnvaf(vVKGew, 0,0,Set.Stellen.Gewicht));
        LF_Text(8, cnvaf(vSchrottGew, 0,0,Set.Stellen.Gewicht));
        LF_Text(11, anum(vVK,2));
        LF_Text(12, anum(vEK,2));
        LF_Text(13, anum(vDB,2));
        AddSum(1, vLagerGew);
        AddSum(2, vVKGew);
        AddSum(3, vSchrottGew);
        AddSum(4, vVK);
        AddSum(5, vEK);
        AddSum(6, vDB);

        if(List_XML = false) then begin
          g_Leselinie # !(g_Leselinie);
          if (g_Leselinie) then
            Lib_PrintLine:Drawbox(0.0,440.0, RGB(230,230,230), 4.0)
          else
            Lib_PrintLine:Drawbox(0.0,440.0,_WinColWhite, 4.0)
        end;

        RETURN;

      end;

      // Instanzieren...
      LF_Set( 1,  '@Mat.Nummer'           ,y , _LF_IntNG);
      LF_Set( 2,  '@Mat.Kommission'       ,n , 0);
      LF_Set( 3,  '@Mat.KommKundenSWort'  ,n , 0);
      LF_Set( 4,  '@Mat.VK.Rechnr'        ,y , 0);
      LF_Set( 5,  '#Mat.Status'           ,y , 0);
      LF_Set( 6,  '#Lager'                ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set( 7,  '#Verkauf'              ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set( 8,  '#Schrott'              ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set( 9,  '@Mat.EK.effektiv'      ,y , _LF_Wae);
      LF_Set(10,  '@Mat.VK.Preis'         ,y , _LF_Wae);
      LF_Set(11,  '#VK'                   ,y , _LF_Wae);
      LF_Set(12,  '#EK'                   ,y , _LF_Wae);
      LF_Set(13,  '#DB'                   ,y , _LF_Wae);
    end;


    'SUMME' : begin
      if (aPrint) then begin
        LF_Sum(6 ,1, Set.Stellen.Gewicht);
        LF_Sum(7 ,2, Set.Stellen.Gewicht);
        LF_Sum(8 ,3, Set.Stellen.Gewicht);
        LF_SumNG(11,4, 2);
        LF_SumNG(12,5, 2);
        LF_SumNG(13,6, 2);
        RETURN;
      end;
      LF_Format(_LF_Overline);
      LF_Set(6, 'SUM1'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(7, 'SUM2'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(8, 'SUM3'                  ,y , _LF_Num, Set.Stellen.Gewicht);
      LF_Set(11,'SUM4'                  ,y , _LF_Wae);
      LF_Set(12,'SUM5'                  ,y , _LF_Wae);
      LF_Set(13,'SUM6'                  ,y , _LF_Wae);
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
    end
  else begin
    LF_Print(g_OutputHeader);
  end;

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
  vOK         : logic;
  vDatei      : int;
  v200        : int;
end;
begin
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Wareneingang suchen...
  RecBufClear(506);
  Ein.E.Materialnr  # Sel.Mat.von.MatNr;
  Erx # RecRead(506,2,0);
  if (Erx>_rLocked) then begin
//    RETURN;
  end;
  vDatei # Mat_Data:Read(Sel.Mat.Von.MatNr);
  if (vDatei<200) then begin
    RETURN;
  end;
  v200 # RekSave(200);


  // Ausgabe ----------------------------------------------------------------
//  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );
    // Progress
//    if ( !vProgress->Lib_Progress:Step() ) then begin
//      Sort_KillList(vTree);
//      vProgress->Lib_Progress:Term();
//      xxxRETURN; cleanup?
//    end;

  // Druckelemente generieren...
  g_Empty         # LF_NewLine('EMPTY');
  g_Sel1          # LF_NewLine('SEL1');
  g_InputHeader   # LF_NewLine('INPUTHEADER');
  g_Input         # LF_NewLine('INPUT');
  g_OutputHeader  # LF_NewLine('OUTPUTHEADER');
  g_Output        # LF_NewLine('OUTPUT');
  g_Summe         # LF_NewLine('SUMME');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  RecBufCopy(v200,200);
  Sel.Von.Datum # 1.1.2000;

  // 19.11.2014
  Mat_B_Data:BewegungenRueckrechnen(Sel.Von.Datum);
/***
  // Bestandsbuch mit einrechnen...
  FOR Erx # RecLink(202,200,12,_recFirst);
  LOOP Erx # RecLink(202,200,12,_recNext);
  WHILE (Erx<=_rLocked) do begin
    // alle Bewegungen NACH dem Stichtag rückrechnen...
    if (Mat.B.Datum>=Sel.von.Datum) then begin
      Mat.Bestand.Gew   # Mat.Bestand.Gew - Mat.B.Gewicht;
      Mat.Bestand.Stk   # Mat.Bestand.Stk - "Mat.B.Stückzahl";
      Mat.Bestand.Menge # Mat.Bestand.Menge - Mat.B.Menge;
    end;
    // alle Bewertungen INCL. des Stichtages rückrechnen...
    if (Mat.B.Datum>Sel.von.Datum) then begin
      Mat.EK.Preis          # Mat.EK.Preis - Mat.B.PreisW1;
      Mat.EK.Effektiv       # Mat.EK.Effektiv - Mat.B.PreisW1;
      Mat.EK.PreisProMEH    # Mat.EK.PreisProMEH - Mat.B.PreisW1ProMEH;
      Mat.EK.EffektivProME  # Mat.EK.EffektivProME - Mat.B.PreisW1ProMEH;
    end;
  END;
***/

  RecBufClear(560);
  Erx # RekLink(555,200,32,_recFirst);    // EKK holen
  if (Erx<=_rLocked) and (EKK.EingangsreNr<>0) then begin
    Erx # RekLink(560,555,1,_recFirst);   // ERE holen
  end;



  // Liste starten
  LF_Init(y);    // Landscape

  LF_Print(g_InputHeader);
  LF_Print(g_Input);

  LF_Print(g_Empty);

  LF_Print(g_OutputHeader);


  RecBufClear(200);
  Mat.Ursprung # v200->Mat.Ursprung;
  FOR Erx # RecRead(vDatei,2,0)
  LOOP Erx # RecRead(vDatei,2,_recNext)
  WHILE (Erx<=_rMultikey) do begin
    if (vDatei=210) then RecbufCopy(210,200);
    if (Mat.Ursprung<>v200->Mat.Ursprung) then BREAK;
    if (Mat.Nummer=v200->Mat.Nummer) then CYCLE;

    LF_Print(g_Output);
  END;

  LF_Print(g_Summe);

  // Liste beenden
  RekRestore(v200);
//  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_OutputHeader);
  LF_FreeLine(g_InputHeader);
  LF_FreeLine(g_Input);
  LF_FreeLine(g_Output);
  LF_FreeLine(g_Summe);
end;

//========================================================================/