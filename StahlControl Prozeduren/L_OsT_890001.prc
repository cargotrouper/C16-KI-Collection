@A+
//===== Business-Control ==================================================
//
//  Prozedur    L_OsT_890001
//                    OHNE E_R_G
//  Info        Onlinestatistik ausgeben
//
//
//  13.08.2004  AI  Erstellung der Prozedur
//
//  Subprozeduren
//    SUB EvtFocusInit(aEvt : event; aFocusObject : int) : logic
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List
declare StartList(aSort : int; aSortName : alpha);

//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vDat : date;
end;
begin
  vDat # today;
  Sel.Von.Jahr # vDat->vpYear;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.890001','L_OsT_890001:AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;


//========================================================================
//  FocusInit
//            Fokus auf Objekt neu gesetzt
//========================================================================
sub EvtFocusInit (
  aEvt                  : event;        // Ereignis
  aFocusObject          : int           // vorheriges Objekt
) : logic
begin

  if (gMDI<>w_Mdi) then  gMDI # w_MDI;  // MDIBUGFIX 03.06.2014

  if (Sel.Adr.von.KdNr<>0) then begin
    Lib_GuiCom:Disable($edArtikel);
    Lib_GuiCom:Disable($edVertreter);
    Lib_GuiCom:Disable($edVerband);
    Lib_GuiCom:Disable($edWgr);
    Lib_GuiCom:Disable($edAgr);
    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($bt.Vertreter);
    Lib_GuiCom:Disable($bt.Verband);
    Lib_GuiCom:Disable($bt.Wgr);
    Lib_GuiCom:Disable($bt.Agr);
    end
  else if (Sel.Adr.von.Vertret<>0) then begin
    Lib_GuiCom:Disable($edKunde);
    Lib_GuiCom:Disable($edArtikel);
    Lib_GuiCom:Disable($edVerband);
    Lib_GuiCom:Disable($edWgr);
    Lib_GuiCom:Disable($edAgr);
    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($bt.Kunde);
    Lib_GuiCom:Disable($bt.Verband);
    Lib_GuiCom:Disable($bt.Wgr);
    Lib_GuiCom:Disable($bt.Agr);
    end
  else if (Sel.Adr.von.Verband<>0) then begin
    Lib_GuiCom:Disable($edKunde);
    Lib_GuiCom:Disable($edArtikel);
    Lib_GuiCom:Disable($edVertreter);
    Lib_GuiCom:Disable($edWgr);
    Lib_GuiCom:Disable($edAgr);
    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($bt.Vertreter);
    Lib_GuiCom:Disable($bt.Kunde);
    Lib_GuiCom:Disable($bt.Wgr);
    Lib_GuiCom:Disable($bt.Agr);
    end
  else if (Sel.Art.von.ArtNr<>'') then begin
    Lib_GuiCom:Disable($edKunde);
    Lib_GuiCom:Disable($edVertreter);
    Lib_GuiCom:Disable($edVerband);
    Lib_GuiCom:Disable($edWgr);
    Lib_GuiCom:Disable($edAgr);
    Lib_GuiCom:Disable($bt.Kunde);
    Lib_GuiCom:Disable($bt.Vertreter);
    Lib_GuiCom:Disable($bt.Verband);
    Lib_GuiCom:Disable($bt.Wgr);
    Lib_GuiCom:Disable($bt.Agr);
    end
  else if (Sel.Art.von.Wgr<>0) then begin
    Lib_GuiCom:Disable($edKunde);
    Lib_GuiCom:Disable($edVertreter);
    Lib_GuiCom:Disable($edVerband);
    Lib_GuiCom:Disable($edArtikel);
    Lib_GuiCom:Disable($edAgr);
    Lib_GuiCom:Disable($bt.Kunde);
    Lib_GuiCom:Disable($bt.Vertreter);
    Lib_GuiCom:Disable($bt.Verband);
    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($bt.Agr);
    end
  else if (Sel.Art.von.ArtGr<>0) then begin
    Lib_GuiCom:Disable($edKunde);
    Lib_GuiCom:Disable($edVertreter);
    Lib_GuiCom:Disable($edVerband);
    Lib_GuiCom:Disable($edWgr);
    Lib_GuiCom:Disable($edArtikel);
    Lib_GuiCom:Disable($bt.Artikel);
    Lib_GuiCom:Disable($bt.Vertreter);
    Lib_GuiCom:Disable($bt.Verband);
    Lib_GuiCom:Disable($bt.Wgr);
    Lib_GuiCom:Disable($bt.Kunde);
    end
  else begin
    Lib_GuiCom:Enable($edKunde);
    Lib_GuiCom:Enable($edArtikel);
    Lib_GuiCom:Enable($edVertreter);
    Lib_GuiCom:Enable($edVerband);
    Lib_GuiCom:Enable($edWgr);
    Lib_GuiCom:Enable($edAgr);
    Lib_GuiCom:Enable($bt.Kunde);
    Lib_GuiCom:Enable($bt.Artikel);
    Lib_GuiCom:Enable($bt.Vertreter);
    Lib_GuiCom:Enable($bt.Verband);
    Lib_GuiCom:Enable($bt.Wgr);
    Lib_GuiCom:ENable($bt.Agr);
  end;

  if (aEvt:Obj->WinInfo(_WinType)<>_WinTypeButton) then begin
    if (aEvt:obj->wpReadonly) then $Bt.OK->winfocusset();
  end;
  Sel_Main:EvtFocusInit(aEvt,aFocusObject);
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
/**
  gSelected # 0;
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Auftragsnummer');
  vHdl2->WinLstDatLineAdd('Kundenstichwort');
  vHdl2->WinLstDatLineAdd('Wunschtermin');
  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
**/
  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin



  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # 15.0;
  List_Spacing[ 3]  # 80.0;
  List_Spacing[ 4]  #124.0;
  List_Spacing[ 5]  #190.0;
  List_Spacing[ 6]  #256.0;
  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Monat'                  ,n , 0);
  Write(2, 'Jahr       ' + ZahlI(Gv.Int.18) +                   '                                  Umsatz              Rohgewinn'      ,n , 0);
  Write(3, 'vergleich                                           ' + ZahlI(Gv.Int.19) +'                  ' +  ZahlI(Gv.Int.20)  ,n , 0);
  Write(4, 'Jahr       ' + ZahlI(Gv.Int.19) +                   '                                  Umsatz              Rohgewinn'      ,n , 0);
  Write(5, 'Jahr       ' + ZahlI(Gv.Int.20) +                   '                                  Umsatz              Rohgewinn'      ,n , 0);
  EndLine();
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # 15.0;
      List_Spacing[ 3]  # 36.0;
      List_Spacing[ 4]  # 58.0;
      List_Spacing[ 5]  # 80.0;
      List_Spacing[ 6]  #102.0;
      List_Spacing[ 7]  #124.0;
      List_Spacing[ 8]  #146.0;
      List_Spacing[ 9]  #168.0;
      List_Spacing[10]  #190.0;
      List_Spacing[11]  #212.0;
      List_Spacing[12]  #234.0;
      List_Spacing[13]  #256.0;


end;


//========================================================================
//  SeitenFuss
//
//========================================================================
sub SeitenFuss(aSeite : int);
begin
end;


//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'Posten' : begin

       StartLine();
       Write(1, GV.Alpha.19                       ,n , 0);
       Write(2, ZahlF(GetSum(1),2)                               ,y , 0, 2.0);
       Write(3, ZahlF(GetSum(2),2)                ,y , 0, 2.0);
       Write(4, ZahlF(GetSum(3),2)+' %'                               ,y , 0, 2.0);
       Write(5, ZahlF(GetSum(10),2)+' %'                ,y , 0, 2.0);
       Write(6, ZahlF(GetSum(11),2)+' %'                               ,y , 0, 2.0);
       Write(7, ZahlF(GetSum(4),2)           ,n , 0, 2.0);
       Write(8, ZahlF(GetSum(5),2)                               ,y , 0, 2.0);
       Write(9, ZahlF(GetSum(6),2)+' %'          ,y , 0, 2.0);
       Write(10,ZahlF(GetSum(7),2)                               ,y , 0, 2.0);
       Write(11, ZahlF(GetSum(8),2)         ,y , 0, 2.0);
       Write(12, ZahlF(GetSum(9),2)+' %'               ,y , 0, 2.0);


/*       Write(21,                ,n , 0);
       Write(22, '|'                              ,n , 0);
       Write(23,           ,n , 0);*/
       EndLine();
    end;

    'Trennzeile' : begin
      StartLine();
      EndLine();
    end;


  end; // CASE
end;


//========================================================================
//  StartList
//
//========================================================================
sub StartList(aSort : int; aSortName : alpha);
local begin
  vSelName  : alpha;
  vSel      : int;
  vFlag     : int;

  vTyp      : alpha;
  vJahr     : int;
  vMonat    : int;
  vWert     : float[20];
  vQSum     : float[20];
  vESum     : float[20];
  vI        : int
end;
begin

  vTyp # 'UNTERNEHMEN';
  aSortName # 'Unternehmen';
  if (Sel.Adr.von.KdNr<>0) then begin
    Adr.Kundennr # Sel.Adr.Von.KdNr;
    RecRead(100,2,0);
    vTyp # 'KU:'+Cnvai(Adr.Kundennr);
    aSortname # 'Kunde '+Adr.Stichwort;
  end;
  if (Sel.Adr.von.Vertret<>0) then begin
    Ver.Nummer # Sel.Adr.Von.Vertret;
    RecRead(110,1,0);
    vTyp # 'VERT:'+Cnvai(Ver.Nummer);
    aSortname # 'Vertreter '+Ver.Stichwort;
  end;
  if (Sel.Adr.von.Verband<>0) then begin
    Ver.Nummer # Sel.Adr.Von.Verband;
    RecRead(110,1,0);
    vTyp # 'VERB:'+Cnvai(Ver.Nummer);
    aSortname # 'Verband '+Ver.Stichwort;
  end;
  if (Sel.Art.von.ArtNr<>'') then begin
    vTyp # 'ART:'+StrCnv(Sel.Art.Von.ArtNr,_StrUpper);
    aSortname # 'Artikel '+Sel.Art.von.ArtNr;
  end;
  if (Sel.Art.von.Wgr<>0) then begin
    Wgr.Nummer # Sel.Art.Von.Wgr;
    RecRead(819,1,0);
    vTyp # 'WGR:'+Cnvai(Wgr.Nummer);
    aSortname # 'Warengrp. '+Wgr.Bezeichnung.L1;
  end;
  if (Sel.Art.von.ArtGr<>0) then begin
    Agr.Nummer # Sel.Art.Von.ArtGr;
    RecRead(826,1,0);
    vTyp # 'WGR:'+Cnvai(Agr.Nummer);
    aSortname # 'Art.Grp. '+Agr.Bezeichnung.L1;
  end;

  vJahr     # Sel.Von.Jahr;
  Gv.Int.01 # vJahr;
  Gv.Int.02 # vJahr - 1;
  Gv.Int.03 # vJahr - 2;
  Gv.Alpha.10 # 'Statistik:'+aSortName;

  ListInit(y); // KEIN Landscape

  FOR vMonat # 1 loop Inc(vMOnat) while (vMonat<13) do begin
    case vMonat of
      1 : Gv.Alpha.01 # 'Jan.';
      2 : Gv.Alpha.01 # 'Feb.';
      3 : Gv.Alpha.01 # 'März';
      4 : Gv.Alpha.01 # 'Apr.';
      5 : Gv.Alpha.01 # 'Mai ';
      6 : Gv.Alpha.01 # 'Juni';
      7 : Gv.Alpha.01 # 'Juli';
      8 : Gv.Alpha.01 # 'Aug.';
      9 : Gv.Alpha.01 # 'Sep.';
      10 : Gv.Alpha.01 # 'Okt.';
      11 : Gv.Alpha.01 # 'Nov.';
      12 : Gv.Alpha.01 # 'Dez.';
    end;


    // Werte zurücksetzen
    FOR vI # 1 loop inc(vI) while (vI<12) do
      vWert[vI] # 0.0;

    // Werte holen
    if (OsT_Data:Hole(vTyp,vMonat,vJahr)) then begin
      vWert[1] # Ost.VK.Wert;
      vWert[2] # Ost.DeckBeitrag1;
    end;
    if (OsT_Data:Hole(vTyp,vMonat,vJahr-1)) then begin
      vWert[4] # Ost.VK.Wert;
      vWert[5] # Ost.DeckBeitrag1;
    end;
    if (OsT_Data:Hole(vTyp,vMonat,vJahr-2)) then begin
      vWert[7] # Ost.VK.Wert;
      vWert[8] # Ost.DeckBeitrag1;
    end;

    vWert[1] # 555.00;
    vWert[2] # 55.00*cnvfi(vMonat);
    vWert[4] # 77.00*cnvfi(vMonat);
    vWert[5] # 33.00*cnvfi(vMonat);

    // Monat ausgeben
    vWert[3] # Lib_Berechnungen:Prozent(vWert[2],vWert[1]);
    vWert[6] # Lib_Berechnungen:Prozent(vWert[5],vWert[4]);
    vWert[9] # Lib_Berechnungen:Prozent(vWert[8],vWert[7]);
    vWert[10] # Lib_Berechnungen:Prozent(vWert[1],vWert[4]);
    vWert[11] # Lib_Berechnungen:Prozent(vWert[1],vWert[7]);
    FOR vI # 1 loop inc(vI) while (vI<12) do
      AddSum(vI,vWert[vI])


      print('Posten');

    // Summieren
    FOR vI # 1 loop inc(vI) while (vI<12) do begin
      vQSum[vI] # vQSum[vI] + vWert[vI];
      vESum[vI] # vESum[vI] + vWert[vI];
    END;

    // Quartalssummen drucken
    if (vMonat%3 = 0) then begin
      print('Trennzeile');
      vQSum[3] # Lib_Berechnungen:Prozent(vQSum[2],vQSum[1]);
      vQSum[6] # Lib_Berechnungen:Prozent(vQSum[5],vQSum[4]);
      vQSum[9] # Lib_Berechnungen:Prozent(vQSum[8],vQSum[7]);
      vQSum[10] # Lib_Berechnungen:Prozent(vQSum[1],vQSum[4]);
      vQSum[11] # Lib_Berechnungen:Prozent(vQSum[1],vQSum[7]);
      FOR vI # 1 loop inc(vI) while (vI<12) do
        AddSum(vI,vQSum[vI])
      Gv.ALpha.01 # 'Q '+ANum(Cnvfi(vMonat) / 3.0, 0);

      print('Posten');
      FOR vI # 1 loop inc(vI) while (vI<12) do
        vQSum[vI] # 0.0;

      print('Trennzeile');
    end;

  END;

  // Gesamtsumme drucken
  vESum[3] # Lib_Berechnungen:Prozent(vESum[2],vESum[1]);
  vESum[6] # Lib_Berechnungen:Prozent(vESum[5],vESum[4]);
  vESum[9] # Lib_Berechnungen:Prozent(vESum[8],vESum[7]);
  vESum[10] # Lib_Berechnungen:Prozent(vESum[1],vESum[4]);
  vESum[11] # Lib_Berechnungen:Prozent(vESum[1],vESum[7]);
  Gv.ALpha.01 # 'Ges.';
  FOR vI # 1 loop inc(vI) while (vI<12) do
    AddSum(vI,vESum[vI])
  print('Posten');

  ListTerm();

end;

//========================================================================