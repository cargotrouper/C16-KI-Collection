@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250013
//                    OHNE E_R_G
//  Info        Artikelbestand mit Chargenauflösung
//
//
//  01.08.2011  MS  Erstellung der Prozedur
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

define begin
  cGesSumSummeDurschn : 1
end;

// Handles für die Zeilenelemente
local begin
  g_Empty            : int;
  g_Artikel          : int;
  g_ArtikelTechDaten : int;
  g_Material         : int;
  g_Charge           : int;
  g_Header           : int;
  g_GesSum           : int;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.SachNr      # 'zzz';
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Art.bis.Stichwor    # 'zzz';
  Sel.Art.mitChargeYN     # true;

  List_FontSize # 8;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.250013', here + ':AusSel');
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
  vHdl2->WinLstDatLineAdd('Artikelgruppe');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Sachnummer');
  vHdl2->WinLstDatLineAdd('Stichwort');
  vHdl2->WinLstDatLineAdd('Warengruppe');
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
    if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end;
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort, vSortname);  // Liste generieren
end;


//========================================================================
//  Element
//
//========================================================================
sub Element(
  aName   : alpha;
  aPrint  : logic);
local begin
  vLine     : int;
  vObf      : alpha(120);
  vPreis    : float;
  vPreisPEH : int;
  vSumme    : float;
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


    'HEADER' : begin

      if (aPrint) then RETURN;

      /*
      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 120.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 00.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 00.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 00.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 00.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 00.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 10.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 22.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 22.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 20.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //
      */

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 17.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 17.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 10.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 25.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 10.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 20.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 30.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //

      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'Artikelnr'                              ,n , 0);
      LF_Set(2,  'Bezeichnung'                            ,n , 0);
      LF_Set(3,  'Dicke'                                  ,y , 0);
      LF_Set(4,  'Breite'                                 ,y , 0);
      LF_Set(5,  'Länge'                                  ,y , 0);
      LF_Set(6,  'I-Ø'                                    ,y , 0);
      LF_Set(7,  'A-Ø'                                    ,y , 0);
      LF_Set(8,  'Wgr.'                                   ,y , 0);
      LF_Set(9,  'Grp.'                                   ,y , 0);
      LF_Set(10,  'Typ'                                   ,n , 0);
      LF_Set(11,  'Menge'                                 ,y , 0);
      LF_Set(12,  'MEH'                                   ,n , 0);
      LF_Set(13,  'letzter EK'                            ,y , 0);
      if(List_XML = true) then begin
        LF_Set(14,  'durschn. EK'                         ,y , 0);
        LF_Set(15,  'Summe durchschn.'                    ,y , 0);
      end
      else begin
        LF_Set(14,  'Ø EK'                                ,y , 0);
        LF_Set(15,  'Summe Ø'                             ,y , 0);
      end;
    end;


    'ARTIKEL' : begin
      if (aPrint) then begin
        vSumme # 0.0;
        if(Art.PEH <> 0) then
          vSumme # (Art.C.Bestand / cnvFI(Art.PEH)) * Art.C.EKDurchschnitt;
        LF_Text(15, ZahlF(vSumme, 2));

        AddSum(cGesSumSummeDurschn, vSumme);
        RETURN;
      end;


      // Instanzieren...
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 94.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 00.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 00.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 00.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 00.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 00.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 25.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 10.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 20.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 30.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //


      if(Sel.Art.mitChargeYN = true) then
        LF_Format(_LF_Bold);

      // Instanzieren...
      LF_Set(1,  '@Art.Nummer'    ,n , 0);
      LF_Set(2,  '@Art.Bezeichnung1'          ,n , 0);

      LF_Set(8,  '@Art.Warengruppe'      ,y , _LF_IntNG);
      LF_Set(9,  '@Art.Artikelgruppe'      ,y , _LF_IntNG);
      LF_Set(10,  '@Art.Typ'      ,n , 0);
      LF_Set(11,  '@Art.C.Bestand'        ,y , _LF_Num3, Set.Stellen.Menge);
      LF_Set(12,  '@Art.MEH'      ,n , 0);
      LF_Set(13,  '@Art.C.EKLetzter'        ,y , _LF_Wae, 2);
      LF_Set(14,  '@Art.C.EKDurchschnitt'        ,y , _LF_Wae, 2);
      LF_Set(15, '#Summe'        ,y , _LF_Wae, 2);
    end;

    'MATERIAL' : begin
      if (aPrint) then begin
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 17.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 17.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 10.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 25.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 10.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 20.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 30.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //

      // Instanzieren...
      LF_Set(1,  '@Mat.Nummer'    ,n , 0);
      LF_Set(2,  '@Stt.Bezeichnung'          ,n , 0);
      LF_Set(3,  '@Mat.Dicke'          ,y , _LF_Num, Set.Stellen.Dicke);
      LF_Set(4,  '@Mat.Breite'         ,y , _LF_Num, Set.Stellen.Breite);
      LF_Set(5,  '@Mat.Länge'          ,y , _LF_Num, "Set.Stellen.Länge");
      LF_Set(6,  '@Mat.RID'          ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(7,  '@Mat.RAD'         ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(8,  ''          ,n , 0);
      LF_Set(9,  ''          ,n , 0);
      LF_Set(10,  ''          ,n , 0);
      LF_Set(11,  '@Mat.Bestand.Gew'        ,y , _LF_Num3, Set.Stellen.Menge);
      LF_Set(12,  'kg'      ,n , 0);
      LF_Set(13,  ''          ,n , 0);
      LF_Set(14,  ''          ,n , 0);
      LF_Set(15, ''        ,y , _LF_Wae, 2);
    end;

    'CHARGE' : begin
      if (aPrint) then begin
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 17.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 17.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 10.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 25.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 10.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 20.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 30.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //


      // Instanzieren...
      LF_Set(1,  '@Art.C.Charge.Intern'    ,n , 0);
      LF_Set(2,  '@Art.C.Charge.Extern'          ,n , 0);
      LF_Set(3,  '@Art.C.Dicke'          ,y , _LF_Num, Set.Stellen.Dicke);
      LF_Set(4,  '@Art.C.Breite'         ,y , _LF_Num, Set.Stellen.Breite);
      LF_Set(5,  '@Art.C.Länge'          ,y , _LF_Num, "Set.Stellen.Länge");
      LF_Set(6,  '@Art.C.RID'          ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(7,  '@Art.C.RAD'         ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(8,  ''          ,n , 0);
      LF_Set(9,  ''          ,n , 0);
      LF_Set(10,  ''          ,n , 0);
      LF_Set(11,  '@Art.C.Bestand'        ,y , _LF_Num3, Set.Stellen.Menge);
      LF_Set(12,  '@Art.MEH'      ,n , 0);
      LF_Set(13,  ''          ,n , 0);
      LF_Set(14,  ''          ,n , 0);
      LF_Set(15, ''        ,y , _LF_Wae, 2);
    end;

    'ARTIKELTECHDATEN' : begin
      if (aPrint) then begin
        RETURN;
      end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 35.0; //  'Artikelnr'
      List_Spacing[ 3]  # List_Spacing[ 2]  + 25.0; // 'Bezeichnung'
      List_Spacing[ 4]  # List_Spacing[ 3]  + 15.0; //  'Dicke'
      List_Spacing[ 5]  # List_Spacing[ 4]  + 17.0; //  'Breite'
      List_Spacing[ 6]  # List_Spacing[ 5]  + 17.0; //  'Länge'
      List_Spacing[ 7]  # List_Spacing[ 6]  + 10.0; //  'Innen-Ø'
      List_Spacing[ 8]  # List_Spacing[ 7]  + 10.0; //  'Außen-Ø'
      List_Spacing[ 9]  # List_Spacing[ 8]  + 10.0; //  'Wgr.'
      List_Spacing[10]  # List_Spacing[ 9]  + 10.0; //  'Grp.'
      List_Spacing[11]  # List_Spacing[10]  + 20.0; //  'Typ'
      List_Spacing[12]  # List_Spacing[11]  + 25.0; //  'Menge'
      List_Spacing[13]  # List_Spacing[12]  + 10.0; //  'MEH'
      List_Spacing[14]  # List_Spacing[13]  + 20.0; //  'letzter EK'
      List_Spacing[15]  # List_Spacing[14]  + 25.0; //  'durschn. EK'
      List_Spacing[16]  # List_Spacing[15]  + 30.0; //  'Summe'
      List_Spacing[17]  # List_Spacing[16]  + 20.0; //
      List_Spacing[18]  # List_Spacing[17]  + 20.0; //


      // Instanzieren...
      LF_Set(1,  ''    ,n , 0);
      LF_Set(2,  ''          ,n , 0);
      LF_Set(3,  '@Art.Dicke'          ,y , _LF_Num, Set.Stellen.Dicke);
      LF_Set(4,  '@Art.Breite'         ,y , _LF_Num, Set.Stellen.Breite);
      LF_Set(5,  '@Art.Länge'          ,y , _LF_Num, "Set.Stellen.Länge");
      LF_Set(6,  '@Art.Innendmesser'          ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(7,  '@Art.Aussendmesser'         ,y , _LF_Num, Set.Stellen.Radien);
      LF_Set(8,  ''          ,n , 0);
      LF_Set(9,  ''          ,n , 0);
      LF_Set(10,  ''          ,n , 0);
      LF_Set(11,  ''        ,y , _LF_Num3, Set.Stellen.Menge);
      LF_Set(12,  ''      ,n , 0);
      LF_Set(13,  ''          ,n , 0);
      LF_Set(14,  ''          ,n , 0);
      LF_Set(15, ''        ,y , _LF_Wae, 2);
    end;

    'GESSUM' : begin
      if (aPrint) then begin
        LF_Sum(15, cGesSumSummeDurschn, 2);
        RETURN;
      end;

      LF_Format(_LF_OverLine + _LF_Bold);
      // Instanzieren...
      LF_Set(1,  'Gesamt:'    ,n , 0);
      LF_Set(2,  ''          ,n , 0);

      LF_Set(8,  ''          ,n , 0);
      LF_Set(9,  ''          ,n , 0);
      LF_Set(10,  ''          ,n , 0);
      LF_Set(11,  ''        ,y , _LF_Num3, Set.Stellen.Menge);
      LF_Set(12,  ''         ,n , 0);
      LF_Set(13,  ''          ,n , 0);
      LF_Set(14,  ''          ,n , 0);
      LF_Set(15, '#Summe'        ,y , _LF_Wae, 2);
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

  if (aSeite = 1) then begin
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

  vProgress   : handle;
  vQ250       : alpha(4000);
end;
begin
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektionsquery
  vQ250 # '';
  if (Sel.Art.von.ArtNr != '') or (Sel.Art.bis.ArtNr != 'zzz') then
    Lib_Sel:QVonBisA(var vQ250, 'Art.Nummer', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);
  if (Sel.Art.von.Stichwor != '') or (Sel.Art.bis.Stichwor != 'zzz') then
    Lib_Sel:QVonBisA(var vQ250, 'Art.Stichwort', Sel.Art.von.Stichwor, Sel.Art.bis.Stichwor);
  if (Sel.Art.von.SachNr != '') or (Sel.Art.bis.SachNr != 'zzz') then
    Lib_Sel:QVonBisA(var vQ250, 'Art.Sachnummer', Sel.Art.von.SachNr, Sel.Art.bis.SachNr);
  if (Sel.Art.von.Typ != '') then
    Lib_Sel:QAlpha(var vQ250, 'Art.Typ', '=', Sel.Art.von.Typ);
  if (Sel.Art.von.ArtGr != 0) or (Sel.Art.bis.ArtGr != 9999) then
    Lib_Sel:QVonBisI(var vQ250, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr);
  if (Sel.Art.von.WGr != 0) or (Sel.Art.bis.WGr != 9999) then
    Lib_Sel:QVonBisI(var vQ250, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr);

    vSel # SelCreate(250, 1);
  Erx # vSel->SelDefQuery('', vQ250);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 0);

  vProgress # Lib_Progress:Init( 'Sortierung', RecInfo( 250, _recCount, vSel ) );

  FOR Erx # RecRead(250,vSel, _recFirst);
  LOOP Erx # RecRead(250,vSel, _recNext);
  WHILE (Erx <= _rLocked) DO BEGIN
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      SelClose(vSel);
      SelDelete(250, vSelName);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    if (aSort = 1) then vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5) + StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort = 2) then vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
    if (aSort = 3) then vSortKey # StrFmt(Art.Sachnummer, 20, _StrEnd);
    if (aSort = 4) then vSortKey # StrFmt(Art.Stichwort, 20, _StrEnd);
    if (aSort = 5) then vSortKey # cnvAI(Art.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7);

    Sort_ItemAdd(vTree,vSortKey,250,RecInfo(250,_RecId));
  END;
  SelClose(vSel);
  SelDelete(250, vSelName);
  vSel # 0;

  // Ausgabe ----------------------------------------------------------------
  vProgress->Lib_Progress:Reset( 'Listengenerierung', CteInfo( vTree, _cteCount ) );

  // Druckelemente generieren...
  g_Empty              # LF_NewLine('EMPTY');
  g_Header             # LF_NewLine('HEADER');
  g_Artikel            # LF_NewLine('ARTIKEL');
  g_ArtikelTechDaten   # LF_NewLine('ARTIKELTECHDATEN');
  g_Material           # LF_NewLine('MATERIAL');
  g_Charge             # LF_NewLine('CHARGE');
  g_GesSum             # LF_NewLine('GESSUM');


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(true);    // Landscape


   // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin
    // Progress
    if (!vProgress->Lib_Progress:Step()) then begin
      Sort_KillList(vTree);
      vProgress->Lib_Progress:Term();
      RETURN;
    end;

    // Datensatz holen
    RecRead(cnvIA(vItem->spCustom), 0, 0, vItem->spID);

    Erx # RecLink(819, 250, 10, _recFirst); // Warengruppe holen
    if(Erx > _rLocked) then
      RecBufClear(819);

    RecBufClear(252);
    Art.C.ArtikelNr # Art.Nummer;
    if (Art.C.ArtikelNr <> '') then
      Art_Data:ReadCharge();

    if(Art.C.Bestand = 0.0) then // nur Artikel mit Bestand!
      CYCLE;

    LF_Print(g_Artikel);

    if (Sel.Art.mitChargeYN = true) then begin
      if (Wgr_Data:IstMix()) then begin             // MATERIALCHARGE?
        FOR Erx # RecLink(200, 250, 8, _recFirst); // Material loopen
        LOOP Erx # RecLink(200, 250, 8, _recNext);
        WHILE(Erx <= _rLocked) DO BEGIN
          if("Mat.Löschmarker" = '*')
          or (Mat.Eingangsdatum = 00.00.0000)
          or (Mat.Ausgangsdatum > 00.00.0000)
          or (Mat.EigenmaterialYN = false) then
            CYCLE;
          Erx # RecLink(820, 200, 9, _recFirst); // Material Status holen
          if(Erx > _rLocked) then
            RecBufClear(820);

          LF_Print(g_Material)
        END;
      end
      else begin // Artikel
        FOR Erx # RecLink(252, 250, 4, _recFirst); // Chargen loopen
        LOOP Erx # RecLink(252, 250, 4, _recNext);
        WHILE(Erx <= _rLocked) DO BEGIN
          if(Art.C.Adressnr = 0) and (Art.C.Anschriftnr = 0) or (Art.C.Bestand = 0.0) then // BASIS Charge UND Chargen mit 0 ueberspringen
            CYCLE;

          LF_Print(g_Charge)
        END;
      end;
    end
    else begin
      if("Art.Länge" + Art.Breite + Art.Dicke + Art.Aussendmesser + Art.Innendmesser > 0.0) then
        LF_Print(g_ArtikelTechDaten);
    end;

    LF_Print(g_Empty);
  END;

  LF_Print(g_GesSum);

  // Löschen der Liste
  Sort_KillList(vTree);

  // Liste beenden
  vProgress->Lib_Progress:Term();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Artikel);
  LF_FreeLine(g_ArtikelTechDaten);
  LF_FreeLine(g_Material);
  LF_FreeLine(g_Charge);
  LF_FreeLine(g_GesSum);
  LF_FreeLine(g_Empty);
end;


//========================================================================