@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_255001
//                    OHNE E_R_G
//  Info        Stückliste
//
//
//  16.07.2010  AI  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List2

declare StartList(aSort : int; aSortName : alpha);

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Alpha     : int;
  g_Header    : int;
  g_SL        : int;
  g_Linie     : int;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  Erx : int;
end;
begin
  Erx # Msg(99,'Wollen Sie die komplette Struktur ausgeben?',_WinIcoQuestion,_WinDialogYesNoCancel,1);
  if (Erx=_WinIdCancel) then RETURN;

  if (Erx=_WinIdYes) then
    StartList(1,'')
  else
    StartList(0,'');
end;


//========================================================================
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  Erx       : int;
  vLine     : int;
  vObf      : alpha(120);
  vPreis    : float;
  vPreisPEH : int;
end;
begin
  case aName of

    'EMPTY' : begin
     if (aPrint) then RETURN;
    end;


    'LINIE' : begin
      LF_Format(_LF_Overline);
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   220.0;
      LF_Set(1,  ''                  ,n , 0);
    end;


    'ALPHA' : begin

      if (aPrint) then begin
//        LF_Text(1,GV.alpha.01);
        RETURN;
      end;

      // Instanzieren...
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   220.0;
      LF_Set(1,  '@GV.Alpha.01'      ,n , 0);
    end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 20.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 70.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 12.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 12.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 30.0;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 50.0;
      List_Spacing[ 8]  # List_Spacing[ 7]  + 20.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  + 15.0;
      List_Spacing[10]  # List_Spacing[ 9]  + 15.0;
      List_Spacing[11]  # List_Spacing[ 10] + 15.0;
      List_Spacing[12]  # List_Spacing[ 11] + 15.0;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Stufe'                                  ,y , 0);
      LF_Set(2,  'Artikelnr'                              ,n , 0);
      LF_Set(3,  'Typ'                                    ,n , 0);
      LF_Set(4,  'Akt?'                                   ,n , 0);
      LF_Set(5,  'Ressource'                              ,n , 0);
      LF_Set(6,  'Arbeitsgang'                            ,n , 0);
      LF_Set(7,  'Menge'                                  ,y , 0);
      LF_Set(8,  'MEH'                                    ,n , 0);
      LF_Set(9,  'Preis '+"Set.Hauswährung.Kurz"          ,y , 0);
      LF_Set(10, 'PEH'                                    ,y , 0);
      LF_Set(11, 'MEH'                                    ,n , 0);
    end;


    'SL' : begin
      if (aPrint) then begin
        LF_Text(1, Gv.Alpha.01);
        GV.Alpha.10 # '';

        RecBufClear(160);
        // Artikel...
        if (Art.SL.Typ=250) then begin
          Erx # RecLink(250,256,2,_recFirst);   // InputArtikel holen
          if (Art_P_Data:LiesPreis('Ø-EK',0)) then vPreis # Art.P.PreisW1
          else if (Art_P_Data:LiesPreis('L-EK',0)) then vPreis # Art.P.PreisW1
          else if (Art_P_Data:LiesPreis('L-EK',-1)) then vPreis # Art.P.PreisW1
          else vPreis # 0.0;
          if (Art.P.PEH=0) then Art.P.PEH # 1;
          vPreisPEH # Art.P.PEH;

          if ("Art.SLRefreshNötigYN") then GV.ALPha.10 # 'N';

          end
        // Arbeitsgang...
        else if (Art.SL.Typ=828) then begin
          Erx # RecLink(828,256,4,_recFirst);   // Arbeitsgang holen
          vPreis    # Art.SL.Kosten.FixW1;
          vPreisPEH # 0;
          if (Art.SL.Kosten.VarW1<>0.0) then begin
            vPreis    # Art.SL.Kosten.VarW1;
            vPreisPEH # Art.SL.Kosten.PEH;
          end;
          Art.SL.Bemerkung # ArG.Bezeichnung;

          end
        // Ressource...
        else if (Art.SL.Typ=160) then begin
          Erx # RecLink(160,256,3,_recFirst);   // Ressource holen
          vPreis  # 0.0;
          vPreis    # Art.SL.Kosten.FixW1;
          vPreisPEH # 0;
          if (Art.SL.Kosten.VarW1<>0.0) then begin
            vPreis    # Art.SL.Kosten.VarW1;
            vPreisPEH # Art.SL.Kosten.PEH;
          end;
          end
        // Text...
        else begin
        end;

        Art.SL.Kosten.FixW1 # vPreis;
        Art.SL.KOsten.PEH   # vPreisPEH;

        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  '#Stufe'               ,n , 0);
      LF_Set(2,  '@Art.SL.Input.ArtNr'  ,n , 0);
      LF_Set(3,  '@Art.Typ'             ,n , 0);
      LF_Set(4,  '@Gv.Alpha.10'         ,n , 0);
      LF_Set(5,  '@Rso.Stichwort'       ,n , 0);
      LF_Set(6,  '@Art.SL.Bemerkung'    ,n , 0);
      LF_Set(7,  '@Art.SL.Menge'        ,y , _LF_Num3);
      LF_Set(8,  '@Art.SL.MEH'          ,n , 0);
      LF_Set(9,  '@Art.SL.Kosten.FixW1' ,y , _LF_WAE);
      LF_Set(10, '@Art.SL.Kosten.PEH'   ,y , 0);
      LF_Set(11, '@Art.SL.Kosten.MEH'   ,y , 0);
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
    GV.alpha.01 # 'zu Artikel : '+Art.SLK.Artikelnr;
    LF_Print(g_Alpha);
    GV.alpha.01 # 'Stückliste : '+aint(Art.SLK.nummer);
    LF_Print(g_Alpha);
    GV.alpha.01 # 'Name : '+Art.SLK.Name;
    LF_Print(g_Alpha);
    GV.alpha.01 # 'Info : '+Art.SLK.Bemerkung;
    LF_Print(g_Alpha);

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
//  Print_REK
//
//========================================================================
sub Print_REK(
  aLevel  : alpha;
  aRek    : logic;
  aMenge  : float);
local begin
  Erx     : int;
  vBuf250 : int;
  vBuf255 : int;
  vBuf256 : int;
  vC      : int;
end;
begin

  vC # 1;

  Erx # RecLink(256,255,2,_recFirst);
  WHILE (Erx<=_rLocked) do begin

    Gv.alpha.01 # aLevel;
    if (aLevel<>'') then
      Gv.Alpha.01 # aLevel + '.';

    Gv.Alpha.01 # gv.alpha.01 + aint(vC);//aint(Art.SL.BlockNr)+'/'+aint(Art.SL.lfdnr)
    inc(vC);

    vBuf250 # RekSave(250);
    Art.SL.Menge # ARt.SL.Menge * aMenge;
    LF_Print(g_SL);
    RekRestore(vBuf250);

    // weiterer Artikel?
    if (Art.SL.Typ=250) and (aRek) then begin
      vBuf250 # RekSave(250);
      Erx # RecLink(250,256,2,_recFirst);       // InputArtikel holen
      if (Erx<=_rLocked) and ("Art.Stückliste"<>0) then begin
        vBuf255 # RekSave(255);
        vBuf256 # RekSave(256);
        Erx # RecLink(255,250,22,_RecFirst);    // aktive Stückliste holen
        if (Erx<=_rLocked) then begin
          Print_REK(Gv.Alpha.01, y, Art.SL.MEnge);
        end;
        RekRestore(vBuf255);
        RekRestore(vBuf256);
      enD;
      RekRestore(vBuf250);
    end;

    Erx # RecLink(256,255,2,_recNext);
  END;

end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vProgress : int;
end;
begin

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', RecLinkInfo(256,255,2,_recCount));

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Alpha     # LF_NewLine('ALPHA');
  g_Header    # LF_NewLine('HEADER');
  g_SL        # LF_NewLine('SL');
  g_Linie     # LF_NewLine('LINIE');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  Print_REK('',aSort=1, 1.0);

  LF_Print(g_Linie);
  GV.Alpha.01 # 'Fertigungsdauer : '+anum(Art.SLK.Fert.Dauer,0)+' min.';
  LF_Print(g_alpha);
  Gv.ALpha.01 # 'Fertigungskosten : '+anum(Art.SLK.Fert.KostW1,2)+' '+"set.Hauswährung.Kurz";
  LF_Print(g_alpha);
  GV.Alpha.01 # 'Materialkosten : '+anum(Art.SLK.Mat.KostW1,2)+' '+"set.Hauswährung.Kurz";
  LF_Print(g_alpha);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_ALPHA);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_SL);
  LF_FreeLine(g_Linie);

end;

//========================================================================