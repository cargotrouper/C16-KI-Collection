@A+
//===== Business-Control ==================================================
//
//  Prozedur    L_CON_950001
//                    OHNE E_R_G
//  Info        Controllingliste für Excelausgabe
//
//
//  01.03.2010  ST  Erstellung der Prozedur
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB Element(aName : alpha; aPrint : logic);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB EvtChanged(aEvt: event; ): logic
//    SUB EvtInit(aEvt: event;): logic
//    SUB getVal(aMode   : alpha;aType   : alpha;aMonat  : int;opt aSuffix : alpha;): float
//
//========================================================================
@I:Def_Global
@I:Def_List2

declare StartList(aSort : int; aSortName : alpha);
declare getVal(aMode   : alpha; aType   : alpha;  aMonat  : int;opt aSuffix : alpha): float

local begin

  g_Empty     : int;
  g_Sel1      : int;
  g_Sel2      : int;
  g_Sel3      : int;

  g_Header    : int;

  g_Pos_Soll  : int;
  g_Pos_Ist   : int;
  g_Pos_Sim   : int;

  g_Sum_Soll  : int;
  g_Sum_Ist   : int;
  g_Sum_Sim   : int;

  g_ConMode   : alpha;  // SOLL, IST, SIM
  g_ConTyp    : alpha;  // Menge, Umsatz, DB
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);

  // Aktuelles Jahr vorbelegen
  Sel.von.Jahr # DateYear(SysDate())+1900;

  // Auswahlmöglichkeiten für Selektion vorbelegen
  Gv.Logic.01 # true;
  Gv.Logic.02 # true;
  Gv.Logic.03 # true;
  Gv.Logic.04 # true;
  Gv.Logic.05 # true;
  Gv.Logic.06 # true;
  Gv.Logic.07 # true;

  // Mengendarstellung vorbelegen
  Gv.Logic.08 # true;
  Gv.Logic.09 # false;
  Gv.Logic.10 # false;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SEL.LST.950001',here+':AusSel');
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

  // Keine Sortierung anzugeben
  if (Gv.Logic.08) then g_ConTyp # 'Menge';
  if (Gv.Logic.09) then g_ConTyp # 'Umsatz';
  if (Gv.Logic.10) then g_ConTyp # 'DB';

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
  vLine : int;
  vObf  : alpha(120);
  vFldWdth : float;
  i : int;
  vModeSum : int;
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

      LF_Set(1, 'Jahr:'                            ,n , 0);
      LF_Set(2,  ZahlI("Sel.von.Jahr")            ,n , _LF_INT);

      LF_Set(4, 'Kunde:'                           ,n , 0);
      if (Gv.Logic.01) then
        LF_Set(5, 'alle'                          ,n , 0);
      else
        LF_Set(5, ZahlI(Sel.Adr.von.KdNr)         ,n , _LF_INT);

      LF_Set(7, 'Verteter:'                       ,n , 0);
      if (Gv.Logic.02) then
        LF_Set(8, 'alle' ,n , 0);
      else
        LF_Set(8, ZahlI(Sel.Adr.von.Vertret)     ,n , _LF_INT);

    end;


    'SEL2' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Warengruppe:'                     ,n , 0);
      if (Gv.Logic.03) then
        LF_Set(2, 'alle'                          ,n , 0);
      else
        LF_Set(2,  ZahlI("Sel.Art.von.WGr")       ,n , _LF_INT);

      LF_Set(4, 'Kostenstelle:'                    ,n , 0);
      if (Gv.Logic.04) then
        LF_Set(5, 'alle'                          ,n , 0);
      else
        LF_Set(5, ZahlI(Sel.Fin.von.KostenSt)     ,n , _LF_INT);

      LF_Set(7, 'Güte:'                           ,n , 0);
      if (Gv.Logic.07) then
        LF_Set(8, 'alle' ,n , 0);
      else
        LF_Set(8, Sel.Art.von.ArtNr              ,n , 0);

    end;


    'SEL3' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      LF_Set(1, 'Artikelgruppe:'                  ,n , 0);
      if (Gv.Logic.05) then
        LF_Set(2, 'alle'                          ,n , 0);
      else
        LF_Set(2,  ZahlI("Sel.Art.von.ArtGr")     ,n , _LF_INT);

      LF_Set(4, 'Artikelnummer:'                  ,n , 0);
      if (Gv.Logic.06) then
        LF_Set(5, 'alle'                          ,n , 0);
      else
        LF_Set(5, Sel.Art.von.ArtNr               ,n , 0);

      LF_Set(7, 'Datenbasis:'                     ,n,0);
      LF_Set(8, g_ConTyp                          ,n ,0);

     end;


    'HEADER' : begin

      if (aPrint) then RETURN;

      // Instanzieren...
      vFldWdth # 15.00;
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 25.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + vFldWdth;
      List_Spacing[ 4]  # List_Spacing[ 3]  + vFldWdth;
      List_Spacing[ 5]  # List_Spacing[ 4]  + vFldWdth;
      List_Spacing[ 6]  # List_Spacing[ 5]  + vFldWdth;
      List_Spacing[ 7]  # List_Spacing[ 6]  + vFldWdth;
      List_Spacing[ 8]  # List_Spacing[ 7]  + vFldWdth;
      List_Spacing[ 9]  # List_Spacing[ 8]  + vFldWdth;
      List_Spacing[10]  # List_Spacing[ 9]  + vFldWdth;
      List_Spacing[11]  # List_Spacing[ 10] + vFldWdth;
      List_Spacing[12]  # List_Spacing[ 11] + vFldWdth;
      List_Spacing[13]  # List_Spacing[ 12] + vFldWdth;
      List_Spacing[14]  # List_Spacing[ 13] + vFldWdth;
      List_Spacing[15]  # List_Spacing[ 14] + vFldWdth;
      List_Spacing[16]  # List_Spacing[ 15] + vFldWdth;
      List_Spacing[17]  # List_Spacing[ 16] + vFldWdth;
      List_Spacing[18]  # List_Spacing[ 17] + vFldWdth;
      List_Spacing[19]  # List_Spacing[ 18] + vFldWdth;

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Bezeichnung',n , 0);
      LF_Set(2,  'Jan'        ,y , 0);
      LF_Set(3,  'Feb'        ,y , 0);
      LF_Set(4,  'Mrz'        ,y , 0);
      LF_Set(5,  'Apr'        ,y , 0);
      LF_Set(6,  'Mai'        ,y , 0);
      LF_Set(7,  'Jun'        ,y , 0);
      LF_Set(8,  'Jul'        ,y , 0);
      LF_Set(9,  'Aug'        ,y , 0);
      LF_Set(10, 'Sep'        ,y , 0);
      LF_Set(11, 'Okt'        ,y , 0);
      LF_Set(12, 'Nov'        ,y , 0);
      LF_Set(13, 'Dez'        ,y , 0);
      LF_Set(14, 'Q1'         ,y , 0);
      LF_Set(15, 'Q2'         ,y , 0);
      LF_Set(16, 'Q3'         ,y , 0);
      LF_Set(17, 'Q4'         ,y , 0);
      LF_Set(18, 'Ges'        ,y , 0);
    end;


    'POS' : begin

      // Drucken
      if (aPrint) then begin

        case g_ConMode of
          'Soll' : vModeSum # 0;
          'Ist'  : vModeSum # 19;
          'Sim'  : vModeSum # 37;
        end;

        // Bezeichnung mit Anzeigemodus
        LF_Text(1,  Con.Bezeichnung + ' ' + g_ConMode);

        // Summierungen Monate
        FOR i # 1 LOOP inc(i) WHILE(i <=12) DO
          AddSum(i+vModeSum,getVal(g_ConMode,g_ConTyp,i));

        // Summierung Quartale
        AddSum(13+vModeSum,getVal(g_ConMode,g_ConTyp,1) +getVal(g_ConMode,g_ConTyp,2) +getVal(g_ConMode,g_ConTyp,3));
        AddSum(14+vModeSum,getVal(g_ConMode,g_ConTyp,4) +getVal(g_ConMode,g_ConTyp,5) +getVal(g_ConMode,g_ConTyp,6));
        AddSum(15+vModeSum,getVal(g_ConMode,g_ConTyp,7) +getVal(g_ConMode,g_ConTyp,8) +getVal(g_ConMode,g_ConTyp,9));
        AddSum(16+vModeSum,getVal(g_ConMode,g_ConTyp,10)+getVal(g_ConMode,g_ConTyp,11)+getVal(g_ConMode,g_ConTyp,12));

        // Summierung Gesamtsumme
        AddSum(17+vModeSum,getVal(g_ConMode,g_ConTyp,0,'Sum'));

        // Übergabe der Quartarlsumme an Ausgabe
        LF_Text(14,ZahlF(getVal(g_ConMode,g_ConTyp,1)+ getVal(g_ConMode,g_ConTyp,2) +getVal(g_ConMode,g_ConTyp,3),  0));
        LF_Text(15,ZahlF(getVal(g_ConMode,g_ConTyp,4) +getVal(g_ConMode,g_ConTyp,5) +getVal(g_ConMode,g_ConTyp,6),  0));
        LF_Text(16,ZahlF(getVal(g_ConMode,g_ConTyp,7) +getVal(g_ConMode,g_ConTyp,8) +getVal(g_ConMode,g_ConTyp,9),  0));
        LF_Text(17,ZahlF(getVal(g_ConMode,g_ConTyp,10)+getVal(g_ConMode,g_ConTyp,11)+getVal(g_ConMode,g_ConTyp,12), 0));

        RETURN;
      end;

      // Instanzieren...
      LF_Set(1,  'Bezeichnung'                        ,n ,0);
      LF_Set(2,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.1'  ,y , _LF_Wae);
      LF_Set(3,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.2'  ,y , _LF_Wae);
      LF_Set(4,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.3'  ,y , _LF_Wae);
      LF_Set(5,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.4'  ,y , _LF_Wae);
      LF_Set(6,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.5'  ,y , _LF_Wae);
      LF_Set(7,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.6'  ,y , _LF_Wae);
      LF_Set(8,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.7'  ,y , _LF_Wae);
      LF_Set(9,  '@Con.'+g_ConMode+'.'+g_ConTyp+'.8'  ,y , _LF_Wae);
      LF_Set(10, '@Con.'+g_ConMode+'.'+g_ConTyp+'.9'  ,y , _LF_Wae);
      LF_Set(11, '@Con.'+g_ConMode+'.'+g_ConTyp+'.10' ,y , _LF_Wae);
      LF_Set(12, '@Con.'+g_ConMode+'.'+g_ConTyp+'.11' ,y , _LF_Wae);
      LF_Set(13, '@Con.'+g_ConMode+'.'+g_ConTyp+'.12' ,y , _LF_Wae);
      LF_Set(14, 'Quartal1'                           ,y , _LF_Wae);
      LF_Set(15, 'Quartal2'                           ,y , _LF_Wae);
      LF_Set(16, 'Quartal3'                           ,y , _LF_Wae);
      LF_Set(17, 'Quartal4'                           ,y , _LF_Wae);
      LF_Set(18, '@Con.'+g_ConMode+'.'+g_ConTyp+'.Sum',y , _LF_Wae);
    end;


    'SUMME' : begin

      if (aPrint) then begin

        case g_ConMode of
          'Soll' : vModeSum # 0;
          'Ist'  : vModeSum # 19;
          'Sim'  : vModeSum # 37;
        end;

        LF_Text(1,'Summe '+g_ConMode + ':');

        // Monatssummen, Quartals und Gesamtsumem ausgeben
        FOR i # 2 LOOP inc(i) WHILE(i <=18) DO
          LF_Sum(i, i-1+vModeSum,2);

        RETURN;
      end;

      // Instanzieren...
      if (g_ConMode = 'Soll') then
        LF_Format(_LF_Overline + _LF_Bold);
      else
        LF_Format(_LF_Bold);

      LF_Set(1, 'Summe' ,y , 0);
      FOR i # 2 LOOP inc(i) WHILE(i <=18) DO
        LF_Set(i, '0' ,y , _LF_Wae);

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
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;

  vQ          : alpha(4000);
  vQ1         : alpha(4000);
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektion erstellen und später füllen
  vSel # SelCreate(950,1);


  if (Sel.Art.nurMarkeYN) then begin
    // -----------------------------
    // Nur Markierung
    // -----------------------------

    // Selektion starten...
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen
    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(950,_SelLock,vSelName);   // Selektion laden

    // Einträge der Markierungsliste in die Selektion schreiben
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 950) then begin
        RecRead(950,0,_RecId,vMID);
        Erx # SelRecInsert(vSel,950);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin
    // -----------------------------
    // Selektion über Werte
    // -----------------------------
    vQ # '';

    // Jahr, grundsätzlich selektieren
    Lib_Sel:QInt(var vQ, '"Con.Jahr"','=', "Sel.von.Jahr");

    // Kunde
    if (!Gv.Logic.01) then
      Lib_Sel:QInt(var vQ, '"Con.Adressnummer"', '=',"Sel.Adr.von.KdNr");

    // Vertreter
    if (!Gv.Logic.02) then
      Lib_Sel:QInt(var vQ, '"Con.Vertreternr"', '=',"Sel.Adr.von.Vertret");

    // Warengruppe
    if (!Gv.Logic.03) then
      Lib_Sel:QInt(var vQ, '"Con.Warengruppe"', '=',"Sel.Art.von.WGr");

    // Kostenstelle
    if (!GV.Logic.04) then
      Lib_Sel:QInt(var vQ, '"Con.Kostenstelle"', '=',"Sel.Fin.von.KostenSt");


    if(!GV.Logic.06) then begin

      // Artikelgruppe
      if (!GV.Logic.05) then
        Lib_Sel:QInt(var vQ, '"Con.Artikelgruppe"', '=',"Sel.Art.von.ArtGr");

      // Artikelnummer
      if (!GV.Logic.06) then begin

        Lib_Sel:QAlpha(var vQ, '"Con.Artikelnummer"', '=', Sel.Art.von.ArtNr);
      end;
    end;

    if !(GV.Logic.05 OR GV.Logic.06) then begin
      // Güte
      if (!GV.Logic.07) then
        Lib_Sel:QAlpha(var vQ, '"Con.Artikelnummer"', '=', "Sel.Mat.Güte");
    end;


    // Keine Selektion bei Kennzahlen, die KEINE Angabe hinterlegt haben -> Unternehmen
    vQ # vQ + 'AND ((Con.Adressnummer <> 0) OR (Con.Vertreternr <> 0) OR (Con.Warengruppe <> 0) ' +
              ' OR (Con.Kostenstelle <> 0) OR (Con.Artikelgruppe <> 0) OR (Con.Artikelnummer <> ''''))';

    // Selektion ausführen
    Erx # vSel->SelDefQuery('', vQ);

    vSelName # Lib_Sel:SaveRun(var vSel, 0);
  end;

  // Sortieren
  vFlag # _RecFirst;
  WHILE (RecRead(950,vSel,vFlag) <= _rLocked) DO BEGIN
    vFlag # _RecNext;
    vSortKey # Con.Bezeichnung;
    Sort_ItemAdd(vTree,vSortKey,950,RecInfo(950,_RecId));
  END;

  // Selektion schließen und löschen, Daten sind im Raumbaum
  SelClose(vSel);
  SelDelete(950, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------

  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Header    # LF_NewLine('HEADER');

  g_ConMode   # 'Soll';
  g_Pos_Soll  # LF_NewLine('POS');
  g_Sum_Soll  # LF_NewLine('SUMME');

  g_ConMode   # 'Ist';
  g_Pos_Ist   # LF_NewLine('POS');
  g_Sum_Ist   # LF_NewLine('SUMME');

  g_ConMode   # 'Sim';
  g_Pos_Sim   # LF_NewLine('POS');
  g_Sum_Sim   # LF_NewLine('SUMME');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Liste starten
  LF_Init(y);    // Landscape

  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);

    g_ConMode # 'Soll';
    LF_Print(g_Pos_Soll);

    g_ConMode # 'Ist';
    LF_Print(g_Pos_Ist);

    g_ConMode # 'Sim';
    LF_Print(g_Pos_Sim);

    LF_Print(g_Empty);
  END;

  g_ConMode # 'Soll';
  LF_Print(g_Sum_Soll);

  g_ConMode # 'Ist';
  LF_Print(g_Sum_Ist);

  g_ConMode # 'Sim';
  LF_Print(g_Sum_Sim);


  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Pos_Soll);
  LF_FreeLine(g_Pos_Ist);
  LF_FreeLine(g_Pos_Sim);
  LF_FreeLine(g_Sum_Soll);
  LF_FreeLine(g_Sum_Ist);
  LF_FreeLine(g_Sum_Sim);
end;



//========================================================================
// EvtChanged
//
//========================================================================
sub EvtChanged(
  aEvt                  : event;        // Ereignis
): logic
begin
  // 25.06.2014
  if (aEvt:Obj->wpchanged=false) then RETURN true;

  if (aEvt:Obj->wpName = 'cb.Mengen') OR
     (aEvt:Obj->wpName = 'cb.Umsatz') OR
     (aEvt:Obj->wpName = 'cb.Deckungsb') then begin

    Gv.Logic.08 # false;
    Gv.Logic.09 # false;
    Gv.Logic.10 # false;

    if (aEvt:Obj->wpName = 'cb.Mengen') then begin
      $cb.Mengen->wpCheckState    # _WinStateChkchecked;
      $cb.Umsatz->wpCheckState    # _WinStateChkUnchecked;
      $cb.Deckungsb->wpCheckState # _WinStateChkUnchecked;
      Gv.Logic.08 # true;
    end;

    if (aEvt:Obj->wpName = 'cb.Umsatz') then begin
      $cb.Mengen->wpCheckState    # _WinStateChkUnchecked;
      $cb.Umsatz->wpCheckState    # _WinStateChkchecked;
      $cb.Deckungsb->wpCheckState # _WinStateChkUnchecked;
      Gv.Logic.09 # true;
    end;

    if (aEvt:Obj->wpName = 'cb.Deckungsb') then begin
      $cb.Umsatz->wpCheckState    # _WinStateChkUnchecked;
      $cb.Mengen->wpCheckState    # _WinStateChkUnchecked;
      $cb.Deckungsb->wpCheckState # _WinStateChkchecked;
      Gv.Logic.10 # true;
    end;

    $cb.Umsatz->winupdate(_WinUpdFld2Obj);
    $cb.Deckungsb->winupdate(_WinUpdFld2Obj);
    $cb.Umsatz->winupdate(_WinUpdFld2Obj);
  end;



  if (StrFind(aEvt:Obj->wpName,'cb.Alle',1) = 1) then begin

    // F9-Felder deaktivieren oder aktivieren
    if (aEvt:Obj->wpName = 'cb.AlleKunden') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edKunde);
        Lib_GuiCom:Disable($bt.Kunde);
      end else begin
        Lib_GuiCom:Enable($edKunde);
        Lib_GuiCom:Enable($bt.Kunde);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleVertreter') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edVertreter);
        Lib_GuiCom:Disable($bt.Vertreter);
      end else begin
        Lib_GuiCom:Enable($edVertreter);
        Lib_GuiCom:Enable($bt.Vertreter);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleWarengruppen') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edWgr);
        Lib_GuiCom:Disable($bt.Wgr);
      end else begin
        Lib_GuiCom:Enable($edWgr);
        Lib_GuiCom:Enable($bt.Wgr);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleKostenstellen') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edKostenstelle);
        Lib_GuiCom:Disable($bt.Kostenstelle);
      end else begin
        Lib_GuiCom:Enable($edKostenstelle);
        Lib_GuiCom:Enable($bt.Kostenstelle);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleArtikelgruppen') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edAgr);
        Lib_GuiCom:Disable($bt.Agr);
      end else begin
        Lib_GuiCom:Enable($edAgr);
        Lib_GuiCom:Enable($bt.Agr);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleArtikelnummern') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edArtikel);
        Lib_GuiCom:Disable($bt.Artikel);
      end else begin
        Lib_GuiCom:Enable($edArtikel);
        Lib_GuiCom:Enable($bt.Artikel);
      end;
    end;

    if (aEvt:Obj->wpName = 'cb.AlleGueten') then begin
      if (aEvt:Obj->wpCheckState = _WinStateChkChecked) then begin
        Lib_GuiCom:Disable($edGuete);
        Lib_GuiCom:Disable($bt.Guete);
      end else begin
        Lib_GuiCom:Enable($edGuete);
        Lib_GuiCom:Enable($bt.Guete);
      end;
    end;


  end;

end;

//========================================================================
// EvtInit
//          Initialisieren der Applikation
//========================================================================
sub EvtInit(
  aEvt                  : event;        // Ereignis
): logic
begin
  WinSearchPath(aEvt:Obj);

  // Aufruf des "Konstruktors"
  Sel_Main:EvtInit(aEvt);

  // Elemente ausblenden
  Lib_GuiCom:Disable($edKunde);
  Lib_GuiCom:Disable($bt.Kunde);
  Lib_GuiCom:Disable($edVertreter);
  Lib_GuiCom:Disable($bt.Vertreter);
  Lib_GuiCom:Disable($edWgr);
  Lib_GuiCom:Disable($bt.Wgr);
  Lib_GuiCom:Disable($edKostenstelle);
  Lib_GuiCom:Disable($bt.Kostenstelle);
  Lib_GuiCom:Disable($edAgr);
  Lib_GuiCom:Disable($bt.Agr);
  Lib_GuiCom:Disable($edArtikel);
  Lib_GuiCom:Disable($bt.Artikel2);
  Lib_GuiCom:Disable($edGuete);
  Lib_GuiCom:Disable($bt.Guete);

  aEvt:Obj->WinUpdate();
end;



//========================================================================
// getVal
//    Liest einen Wert aus der Controllingdatei
//========================================================================
sub getVal(
  aMode   : alpha;
  aType   : alpha;
  aMonat  : int;
  opt aSuffix : alpha;
): float
local begin
  vFldName : alpha
end
begin

  if (aSuffix = '') then
    vFldName # 'Con.'+aMode+'.'+aType+'.'+CnvAi(aMonat,_FmtInternal);
  else
    vFldName # 'Con.'+aMode+'.'+aType+'.'+aSuffix;

  return FldFloatByName(vFldName);
end;


//========================================================================