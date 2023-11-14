@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250003
//                    OHNE E_R_G
//  Info        Inventurbestand
//
//
//  21.03.2006  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  20.04.2010  MS  Umstellung neues Listenformat
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
//@I:Def_List
@I:Def_List2

declare StartList(aSort : int; aSortName : alpha);

define begin
  cGesSumInvWarenwert : 1
end;

// Handles für die Zeilenelemente
local begin
  g_Empty     : int;
  g_Sel1      : int;
  g_Sel2      : int;
  g_Sel3      : int;
  g_Header    : int;
  g_Artikel   : int;
  g_GesSum    : int;
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Art.bis.ArtNr       # 'zzz';
  Sel.Art.bis.Typ         # 'zzz';
  Sel.Art.bis.SachNr      # 'zzz';
  Sel.Art.bis.Wgr         # 9999;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Art.bis.Stichwor    # 'zzz';
  "Sel.Art.-VerfügbarYN"  # false;
  "Sel.Art.+VerfügbarYN"  # false;
  Sel.Art.OutOfSollYN     # false;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.250003', here + ':AusSel');
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
  vHdl # WinOpen('Lfm.Sortierung',_WinOpendialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Sachnummer');
  vHdl2->WinLstDatLineAdd('Warengruppe');
  vHdl2->WinLstDatLineAdd('Artikelgruppe');
  vHdl2->WinLstDatLineAdd('Stichwort');
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
  vLine : int;
  vObf  : alpha(120);
end;
begin
  case aName of

    'SEL1' : begin

      if (aPrint) then RETURN;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;
      List_Spacing[ 3]  # List_Spacing[ 2] +  3.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 9.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 9.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 3.0;
      List_Spacing[10]  # List_Spacing[ 9] + 9.0;
      List_Spacing[11]  # List_Spacing[10] + 30.0;
      List_Spacing[12]  # List_Spacing[11] + 9.0;
      List_Spacing[13]  # List_Spacing[12] + 30.0;

      LF_Set(1, 'Artikelnummer'                                          ,n , 0);
      LF_Set(2, ' : '                                                    ,n , 0);
      LF_Set(3, ' von: '                                                 ,n , 0);
      LF_Set(4, Sel.Art.von.ArtNr                                        ,n , 0);
      LF_Set(5, ' bis: '                                                 ,n , 0);
      LF_Set(6, Sel.Art.bis.ArtNr                                        ,n , 0);
      LF_Set(7, 'Artikeltyp'                                             ,n , 0);
      LF_Set(8, ' : '                                                    ,n , 0);
      // LF_Set(9, ' von: '                                                 ,n , 0);
      LF_Set(10, Sel.Art.von.Typ                                         ,n , 0);
      //LF_Set(11, ' bis: '                                                 ,n , 0);
      //LF_Set(12, Sel.Art.bis.Typ
    end;

    'SEL2' : begin
      if (aPrint) then RETURN;

      LF_Set(1, 'Stichwort'                                              ,n , 0);
      LF_Set(2, ' : '                                                    ,n , 0);
      LF_Set(3, ' von: '                                                 ,n , 0);
      LF_Set(4, Sel.Art.von.Stichwor                                     ,n , 0);
      LF_Set(5, ' bis: '                                                 ,n , 0);
      LF_Set(6, Sel.Art.bis.Stichwor                                     ,n , 0);
      LF_Set(7, 'Warengruppe'                                            ,n , 0);
      LF_Set(8, ' : '                                                    ,n , 0);
      LF_Set(9, ' von: '                                                 ,n , 0);
      LF_Set(10, ZahlI(Sel.Art.von.WGr)                                  ,y , 0);
      LF_Set(11, ' bis: '                                                ,n , 0);
      LF_Set(12, ZahlI(Sel.Art.bis.WGr)                                  ,y , 0);
    end;

    'SEL3' : begin
      if (aPrint) then RETURN;

      LF_Set(1, 'Sachnummer'                                             ,n , 0);
      LF_Set(2, ' : '                                                    ,n , 0);
      LF_Set(3, ' von: '                                                 ,n , 0);
      LF_Set(4, Sel.Art.von.SachNr                                       ,n , 0);
      LF_Set(5, ' bis: '                                                 ,n , 0);
      LF_Set(6, Sel.Art.bis.SachNr                                       ,n , 0);
      LF_Set(7, 'Artikelgruppe'                                          ,n , 0);
      LF_Set(8, ' : '                                                    ,n , 0);
      LF_Set(9, ' von: '                                                 ,n , 0);
      LF_Set(10, ZahlI(Sel.Art.von.ArtGr)                                ,y , 0);
      LF_Set(11, ' bis: '                                                ,n , 0);
      LF_Set(12, ZahlI(Sel.Art.bis.ArtGr)                                ,y , 0);
    end;





    'EMPTY' : begin
      if (aPrint) then RETURN;

    end;


    'HEADER' : begin
      if (aPrint) then RETURN;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 15.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 10.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 15.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 40.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 35.0;
      List_Spacing[10]  # List_Spacing[ 9] + 40.0;
      List_Spacing[11]  # List_Spacing[10] + 30.0;
     /* List_Spacing[12]  # List_Spacing[11] + 5.0;
      List_Spacing[13]  # List_Spacing[12] + 5.0; */


      LF_Format(_LF_UnderLine + _LF_Bold);
      LF_Set(1,  'ArtNr'                                 ,n , 0);
      LF_Set(2,  'Stichwort'                             ,n , 0);
      LF_Set(3,  'Typ'                                   ,n , 0);
      LF_Set(4,  'Wgr'                                   ,y , 0);
      LF_Set(5,  'ArtGr'                                 ,y , 0);
      LF_Set(6,  'Inventurb.'                            ,y , 0);
      LF_Set(7,  'Ø-EK Preis pro'                        ,y , 0);
      LF_Set(8,  'Waren wert'                            ,y , 0);
      LF_Set(9,  'Inv-EK Preis pro'                      ,y , 0);
      LF_Set(10, 'Waren wert'                            ,y , 0);
    end;

    'ARTIKEL' : begin
      if (aPrint) then begin
        Gv.Num.01 # 0.0;
        Gv.Num.02 # 0.0;

        // Preis holen
        RecBufClear(254);
        Art.P.ArtikelNr # Art.Nummer;
        Art.P.Preistyp  # 'Ø-EK';
        Erx # RecRead(254,5,0);
        if (Erx>_rMultikey) then RecBufClear(254);
        Gv.Num.01   # Art.P.PreisW1;
        Gv.Alpha.01 # Art.P.MEH;
        Gv.Int.01   # Art.P.PEH;
        if (Art.P.PEH <> 0) then
          Gv.Num.02 # Art.Bestand.Inventur * Art.P.PreisW1 / cnvfi(Art.P.PEH)
        else
          Gv.Num.02 # 0.0;

        // Preis holen
        RecBufClear(254);
        Art.P.ArtikelNr # Art.Nummer;
        Art.P.Preistyp  # 'INVEK';
        Erx # RecRead(254,5,0);
        if (Erx>_rMultikey) then RecBufClear(254);
        Gv.Num.03   # Art.P.PreisW1;
        Gv.Alpha.02 # Art.P.MEH;
        Gv.Int.02   # Art.P.PEH;
        if (Art.P.PEH <> 0) then
          Gv.Num.04 # Art.Bestand.Inventur * Art.P.PreisW1 / cnvfi(Art.P.PEH)
        else
          Gv.Num.04 # 0.0;

        LF_Text( 6, ZahlF(Art.Bestand.Inventur,2) + Art.MEH                                                       );
        LF_Text( 7, ZahlF(GV.Num.01,2) + "Set.Hauswährung.Kurz"+'/'+ZahlI(GV.Int.01)+ GV.Alpha.01                   );
        LF_Text( 8, ZahlF(GV.Num.02,2)                                                                            );
        LF_Text( 9, ZahlF(GV.Num.03,2) + "Set.Hauswährung.Kurz" +'/'+ ZahlI(GV.Int.03) +  GV.Alpha.03             );
        LF_Text(10, ZahlF(GV.Num.04,2)   );

        AddSum(cGesSumInvWarenwert, GV.Num.04);
        RETURN;
      end;

      LF_Set( 1, '@Art.Nummer'                            ,n , 0);
      LF_Set( 2, '@Art.Stichwort'                         ,n , 0);
      LF_Set( 3, '@Art.Typ'                               ,n , 0);
      LF_Set( 4, '@Art.Warengruppe'                       ,y , _LF_IntNG);
      LF_Set( 5, '@Art.Artikelgruppe'                     ,y , _LF_IntNG);
      LF_Set( 6, '#Inventurb.'                            ,y , 0);
      LF_Set( 7, '#Ø-EK Preis pro'                        ,y , 0);
      LF_Set( 8, '#Waren wert'                            ,y , _LF_Num);
      LF_Set( 9, '#Inv-EK Preis pro'                      ,y , 0);
      LF_Set(10, '#Waren wert'                            ,y , _LF_Num);
    end;

    'GESSUM' : begin
      if (aPrint) then begin
        LF_Text(10, ZahlF(GetSum(cGesSumInvWarenwert), 2));
        RETURN;
      end;
      LF_Format(_LF_OverLine + _LF_Bold);
      LF_Set(10, '#Waren wert'                            ,y , _LF_Num);
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
  vQ          : alpha(4000);

  vTree       : int;
  vSortKey    : alpha;
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  /*
  // Sortierung setzen
  if (aSort=1) then vKey # 1; // Artikelnummer
  if (aSort=2) then vKey # 3; // Sachnummer
  if (aSort=3) then vKey # 10; // Wgr
  if (aSort=4) then vKey # 11; // Agr
  if (aSort=5) then vKey # 6; // Stichwort
  */
  if (aSort = 1) then vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
  if (aSort = 2) then vSortKey # StrFmt(Art.Sachnummer, 20, _StrEnd);
  if (aSort = 3) then vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5) + StrFmt(Art.Nummer, 20, _StrEnd);
  if (aSort = 4) then vSortKey # cnvAI(Art.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7);
  if (aSort = 5) then vSortKey # StrFmt(Art.Stichwort, 20, _StrEnd);

  if (Sel.Art.nurMarkeYN) then begin // nur Markierte
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    FOR vItem # gMarkList->CteRead(_CteFirst);
    LOOP vItem # gMarkList->CteRead(_CteNext,vItem);
    WHILE (vItem > 0) DO BEGIN
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);

      if (vMFile = 250) then begin
        RecRead(250, 0, _RecId, vMID);

        if (aSort = 1) then vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
        if (aSort = 2) then vSortKey # StrFmt(Art.Sachnummer, 20, _StrEnd);
        if (aSort = 3) then vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5) + StrFmt(Art.Nummer, 20, _StrEnd);
        if (aSort = 4) then vSortKey # cnvAI(Art.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7);
        if (aSort = 5) then vSortKey # StrFmt(Art.Stichwort, 20, _StrEnd);

        Sort_ItemAdd(vTree, vSortKey, 250, RecInfo(250, _RecId));
      end;
    END;

  end else begin

    // Selektionsquery
    vQ # '';
    Lib_Sel:QFloat(var vQ, 'Art.Bestand.Inventur','>',0.0);
    if (Sel.Art.von.ArtNr != '') or (Sel.Art.bis.ArtNr != 'zzz') then
      Lib_Sel:QVonBisA(var vQ, 'Art.Nummer', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr);
    if (Sel.Art.von.Stichwor != '') or (Sel.Art.bis.Stichwor != 'zzz') then
      Lib_Sel:QVonBisA(var vQ, 'Art.Stichwort', Sel.Art.von.Stichwor, Sel.Art.bis.Stichwor);
    if (Sel.Art.von.SachNr != '') or (Sel.Art.bis.SachNr != 'zzz') then
      Lib_Sel:QVonBisA(var vQ, 'Art.Sachnummer', Sel.Art.von.SachNr, Sel.Art.bis.SachNr);
    if (Sel.Art.von.Typ != '') then
      Lib_Sel:QAlpha(var vQ, 'Art.Typ', '=', Sel.Art.von.Typ);
    if (Sel.Art.von.ArtGr != 0) or (Sel.Art.bis.ArtGr != 9999) then
      Lib_Sel:QVonBisI(var vQ, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr);
    if (Sel.Art.von.WGr != 0) or (Sel.Art.bis.WGr != 9999) then
      Lib_Sel:QVonBisI(var vQ, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr);

    // Selektion starten...
    vSel # SelCreate(250, 1);
    vSel->SelDefQuery('', vQ);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);
    FOR Erx # RecRead(250, vSel, _recFirst); // Artikel loopen
    LOOP Erx # RecRead(250, vSel, _recNext);
    WHILE (Erx <= _rLocked) DO BEGIN
      if (aSort = 1) then vSortKey # StrFmt(Art.Nummer, 20, _StrEnd);
      if (aSort = 2) then vSortKey # StrFmt(Art.Sachnummer, 20, _StrEnd);
      if (aSort = 3) then vSortKey # cnvAI(Art.Artikelgruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 5) + StrFmt(Art.Nummer, 20, _StrEnd);
      if (aSort = 4) then vSortKey # cnvAI(Art.Warengruppe, _FmtNumNoGroup | _FmtNumLeadZero, 0, 7);
      if (aSort = 5) then vSortKey # StrFmt(Art.Stichwort, 20, _StrEnd);

      Sort_ItemAdd(vTree, vSortKey, 250, RecInfo(250, _RecId));
    END;

    SelClose(vSel);
    SelDelete(250, vSelName);
    vSel # 0;
  end;


  // Druckelemente generieren...
  g_Empty     # LF_NewLine('EMPTY');
  g_Sel1      # LF_NewLine('SEL1');
  g_Sel2      # LF_NewLine('SEL2');
  g_Sel3      # LF_NewLine('SEL3');
  g_Header    # LF_NewLine('HEADER');
  g_Artikel   # LF_NewLine('ARTIKEL');
  g_GesSum    # LF_NewLine('GESSUM');

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  // Liste starten
  LF_Init(y);    // Landscape


  FOR   vItem # Sort_ItemFirst(vTree)
  LOOP  vItem # Sort_ItemNext(vTree, vItem)
  WHILE (vItem <> 0) do begin

    // Datensatz holen
    RecRead(cnvIA(vItem -> spCustom), 0, 0, vItem -> spID);

    Erx # RecLink(252, 250, 4, _recFirst);   // Basischarge holen
    if(Erx > _rLocked) then
      RecBufClear(252);

    vOK # false;
    // Verfügbarkeits- oder bestandsabhängiger Ausdruck START
    if ("Sel.Art.-VerfügbarYN") or ("Sel.Art.+VerfügbarYN") or ("Sel.Art.OutOfSollYN") then begin
      if ("Sel.Art.-VerfügbarYN") and ("Art.C.Verfügbar" <= 0.00) then vOK # y;
      if ("Sel.Art.+VerfügbarYN") and ("Art.C.Verfügbar" >  0.00) then vOK # y;
      if ("Sel.Art.OutOfSollYN")  and ("Art.C.Verfügbar" <= "Art.Bestand.Min") then vOK # y;
      end
      // Verfügbarkeits- oder bestandsabhängiger Ausdruck endE
    else begin
      vOK # true;
    end;

    if (vOK) then begin
      LF_Print(g_Artikel);
    end;

  END;

  LF_Print(g_GesSum);

  // Löschen der Liste
  Sort_KillList(vTree);

  //ListTerm();
  LF_Term();

  // Druckelemente freigeben...
  LF_FreeLine(g_Header);
  LF_FreeLine(g_Sel1);
  LF_FreeLine(g_Sel2);
  LF_FreeLine(g_Sel3);
  LF_FreeLine(g_Empty);
  LF_FreeLine(g_Artikel);
  LF_FreeLine(g_GesSum);
end;

//========================================================================