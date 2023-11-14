@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Vbk_550001
//                  OHNE E_R_G
//  Info        Lieferanten Hitliste pro Jahr
//
//
//
//  19.05.2009  AI  Erstellung der Prozedur
//  2022-06-28  AH  ERX
//
//  Subprozeduren
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
@I:Def_aktionen

define begin
  cS1   : 18.0;
  cS2   : 15.0;
  Proz(a,b) : Lib_Berechnungen:Prozent(a,b)
end

global Struct_Werte begin
  s_LfNr  : int;
  s_GewLJ : float;
  s_UmsLJ : float;
  s_GewVJ : float;
  s_UmsVJ : float;
end;

local begin
  gGewLJ  : float;
  gUmsLJ  : float;
  gGewVJ  : float;
  gUmsVJ  : float;

  gMAX    : int;
  gAnz    : int;

  gRGewLJ : float;
  gRUmsLJ : float;
  gREKLJ  : float;
  gRDBLJ  : float;
  gRGewVJ : float;
  gRUmsVJ : float;
  gREKVJ  : float;
  gRDBVJ  : float;

end;

declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort       : int;
  vSortName   : alpha;
  vHdl,vHdl2  : int;
end;
begin

  // OHNE Lieferanten Gutschriften+Belastugen
  Sel.Fin.LiefGutBelYN # false;

  // Jahr Abfragen...
  if (Dlg_Standard:Anzahl(Translate('Jahr'), var GV.Int.01, dateyear(today)+1900)=false ) then RETURN;
  if (Gv.Int.01<1900) or (GV.Int.01>2099) then RETURN;

  if (Dlg_Standard:Anzahl(Translate('max. Anzahl'), var gMAX, 30)=false ) then RETURN;
  if (gMAX<0) then RETURN;

  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  // vHdl2->WinLstDatLineAdd('Deckungsbeitrag');
  vHdl2->WinLstDatLineAdd('Tonne');
  vHdl2->WinLstDatLineAdd('Umsatz');
  vHdl2->wpcurrentint # 3;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end   // keine Sortierung ausgewählt? ->  ENDE
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren

end;


//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  Erx         : int;
  vProzLJ     : float;
  vDurchLJ    : float;
  vProzVJ     : float;
  vDurchVJ    : float;

  vGew      : float;
  vUms      : float;
  vProz     : float;
  vDurch    : float;
end;
begin

  case aName of

    'Pos' : begin
     Adr.LieferantenNr # s_LfNr;
      Erx # RecRead(100,3,0);     // Kunde holen
      if (Erx>_rMultiKey) then RecBufClear(100);


      // fehlende Werte errechnen...
      vProzLJ # Proz(s_UmsLJ, gUmsLJ);
      vProzVJ # Proz(s_UmsVJ, gUmsVJ);
      if (s_GewLJ<>0.0) then vDurchLJ # Rnd(s_UmsLJ / s_GewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (s_GewVJ<>0.0) then vDurchVJ # Rnd(s_UmsVJ / s_GewVJ,2) * 1000.0
      else vDurchVJ # 0.0;

      // Differenzen...
      vGew    # s_GewLJ   - s_GewVJ;
      vUms    # s_UmsLJ   - s_UmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;

      // kg in Tonne wandeln...
      s_GewLJ # Rnd(s_GewLJ / 1000.0, 1);
      s_GewVJ # Rnd(s_GewVJ / 1000.0, 1);
      vGew    # Rnd(vGew    / 1000.0, 1);
      s_UmsLJ # Rnd(s_UmsLJ / 1000.0, 1);
      s_UmsVJ # Rnd(s_UmsVJ / 1000.0, 1);
      vUms    # Rnd(vUms    / 1000.0, 1);


      StartLine();
      Write(1,  Adr.Stichwort                             ,n , 0);

      Write(2,  ZahlF(s_GewLJ,1)                          ,y , _LF_Num);
      Write(3,  ZahlF(s_UmsLJ,1)                          ,y , _LF_Wae);
      Write(4,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);
      Write(5,  ZahlF(vDurchLJ,2)                         ,y , _LF_Wae);
      Write(6,  ZahlF(s_GewVJ,1)                          ,y , _LF_Num);
      Write(7,  ZahlF(s_UmsVJ,1)                          ,y , _LF_Wae);
      Write(8,  ZahlF(vProzVJ,1)                          ,y , _LF_Num);
      Write(9,  ZahlF(vDurchVJ,2)                         ,y , _LF_Wae);
      Write(10, ZahlF(vGew,1)                             ,y , _LF_Num);
      Write(11, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(12, ZahlF(vProz,1)                            ,y , _LF_Num);
      Write(13, ZahlF(vDurch,2)                           ,y , _LF_Wae);
      EndLine();
    end;

    'Rest' : begin
      // fehlende Werte errechnen...
      vProzLJ # Proz(gRUmsLJ, gUmsLJ);
      vProzVJ # Proz(gRUmsVJ, gUmsVJ);
      if (gRGewLJ<>0.0) then vDurchLJ # Rnd(gRUmsLJ / gRGewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (gRGewVJ<>0.0) then vDurchVJ # Rnd(gRUmsVJ / gRGewVJ,2) * 1000.0
      else vDurchVJ # 0.0;
      //  vSpanLJ # Proz(gRDBLJ, gRUmsLJ);
      //  vSpanVJ # Proz(gRDBVJ, gRUmsVJ);

      // Differenzen...
      vGew    # gRGewLJ   - gRGewVJ;
      vUms    # gRUmsLJ   - gRUmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;
      //  vDB     # gRDBLJ - gRDBVJ;
      //  vSpan   # Proz(vSpanLJ, vSpanVJ) - 100.0;

      // kg in Tonne wandeln...
      gRGewLJ # Rnd(gRGewLJ / 1000.0, 1);
      gRGewVJ # Rnd(gRGewVJ / 1000.0, 1);
      vGew    # Rnd(vGew / 1000.0, 1);
      gRUmsLJ # Rnd(gRUmsLJ / 1000.0, 1);
      gRUmsVJ # Rnd(gRUmsVJ / 1000.0, 1);
      vUms    # Rnd(vUms / 1000.0, 1);
      gRDBLJ  # Rnd(gRDBLJ / 1000.0, 1);
      // gRDBVJ  # Rnd(gRDBVJ / 1000.0, 1);
      // vDB     # Rnd(vDB / 1000.0, 1);


      StartLine(_LF_Overline);
      Write(1, 'REST:'                                    ,y, 0);
      Write(2,  ZahlF(gRGewLJ,1)                           ,y , _LF_Num);
      Write(3,  ZahlF(gRUmsLJ,1)                           ,y , _LF_Wae);
      Write(4,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);
      Write(5 , ZahlF(vDurchLJ,2)                         ,y , _LF_Wae);

      Write(6,  ZahlF(gRGewVJ,1)                           ,y , _LF_Num);
      Write(7,  ZahlF(gRUmsVJ,1)                           ,y , _LF_Wae);
      Write(8, ZahlF(vProzVJ,1)                          ,y , _LF_Num);
      Write(9, ZahlF(vDurchVJ,2)                         ,y , _LF_Wae);

      Write(10, ZahlF(vGew,1)                             ,y , _LF_Num);
      Write(11, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(12, ZahlF(vProz,1)                            ,y , _LF_Num);
      Write(13, ZahlF(vDurch,2)                           ,y , _LF_Wae);

      EndLine();
     end; // Rest

    'GesamtSumme' : begin

      // fehlende Werte errechnen...
      vProzLJ # 100.0;
      vProzVJ # 100.0;
      if (gGewLJ<>0.0) then vDurchLJ # Rnd(gUmsLJ / gGewLJ,2) * 1000.0
      else vDurchLJ # 0.0;
      if (gGewVJ<>0.0) then vDurchVJ # Rnd(gUmsVJ / gGewVJ,2) * 1000.0
      else vDurchVJ # 0.0;

      // Differenzen...
      vGew    # gGewLJ   - gGewVJ;
      vUms    # gUmsLJ   - gUmsVJ;
      vProz   # vProzLJ   - vProzVJ;
      vDurch  # vDurchLJ  - vDurchVJ;

      // kg in Tonne wandeln...
      gGewLJ # Rnd(gGewLJ / 1000.0, 1);
      gGewVJ # Rnd(gGewVJ / 1000.0, 1);
      vGew   # Rnd(vGew   / 1000.0, 1);
      gUmsLJ # Rnd(gUmsLJ / 1000.0, 1);
      gUmsVJ # Rnd(gUmsVJ / 1000.0, 1);
      vUms   # Rnd(vUms   / 1000.0, 1);


      StartLine(_LF_Overline);
      Write(1, 'GESAMT SUMME:'                            ,y, 0);
      Write(2,  ZahlF(gGewLJ,1)                           ,y , _LF_Num);
      Write(3,  ZahlF(gUmsLJ,1)                           ,y , _LF_Wae);
      Write(4,  ZahlF(vProzLJ,1)                          ,y , _LF_Num);
      Write(5,  ZahlF(vDurchLJ,2)                         ,y , _LF_Wae);
      Write(6,  ZahlF(gGewVJ,1)                           ,y , _LF_Num);
      Write(7,  ZahlF(gUmsVJ,1)                           ,y , _LF_Wae);
      Write(8,  ZahlF(vProzVJ,1)                          ,y , _LF_Num);
      Write(9,  ZahlF(vDurchVJ,2)                         ,y , _LF_Wae);
      Write(10, ZahlF(vGew,1)                             ,y , _LF_Num);
      Write(11, ZahlF(vUms,1)                             ,y , _LF_Wae);
      Write(12, ZahlF(vProz,1)                            ,y , _LF_Num);
      Write(13, ZahlF(vDurch,2)                           ,y , _LF_Wae);
      EndLine();
     end; // Summe

  end; // CASE

end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();
  StartLine();
  EndLine();

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 27.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + cS1;
  List_Spacing[ 4]  # List_Spacing[ 3] + cS1;
  List_Spacing[ 5]  # List_Spacing[ 4] + cS2;
  List_Spacing[ 6]  # List_Spacing[ 5] + cS2;
  List_Spacing[ 7]  # List_Spacing[ 6] + cS1;
  List_Spacing[ 8]  # List_Spacing[ 7] + cS1;
  List_Spacing[ 9]  # List_Spacing[ 8] + cS2;
  List_Spacing[10]  # List_Spacing[ 9] + cS2;
  List_Spacing[11]  # List_Spacing[10] + cS1;
  List_Spacing[12]  # List_Spacing[11] + cS1;
  List_Spacing[13]  # List_Spacing[12] + cS2;
  List_Spacing[14]  # List_Spacing[13] + cS1;
  List_Spacing[15]  # List_Spacing[14] + cS2;

  List_Spacing[16]  # List_Spacing[15] + 20.0;
  List_Spacing[17]  # List_Spacing[16] + 20.0;

  List_FontSize # 8;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Lieferant'                                           ,n , 0);

  Write(2,  'Umsatz t '+AInt(Gv.Int.01)                       ,y , 0);
  Write(3,  'Umsatz '+"Set.Hauswährung.Kurz"+AInt(Gv.int.01)  ,y , 0);
  Write(4,  'Umsatz % '+AInt(Gv.int.01)                       ,y , 0);
  Write(5,  'Ø '+"Set.Hauswährung.Kurz"+' / t '+AInt(Gv.int.01),y , 0);
  Write(6,  'Absatz t '+AInt(Gv.Int.02)                       ,y , 0);
  Write(7,  'Umsatz '+"Set.Hauswährung.Kurz"+AInt(Gv.int.02)  ,y , 0);
  Write(8,  'Umsatz % '+AInt(Gv.int.02)                       ,y , 0);
  Write(9, 'Ø '+"Set.Hauswährung.Kurz"+' / t '+AInt(Gv.int.02),y , 0);
  Write(10, 'Absatz t Diff'                                   ,y , 0);
  Write(11, 'Umsatz '+"Set.Hauswährung.Kurz"+'Diff'           ,y , 0);
  Write(12, 'Umsatz % Diff'                                   ,y , 0);
  Write(13, 'Ø '+"Set.Hauswährung.Kurz"+' / t Diff'           ,y , 0);

  EndLine();
end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  MerkeDaten
//
//========================================================================
Sub MerkeDaten(aTree : int; aSort : int);
local begin
  vItem   : int;
end;
begin

  // Item für Baum anlegen...
  vItem # CteOpen(_CteItem);

  // Sortierung über EINDEUTIGEN Name
  // if (aSort=1) then
  //   vItem->spname # cnvaf(1000000000.0-s_DBLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_lfnr);
  if (aSort=1) then
    vItem->spname # cnvaf(1000000000.0-s_GewLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_lfnr);;
  if (aSort=2) then
    vItem->spname # cnvaf(1000000000.0-s_UmsLJ,_FmtNumNoGroup|_FmtNumLeadZero,0,2,15)+cnvai(s_lfnr);;

  // Handle der Structure im Item mekren...
  vItem->spid   # VarInfo(struct_Werte);

  // Item im Baum speicehrn...
  Cteinsert(aTree, vitem);
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
  vKey        : int;
  vTree       : int;
  vSortKey    : alpha;
  vItem       : int;
  vQ450       : alpha(4000);
  vLfNr       : int;
  vX          : float;

end;
begin

  Sel.Von.Datum # DateMake(1,1,GV.Int.01-1900);
  Sel.Bis.Datum # DateMake(31,12,GV.Int.01-1900);
  GV.Int.02 # GV.Int.01 - 1;
  Sel.Von.Datum2 # DateMake(1,1,GV.Int.02-1900);
  Sel.Bis.Datum2 # DateMake(31,12,GV.Int.02-1900);

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ450 # '';
  Lib_Sel:QVonBisD(var vQ450, 'Vbk.Rechnungsdatum',Sel.von.Datum ,Sel.bis.Datum);
  Lib_Sel:QVonBisD(var vQ450, 'Vbk.Rechnungsdatum',Sel.von.Datum2,Sel.bis.Datum2,'OR');

  // Selektion starten...
  vSel # SelCreate(550, 1);
  vSel->SelDefQuery('', vQ450);
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun(var vSel, 3);  // nach Kunde sortiert


  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  vTree # CteOpen(_CteTree);    // Rambaum anlegen

  Erx # RecRead(550,vSel,_recFirst);
  WHILE (Erx <= _rLocked) DO BEGIN // Material loopen

    if (Sel.Fin.LiefGutBelYN=false) then begin
      Erx # RecLink(555,550,6,_RecFirst);     // 1.Einkaufskontrolle holen
      if (Erx<=_rLocked) then begin

        Erx # RecLink(501,555,5,0);               // Auftrag holen
        if (Erx > _rLocked) then begin

          Erx # RecLink(511,555,6,0);             // Auftrag holen
          if (Erx > _rLocked) then RecBufClear(500)
          else RecbufCopy(511,501);
        end;
        if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then begin
          Erx # RecRead(550,vSel,_recNext);
          CYCLE;
        end;

      end;
    end;

    // Kundenwechsel?
    if (vLfNr<>Vbk.Lieferant) then begin
      if (vLfNr<>0) then MerkeDaten(vTree,aSort); // bisherige Structure im Baum speichern
      VarAllocate(Struct_Werte);            // neue Structure anlegen
      s_LfNr # Vbk.Lieferant;
      vLfNr  # Vbk.Lieferant;
    end;

    vX # 0.0;
    Erx # RecLink(551,550,1,_RecFirst);   // Erloeskonto holen
    WHILE(Erx <= _rLocked) DO BEGIN
      vX # vX + Vbk.K.BetragW1;     // EK summieren
      Erx # RecLink(551,550,1,_RecNext);
    END;

    // aktuelle sJahr?
    if (Vbk.Rechnungsdatum>=Sel.Von.Datum) then begin
      // s_EKLJ  # s_EKLJ + vX;
      s_UmsLJ # s_UmsLJ + Vbk.NettoW1;
      s_GewLJ # s_GewLJ + Vbk.Gewicht;

      gUmsLJ  # gUmsLJ + Vbk.NettoW1;
      gGewLJ  # gGewLJ + Vbk.Gewicht;
      end
    else begin
    // Vorjahr...
      // s_EKVJ  # s_EKVJ + vX;
      s_UmsVJ # s_UmsVJ + Vbk.NettoW1;
      s_GewVJ # s_GewVJ + Vbk.Gewicht;

      gUmsVJ  # gUmsVJ + Vbk.NettoW1;
      gGewVJ  # gGewVJ + Vbk.Gewicht;
    end;

    Erx # RecRead(550,vSel,_recNext);
  END;

  if (vLfNr<>0) then MerkeDaten(vTree,aSort); // bisherige Structure im Baum speichern

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(550, vSelName);


  // AUSGABE ---------------------------------------------------------------
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  gRGewLJ # gGewLJ;
  gRUmsLJ # gUmsLJ;
  // gREKLJ  # gEKLJ;
  // gRDBLJ  # gDBLJ;

  gRGewVJ # gGewVJ;
  gRUmsVJ # gUmsVJ;
  // gREKVJ  # gEKVJ;
  // gRDBVJ  # gDBVJ;

  // Tree durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    gAnz # gAnz + 1;

    // Structure holen...
    VarInstance(struct_werte, vItem->spID);

    if (gMAX=0) or (gAnz<=gMax) then begin
      gRGewLJ # gRGewLJ - s_GewLJ;
      gRUmsLJ # gRUmsLJ - s_UmsLJ;
      // gREKLJ  # gREKLJ - s_EKLJ;
      // gRDBLJ  # gRDBLJ - s_DBLJ;

      gRGewVJ # gRGewVJ - s_GewVJ;
      gRUmsVJ # gRUmsVJ - s_UmsVJ;
      // gREKVJ  # gREKVJ - s_EKVJ;
      // gRDBVJ  # gRDBVJ - s_DBVJ;
      PRINT('Pos');
    end;

    // Structure zerstören...
    VarFree(struct_werte);

  END;  // loop

  //Print('Summe');
  Print('Rest');
  Print('GesamtSumme');

  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;
//========================================================================