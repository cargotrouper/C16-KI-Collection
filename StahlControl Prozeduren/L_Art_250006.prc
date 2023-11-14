@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250006
//                    OHNE E_R_G
//  Info        Artikel VK-Preisliste
//
//
//  05.03.2006  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List
declare StartList(aSort : int; aSortName : alpha);

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
  "Sel.Art.-VerfügbarYN"  # N;
  "Sel.Art.+VerfügbarYN"  # N;
  Sel.Art.OutOfSollYN     # N;

  Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Artikel','L_Art_250006:AusSel');
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
  vHdl2->WinLstDatLineAdd('Artikelnummer');
  vHdl2->WinLstDatLineAdd('Sachnummer');
  vHdl2->WinLstDatLineAdd('Warengruppe');
  vHdl2->WinLstDatLineAdd('Artikelgruppe');
  vHdl2->WinLstDatLineAdd('Stichwort');
  vHdl2->wpcurrentint#1;
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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'Artikel' : begin
      StartLine();
      Write(1, Art.Nummer                                                               ,n , 0);
      EndLine();
    end;

    'Preis' : begin

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 40.0;
      // List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 80.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 10.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 5.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 10.0;
      List_Spacing[10]  # List_Spacing[ 9] + 10.0;
      List_Spacing[11]  # List_Spacing[10] + 30.0;

      StartLine();
      Write(2, GV.Alpha.01                                                              ,n , 0);
      if (Art.P.Datum.Von <> 0.0.0) and (Art.P.Datum.Bis <> 0.0.0) then

      //Write(2, ZahlF(Art.P.abMenge,2)                                             ,y , _LF_NUM);
      Write(2,'',n,0);

      Write(3, ZahlF(Art.P.abMenge,2) + Art.P.MEH                                 ,y , 0);
      Write(5, ZahlF(Art.P.PreisW1,2)                                             ,y , _LF_NUM);
      Write(6, "Set.Hauswährung.Kurz" + ' /'                                            ,n , 0);
      Write(7, ZahlI(Art.P.PEH)                                                   ,y , _LF_INT);
      Write(8, Art.P.MEH                                                                ,n , 0);
      Write(10,DatS(Art.P.Datum.Bis)                                              ,n , 0);
      EndLine();

      // StartLine();
      // EndLine();
    end;


    'Selektierung' : begin

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


      StartLine();
      Write( 1, 'Artikelnummer'                                          ,n , 0);
      Write( 2, ' : '                                                    ,n , 0);
      Write( 3, ' von: '                                                 ,n , 0);
      Write( 4, Sel.Art.von.ArtNr                                        ,n , 0);
      Write( 5, ' bis: '                                                 ,n , 0);
      Write( 6, Sel.Art.bis.ArtNr                                        ,n , 0);
      Write( 7, 'Artikeltyp'                                             ,n , 0);
      Write( 8, ' : '                                                    ,n , 0);
      // Write( 9, ' von: '                                                 ,n , 0);
      Write(10, Sel.Art.von.Typ                                          ,y , 0, 3.0);
      //Write(11, ' bis: '                                                 ,n , 0);
      //Write(12, Sel.Art.bis.Typ                                          ,y , 0);
      EndLine();

      StartLine();
      Write( 1, 'Stichwort'                                              ,n , 0);
      Write( 2, ' : '                                                    ,n , 0);
      Write( 3, ' von: '                                                 ,n , 0);
      Write( 4, Sel.Art.von.Stichwor                                     ,n , 0);
      Write( 5, ' bis: '                                                 ,n , 0);
      Write( 6, Sel.Art.bis.Stichwor                                     ,n , 0);
      Write( 7, 'Warengruppe'                                            ,n , 0);
      Write( 8, ' : '                                                    ,n , 0);
      Write( 9, ' von: '                                                 ,n , 0);
      Write(10, ZahlI(Sel.Art.von.WGr)                                   ,y , _LF_Int, 3.0);
      Write(11, ' bis: '                                                 ,n , 0);
      Write(12, ZahlI(Sel.Art.bis.WGr)                                   ,y , _LF_Int);
      EndLine();

      StartLine();
      Write( 1, 'Sachnummer'                                             ,n , 0);
      Write( 2, ' : '                                                    ,n , 0);
      Write( 3, ' von: '                                                 ,n , 0);
      Write( 4, Sel.Art.von.SachNr                                       ,n , 0);
      Write( 5, ' bis: '                                                 ,n , 0);
      Write( 6, Sel.Art.bis.SachNr                                       ,n , 0);
      Write( 7, 'Artikelgruppe'                                          ,n , 0);
      Write( 8, ' : '                                                    ,n , 0);
      Write( 9, ' von: '                                                 ,n , 0);
      Write(10, ZahlI(Sel.Art.von.ArtGr)                                 ,y , _LF_Int, 3.0);
      Write(11, ' bis: '                                                 ,n , 0);
      Write(12, ZahlI(Sel.Art.bis.ArtGr)                                 ,y , _LF_Int);
      EndLine();

      StartLine();
      Endline();

    end;

    'Leerzeile' : begin
      StartLine();
      EndLine();
    end;
  end; // CASE
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift
  StartLine();
  EndLine();
  if (aSeite=1) then begin
    StartLine();
    EndLine();

  end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #100.0;
      List_Spacing[ 3]  #200.0;

      Print('Selektierung');        // Selektierung drucken

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 40.0;
      // List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 80.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 10.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
      List_Spacing[ 7]  # List_Spacing[ 6] + 10.0;
      List_Spacing[ 8]  # List_Spacing[ 7] + 5.0;
      List_Spacing[ 9]  # List_Spacing[ 8] + 10.0;
      List_Spacing[10]  # List_Spacing[ 9] + 10.0;
      List_Spacing[11]  # List_Spacing[10] + 30.0;
      /*List_Spacing[11]  # List_Spacing[10] + 30.0;
      List_Spacing[12]  # List_Spacing[11] + 9.0;
      List_Spacing[13]  # List_Spacing[12] + 30.0;*/




  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Art Nr'                                ,n , 0);
  Write(2,  'Preistype'                             ,n , 0);
  Write(3,  'ab Menge'                              ,y , 0);
  Write(5,  'Preis pro'                             ,y , 0);
  Write(10,  'Gültigkeit bis'                    ,n , 0);
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
  vMFIle,vMID : int;
  vOk         : logic;
  vQ          : alpha(4000);
end;
begin

  // Sortierung setzen
  if (aSort=1) then vKey # 1; // Artikelnummer
  if (aSort=2) then vKey # 3; // Sachnummer
  if (aSort=3) then vKey # 10; // Wgr
  if (aSort=4) then vKey # 11; // Agr
  if (aSort=5) then vKey # 6; // Stichwort

  If (Sel.Art.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate( 250, vKey );
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(250,_SelLock,vSelName);   // Selektion laden

    //vSelName # Sel_Build(vSel, 250, 'LST.250006',n,vKey);

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 250) then begin
        RecRead(250,0,_RecId,vMID);
        SelRecInsert(vSel,250);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;
  end else begin

    // Selektionsquery
    vQ # '';
    if ( Sel.Art.von.ArtNr != '' ) or ( Sel.Art.bis.ArtNr != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Art.Nummer', Sel.Art.von.ArtNr, Sel.Art.bis.ArtNr );
    if ( Sel.Art.von.Stichwor != '' ) or ( Sel.Art.bis.Stichwor != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Art.Stichwort', Sel.Art.von.Stichwor, Sel.Art.bis.Stichwor );
    if ( Sel.Art.von.SachNr != '' ) or ( Sel.Art.bis.SachNr != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Art.Sachnummer', Sel.Art.von.SachNr, Sel.Art.bis.SachNr );
    if ( Sel.Art.von.Typ != '' ) then
      Lib_Sel:QAlpha( var vQ, 'Art.Typ', '=', Sel.Art.von.Typ );
    if ( Sel.Art.von.ArtGr != 0 ) or ( Sel.Art.bis.ArtGr != 9999 ) then
      Lib_Sel:QVonBisI( var vQ, 'Art.Artikelgruppe', Sel.Art.von.ArtGr, Sel.Art.bis.ArtGr );
    if ( Sel.Art.von.WGr != 0 ) or ( Sel.Art.bis.WGr != 9999 ) then
      Lib_Sel:QVonBisI( var vQ, 'Art.Warengruppe', Sel.Art.von.WGr, Sel.Art.bis.WGr );

    // Selektion starten...
    vSel # SelCreate( 250, vKey );
    vSel->SelDefQuery( '', vQ );
    vSelName # Lib_Sel:SaveRun( var vSel, 0);
    //vSelName # Sel_Build(vSel, 250, 'LST.250006',y,vKey);
  end;
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(y); // KEIN Landscape

  vFlag # _RecFirst;
  WHILE (RecRead(250,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecBufClear(252);
    RecLink(252,250,4,_RecFirst);

    vOk # n;
    // Verfügbarkeits- oder bestandsabhängiger Ausdruck START
    If ("Sel.Art.-VerfügbarYN") or ("Sel.Art.+VerfügbarYN") or ("Sel.Art.OutOfSollYN") then begin
      If ("Sel.Art.-VerfügbarYN") and ("Art.C.Verfügbar" <= 0.00) then vOk # y;
      If ("Sel.Art.+VerfügbarYN") and ("Art.C.Verfügbar" >  0.00) then vOk # y;
      If ("Sel.Art.OutOfSollYN")  and ("Art.C.Verfügbar" <= "Art.Bestand.Min") then vOk # y;
      End
      // Verfügbarkeits- oder bestandsabhängiger Ausdruck ENDE
    Else begin
      vOk # y;
    end;

    if (vOK) then begin
      Print('Artikel');        // Artikel drucken


      Erx # RecLink(254,250,6,_recFirst); // Preise loopen
      WHILE (Erx<=_rLocked) do begin
        if (Art.P.PreisTyp='Ø-VK') or
          (Art.P.PreisTyp='VK') or
          (Art.P.PreisTyp='L-VK') then begin
          vOk # n;
          if (Art.P.PreisTyp='Ø-VK') then Art.P.Preistyp # StrChar(157,1)+'-VK';
          Gv.Alpha.01 # Art.P.PreisTyp+' '+Art.P.AdrStichwort;
          Print('Preis');        // Preis drucken

        end;
        Erx # RecLink(254,250,6,_recNext);
      END;

      // if (vOk) then begin
      //  Print('Leerzeile');        // Leerzeile drucken
      // end;

    end

  END;

  ListTerm();

  SelClose(vSel);
  vSel # 0;
  SelDelete(250,vSelName);


end;

//========================================================================