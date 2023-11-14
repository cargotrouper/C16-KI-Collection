@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250002
//                    OHNE E_R_G
//  Info        Selektierte Artikelwertliste
//
//
//  21.03.2006  AI  Erstellung der Prozedur
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
  Sel.Art.bis.SachNr      # 'zzz';
  Sel.Art.bis.Wgr         # 9999 ;
  Sel.Art.bis.ArtGr       # 9999;
  Sel.Art.bis.Stichwor    # 'zzz';
  "Sel.Art.-VerfügbarYN"  # N;
  "Sel.Art.+VerfügbarYN"  # N;
  Sel.Art.OutOfSollYN     # N;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.Artikel_C','L_Art_250002:AusSel');
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
      Write(1, Art.Nummer                                                    ,n , 0);
      Write(2, Art.Stichwort                                                 ,n , 0);
      Write(3, Art.Typ                                                       ,n , 0);
      Write(4, ZahlI(Art.Warengruppe)                                        ,y , _LF_INT);
      Write(5, ZahlI(Art.Artikelgruppe)                                      ,y , _LF_INT);
      Write(6, ZahlF(Art.P.PreisW1,2)+'/'+ZahlI(Art.P.PEH)+Art.P.MEH         ,y , 0);
      Write(7, ZahlF(Art.Bestand.Min,2)                                      ,y , _LF_NUM);
      Write(8, ZahlF(GV.Num.01,2)                                            ,y , _LF_NUM);
      Write(9,  ZahlF(Art.Bestand.Soll,2)                                    ,y , _LF_NUM);
      Write(10, ZahlF(GV.Num.02,2)                                           ,y , _LF_NUM);
      Write(11, ZahlF(Art.C.Bestand,2)                                       ,y , _LF_NUM);
      Write(12, ZahlF(GV.Num.03,2)                                           ,y , 0);
      EndLine();
     end;

    'Charge' : begin
      StartLine(_LF_Underline + _LF_Overline);
      Write(2,  Art.C.Charge.Intern                           ,n , 0);
      Write(3,  ZahlF(Art.C.Dicke,2) + 'x'                    ,n , 0);
      Write(4,  ZahlF(Art.C.Breite,2) + 'x'                   ,n , 0);
      Write(5,  ZahlF("Art.C.Länge",2)                          ,n , 0);
      Write(11, ZahlF(Art.C.Bestand,2)                        ,n , _LF_NUM);
      Write(12, ZahlF(GV.Num.03,2)                            ,n , _LF_NUM);
      EndLine();

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
    StartLine();
    EndLine();
  end;

      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  #100.0;
      List_Spacing[ 3]  #200.0;
      StartLine();
      Write(1, Prg.Key.Name                        ,n , 0);
      EndLine();
      StartLine();
      EndLine();
      StartLine();
      EndLine();

  Print('Selektierung');        // Selektierung drucken

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 10.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 10.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 15.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;
  List_Spacing[10]  # List_Spacing[ 9] + 25.0;
  List_Spacing[11]  # List_Spacing[10] + 25.0;
  List_Spacing[12]  # List_Spacing[11] + 25.0;
  List_Spacing[13]  # List_Spacing[12] + 25.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'ArtNr'                                 ,n , 0);
  Write(2,  'Stichwort'                             ,n , 0);
  Write(3,  'Typ'                                   ,n , 0);
  Write(4,  'Wgr'                                   ,y , 0);
  Write(5,  'ArtGr'                                 ,y , 0);
  Write(6,  'Ø-EK-Preis'                            ,y , 0);
  Write(7,  'Min Menge'                             ,y , 0);
  Write(8,  'Min Wert'                              ,y , 0);
  Write(9,  'Soll Menge'                            ,y , 0);
  Write(10, 'Soll Wert'                             ,y , 0);
  Write(11, 'Ist Bestand'                           ,y , 0);
  Write(12, 'Lager wert'                            ,y , 0);
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
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vQ          : alpha(4000);
end;
begin

  // Sortierung setzen
  if (aSort=1) then vKey # 1; // Artikelnummer
  if (aSort=2) then vKey # 3; // Sachnummer
  if (aSort=3) then vKey # 10; // Wgr
  if (aSort=4) then vKey # 11; // Agr
  if (aSort=5) then vKey # 6; // Stichwort

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  If (Sel.Art.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate( 250, vKey );
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(250,_SelLock,vSelName);   // Selektion laden

    //vSelName # Sel_Build(vSel, 250, 'LST.250002',n,vKey);

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


    //vSelName # Sel_Build(vSel, 250, 'LST.250002',y,vKey);
  end;
  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(y); // KEIN Landscap


  vFlag # _RecFirst;
  WHILE (RecRead(250,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    RecLink(252,250,4,_RecFirst);   // Basischarge holen

    vOK # n;
    // Verfügbarkeits- oder bestandsabhängiger Ausdruck START
    If ("Sel.Art.-VerfügbarYN") or ("Sel.Art.+VerfügbarYN") or ("Sel.Art.OutOfSollYN") then begin
      If ("Sel.Art.-VerfügbarYN") and ("Art.C.Verfügbar" <= 0.00) then vOK # y;
      If ("Sel.Art.+VerfügbarYN") and ("Art.C.Verfügbar" >  0.00) then vOK # y;
      If ("Sel.Art.OutOfSollYN")  and ("Art.C.Verfügbar" <= "Art.Bestand.Min") then vOK # y;
      End
      // Verfügbarkeits- oder bestandsabhängiger Ausdruck ENDE
    Else begin
      vOK # y;
    end;

    if (vOK) then begin

      // Preis holen
      RecBufClear(254);
      Art.P.ArtikelNr # Art.Nummer;
      Art.P.Preistyp  # 'Ø-EK';
      Erx # RecRead(254,5,0);
      if (Erx>_rMultikey) then RecBufClear(254);
      Gv.Num.01 # 0.0;
      Gv.Num.02 # 0.0;
      Gv.Num.03 # 0.0;
      Art.C.Bestand # Rnd(Art.C.Bestand,2);
      Art.P.PreisW1 # Rnd(Art.P.PreisW1,2);
      if (Art.P.PEH<>0) then begin
        Gv.Num.01 # (Art.Bestand.min   * Art.P.PreisW1) / Cnvfi(Art.P.PEH);
        Gv.Num.02 # (Art.Bestand.soll  * Art.P.PreisW1) / Cnvfi(Art.P.PEH);
        Gv.Num.03 # (Art.C.Bestand     * Art.P.PreisW1) / Cnvfi(Art.P.PEH);
      end;
      Print('Artikel');        // Artikel drucken



      // Detailchargen ausgeben??
      if (Sel.Art.mitChargeYN) and ("Art.ChargenführungYN") then begin

        Erx # RecLink(252,250,4,_RecFirst);   // Chargen loopen
        WHILE (Erx<=_rLocked) do begin
          if (Art.C.Charge.Intern<>'') and (Art.C.Adressnr=0) and (Art.C.Anschriftnr=0) then begin
            Sort_ItemAdd(vTree, CnvaF("Art.C.Länge",_FmtNumLeadZero,0,2,15), 252, RecInfo(252,_RecId));
          end;

          Erx # RecLink(252,250,4,_recNext);
        END;

        // Durchlaufen und löschen
        vItem # Sort_ItemFirst(vTree)
        WHILE (vItem != 0) do begin
          // Datensatz holen
          RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

          Gv.Num.03 # 0.0;
          if (Art.P.PEH<>0) then begin
            Gv.Num.03 # Art.C.Bestand     * Art.P.PreisW1 / Cnvfi(Art.P.PEH);
          end;
          Print('Charge');    // Charge drucken

          vTree->Ctedelete(vItem);
          vItem # Sort_ItemFirst(vTree)
        END
      end;

    end;
  END;


  ListTerm();
  SelClose(vSel);
  vSel # 0;
  SelDelete(250,vSelName);

  // Löschen der Liste
  Sort_KillList(vTree);
end;

//========================================================================