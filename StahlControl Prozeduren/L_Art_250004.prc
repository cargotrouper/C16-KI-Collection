@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250004
//                    OHNE E_R_G
//  Info        Ausgabe der Artikelliste Lagerjournal
//
//
//  05.05.2004  AI  Erstellung der Prozedur
//  11.05.2005  TM  Anpassungen für Artikelliste
//  03.08.2005  TM  Neueinrichtung für FUTURETEST
//  *** Sortierschlüssel noch nicht optimal - siehe Zeile 131 ff ***
//  29.07.2008  DS  QUERY
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Artikel','L_Art_250004:AusSel');
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
      Write(1, Art.Nummer                                 ,n , 0);
      Write(2, Art.Typ                    ,n , 0);
      Write(3, ZahlI(Art.Warengruppe)                             ,n , _LF_INT);
      Write(4, ZahlI(Art.Artikelgruppe)                                   ,n , _LF_INT);
      Write(5, ZahlF(Art.C.Bestand,2) +  Art.MEH                ,n , 0);
      Write(6, ZahlF(Art.Dicke,2) + 'x' + ZahlF(Art.Breite,2) + 'x' + ZahlF("Art.Länge",2)                 ,n , 0);
      Write(7, ZahlF("Art.GewichtProStk",2)                   ,n , _LF_NUM);
      Write(8, ZahlF("Art.GewichtProm",2)               ,n , _LF_NUM);
      Write(9, ZahlF(Art.SpezGewicht,2)               ,n , _LF_NUM);
      EndLine();

      StartLine();
      EndLine();
    end;


    'Charge' : begin
      StartLine(_LF_Underline + _LF_Overline);
      Write(1, Art.C.Charge.Intern                    ,n , 0);
      Write(2, ZahlF(Art.C.Dicke,2)                   ,n , _LF_NUM);
      Write(3, 'x'                                    ,n , 0);
      Write(4, ZahlF(Art.C.Breite,2)                  ,n , _LF_NUM);
      Write(5, 'x'                                    ,n , 0);
      Write(6, ZahlF("Art.C.Länge",2)                   ,n , _LF_NUM);
      Write( 7, ZahlF(Art.C.Bestellt,2)               ,n , _LF_NUM);
      Write( 8, ZahlF(Art.C.Bestand,2)                ,n , _LF_NUM);
      Write( 9, ZahlF(Art.C.Reserviert,2)             ,n , _LF_NUM);
      Write(10, ZahlF(Art.C.OffeneAuf,2)              ,n , _LF_NUM);
      Write(11, ZahlF("Art.C.Verfügbar",2)              ,n , _LF_NUM);
      EndLine();

      StartLine();
      EndLine();
    end;

    'leerzeile' : begin
      StartLine();
      EndLine();
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
      Write(10, ZahlI(Sel.Art.von.WGr)                                   ,y , 0, 3.0);
      Write(11, ' bis: '                                                 ,n , 0);
      Write(12, ZahlI(Sel.Art.bis.WGr)                                   ,y , 0);
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
      Write(10, ZahlI(Sel.Art.von.ArtGr)                                 ,y , 0, 3.0);
      Write(11, ' bis: '                                                 ,n , 0);
      Write(12, ZahlI(Sel.Art.bis.ArtGr)                                 ,y , 0);
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
  List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 15.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 15.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 25.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 50.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 40.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 40.0;
  List_Spacing[10]  # List_Spacing[ 9] + 40.0;
  List_Spacing[11]  # List_Spacing[10] + 30.0;
 /* List_Spacing[12]  # List_Spacing[11] + 5.0;
  List_Spacing[13]  # List_Spacing[12] + 5.0; */




  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'ArtNr'                                 ,n , 0);
  Write(2,  'Type'                                  ,n , 0);
  Write(3,  'Wgr'                                   ,n , 0);
  Write(4,  'Agr.'                                  ,n , 0);
  Write(5,  'Bestand'                               ,n , 0);
  Write(6,  'Abmessungen (DxBxL)'                   ,n , 0);
  Write(7,  'Gewicht /Stk'                          ,n , 0);
  Write(8,  'Gewicht /m'                            ,n , 0);
  Write(9,  'spez. Gewicht'                         ,n , 0);
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
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vFlag2      : int;        // Datensatzlese option 2. Schleife

  vSelName    : alpha;
  vMFile,vMID : int;
  vItem       : int;
  vKey        : int;
  vVerfuegbar : float;
  vFolgend    : logic;
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
    //vSelName # Sel_Build(vSel, 250, 'LST.250004',n,vKey);

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
    //vSelName # Sel_Build(vSel, 250, 'LST.250004',y,vKey);
  end;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y); // KEIN Landscape


  vFlag # _RecFirst;
  vFolgend # N;
  WHILE (RecRead(250,vSel,vFlag) <= _rLocked ) DO BEGIN // alle Artikel durchlaufen

    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if "Art.ChargenführungYN" then begin // nur Artikel mit Chargenführung

      RecBufClear(252);
      Art.C.ArtikelNr   # Art.Nummer;
      if (Art.Nummer<>'') then Art_Data:ReadCharge();
      vVerfuegbar # "Art.C.Verfügbar";

      // Artikel ausgeben
      If (("Sel.Art.-VerfügbarYN") or ("Sel.Art.+VerfügbarYN") or ("Sel.Art.OutOfSollYN")) then begin
        If (("Sel.Art.-VerfügbarYN") and (vVerfuegbar <= 0.00)) then Print('Artikel');        // Artikel drucken
        If (("Sel.Art.+VerfügbarYN") and (vVerfuegbar >  0.00)) then Print('Artikel');        // Artikel drucken
        If (("Sel.Art.OutOfSollYN")  and (vVerfuegbar <= "Art.Bestand.Min")) then Print('Artikel');        // Artikel drucken
      End
      Else begin
        If vFolgend then print('leerzeile'); // Leerzeile zwischen Artikeln
        Print('Artikel');        // Artikel drucken
        vFolgend # Y;
      End;
      RecBufClear(252);
      RecLink(252,250,4,_RecFirst);

      vFlag2 # _recNext;
      WHILE (RecLink(252,250,4,vFlag2) <= _rLocked) DO BEGIN // alle zugehörigen Chargen durchlaufen

        If ((Art.C.Anschriftnr = 0) and (Art.C.Lagerplatz = '')) then begin // nur Chargen ohne Lagerort/-platz beachten

          // Charge ausgeben
          If (("Sel.Art.-VerfügbarYN") or ("Sel.Art.+VerfügbarYN") or ("Sel.Art.OutOfSollYN")) then begin // Verfügbarkeitsabhängiger Ausdruck
            If (("Sel.Art.-VerfügbarYN") and (vVerfuegbar <= 0.00)) then Print('Charge');    // Charge drucken
            If (("Sel.Art.+VerfügbarYN") and (vVerfuegbar >  0.00)) then Print('Charge');    // Charge drucken
            If (("Sel.Art.OutOfSollYN")  and (vVerfuegbar <= "Art.Bestand.Min")) then Print('Charge');    // Charge drucken
          End

        Else Print('Charge');    // Charge drucken

        End; // nur Chargen ohne Lagerort/-platz beachten

      END; // alle zugehörigen Chargen durchlaufen

  End; // nur Artikel mit Chargenführung

END; // alle Artikel durchlaufen

ListTerm();

SelClose(vSel);
vSel # 0;
SelDelete(250,vSelName);

end;

//========================================================================