@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Adr_100004
//                    OHNE E_R_G
//  Info        Selektierte Adressen ausgeben
//
//
//  05.05.2004  AI  Erstellung der Prozedur
//  12.04.2005  TM  Sel.Adr.von.KdNr bleibt immer leer!
//  26.11.2012  ST  Erweiterung um Haken "Privates GEschenk" für XML (Projekt 1334/148)
//  06.06.2016  AH  Umbau Adr.KundenFibuNr/Adr.LieferantFibuNr
//
//  Subprozeduren
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
begin

  RecBufClear(998);
  Sel.Adr.bis.KdNr   # 9999999;
  Sel.Adr.bis.LiNr   # 9999999;
  Sel.Adr.bis.FibuKd # 'ZZZ';
  Sel.Adr.bis.FibuLi # 'ZZZ';
  Sel.Adr.bis.Gruppe # 'zzz';
  Sel.Adr.bis.Stichw # 'zzz';
  Sel.Adr.bis.ABC    # 'z';
  Sel.Adr.bis.LKZ    # 'zzz';
  Sel.Adr.bis.PLZ    # 'zzz';
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.Mark.Adressen','L_Adr_100004:AusSel');
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
  vHdl2->WinLstDatLineAdd('Kundennnummer');
  vHdl2->WinLstDatLineAdd('Lieferantenummer');
  vHdl2->WinLstDatLineAdd('Stichwort');
  vHdl2->WinLstDatLineAdd('Name');
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
  List_Spacing[ 2]  # 40.0;
  List_Spacing[ 3]  # 80.0;
  List_Spacing[ 4]  # 100.0;
  List_Spacing[ 5]  # 120.0;
  List_Spacing[ 6]  # 125.0;
  List_Spacing[ 7]  # 200.0;


  StartLine(_LF_Bold);
  Write(1, 'Stichwort'                           ,n , 0);
  Write(2, 'Anrede'                           ,n , 0);
  Write(6, 'Strasse'                   ,n , 0);
  EndLine();
    StartLine(_LF_Bold);
  Write(1, 'KundenNr'                           ,n , 0);
  Write(2, 'Name'                           ,n , 0);
  Write(6, 'PLZ    Ort'                   ,n , 0);
  EndLine();
    StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'LieferNr'                           ,n , 0);
  Write(2, 'Zusatz'                           ,n , 0);
  Write(6, 'Telefon'                   ,n , 0);



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
  vName       : alpha;

  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vFlag2      : int;        // Datensatzlese option

  vSelName    : alpha;

  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;

  vzae        : int;
  vQ          : alpha(4000);
end;
begin

  // Sortierung setzen
  if (aSort=1) then vKey # 2; // Kundennummer
  if (aSort=2) then vKey # 3; // Lieferantennummer
  if (aSort=3) then vKey # 4; // Stichwort
  if (aSort=4) then vKey # 6; // Name

  If (Sel.Adr.nurMarkeYN) then begin

    // Selektion starten...
    vSel # SelCreate( 100, vKey );
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen

    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(100,_SelLock,vSelName);   // Selektion laden

    //vSelName # Sel_Build(vSel, 100, 'LST.100004',n,vKey);

    // Ermittelt das erste Element der Liste (oder des Baumes)
    vItem # gMarkList->CteRead(_CteFirst);
    // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 100) then begin
        RecRead(100,0,_RecId,vMID);
        SelRecInsert(vSel,100);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin

    // Selektionsquery
    vQ # '';
    if ( Sel.Adr.von.KdNr != 0 ) or ( Sel.Adr.bis.KdNr != 9999999 ) then
      Lib_Sel:QVonBisI( var vQ, 'Adr.Kundennr', Sel.Adr.von.KdNr, Sel.Adr.bis.KdNr );
    if ( Sel.Adr.von.LiNr != 0 ) or ( Sel.Adr.bis.LiNr != 9999999 ) then
      Lib_Sel:QVonBisI( var vQ, 'Adr.LieferantenNr', Sel.Adr.von.LiNr, Sel.Adr.bis.LiNr );
    if ( Sel.Adr.von.FibuKd != '' ) or ( Sel.Adr.bis.FibuKd != 'ZZZ' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.KundenFibuNr', Sel.Adr.von.FibuKd, Sel.Adr.bis.FibuKd );
    if ( Sel.Adr.von.FibuLi != '' ) or ( Sel.Adr.bis.FibuLi != 'ZZZ' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.LieferantFibuNr', Sel.Adr.von.FibuLi, Sel.Adr.bis.FibuLi );
    if ( Sel.Adr.von.Stichw != '' ) or ( Sel.Adr.bis.Stichw != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.Stichwort', Sel.Adr.von.Stichw, Sel.Adr.bis.Stichw );
    if ( Sel.Adr.von.Sachbear != '' ) then
      Lib_Sel:QAlpha( var vQ, 'Adr.Sachbearbeiter', '=', Sel.Adr.von.Sachbear );
    if ( Sel.Adr.von.Vertret != 0 ) then
      Lib_Sel:QInt( var vQ, 'Adr.Vertreter', '=', Sel.Adr.von.Vertret );
    if ( Sel.Adr.von.Gruppe != '' ) or ( Sel.Adr.bis.Gruppe != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.Gruppe', Sel.Adr.von.Gruppe, Sel.Adr.bis.Gruppe );
    if ( Sel.Adr.von.ABC != '' ) or ( Sel.Adr.bis.ABC != 'z' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.ABC', Sel.Adr.von.ABC, Sel.Adr.bis.ABC );
    if ( Sel.Adr.von.LKZ != '' ) or ( Sel.Adr.bis.LKZ != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.LKZ', Sel.Adr.von.LKZ, Sel.Adr.bis.LKZ );
    if ( Sel.Adr.von.PLZ != '' ) or ( Sel.Adr.bis.PLZ != 'zzz' ) then
      Lib_Sel:QVonBisA( var vQ, 'Adr.PLZ', Sel.Adr.von.PLZ, Sel.Adr.bis.PLZ );
    if ( Sel.Adr.Briefgruppe != '') then
      Lib_Sel:QenthaeltA( var vQ, 'Adr.Briefgruppe', Sel.Adr.Briefgruppe );

    // Selektion starten...
    vSel # SelCreate( 100, vKey );
    vSel->SelDefQuery( '', vQ );
    vSelName # Lib_Sel:SaveRun( var vSel, 0);
    //vSelName # Sel_Build(vSel, 100, 'LST.100004',y,vKey);
  end;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


ListInit(n); // KEIN Landscape



  vFlag # _RecFirst;
  WHILE (RecRead(100,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    StartLine();
    Write(1, Adr.Stichwort                     ,n , 0);
    Write(2, Adr.Anrede                       ,n , 0);
    Write(6, "Adr.Straße"                     ,n , 0);
    EndLine();

    StartLine();
    Write(1, ZahlI(Adr.KundenNr)                         ,n , _LF_INT);
    Write(2, Adr.Name                                    ,n , 0);
    Write(6, Adr.LKZ +' '+Adr.PLZ +' ' + Adr.Ort                    ,n , 0);
    EndLine();

    StartLine();
    Write(1, ZahlI(Adr.LieferantenNr)               ,n , _LF_INT);
    Write(2, Adr.Zusatz                             ,n , 0);
    Write(6, Adr.Telefon1                           ,n , 0);
    EndLine();
    startLine();
    endline();
    startLine();
    endline();

    vFlag2 # _RecFirst;


    vzae # 1;
    WHILE (recLink(102,100,13,vFlag2) <= _rlocked) DO BEGIN
      if (vFlag2=_RecFirst) then vFlag2 # _RecNext;

    StartLine(_LF_Bold);
    Write(2, 'Ansprechpartner'+ ZahlI(vzae)                     ,n , 0);

    EndLine();
    startLine();
    EndLine();
    StartLine();
    Write(2, Adr.P.Titel                          ,n , 0);
    Write(4, 'Tele'                               ,n , 0);
    Write(5, ':'                                  ,n , 0);
    Write(6, Adr.P.Telefon                        ,n , 0);
    EndLine();

    StartLine();
    Write(2, Adr.P.Name                    ,n , 0);
    Write(4, 'Fax'                         ,n , 0);
    Write(5, ':'                           ,n , 0);
    Write(6, Adr.P.Telefax                 ,n , 0);
    EndLine();

    StartLine();
    Write(2, Adr.P.Vorname                   ,n , 0);
    Write(4, 'Mobil'                         ,n , 0);
    Write(5, ':'                             ,n , 0);
    Write(6, Adr.P.Mobil                     ,n , 0);
    EndLine();

    StartLine();
    Write(4, 'e-mail'                        ,n , 0);
    Write(5, ':'                             ,n , 0);
    Write(6, Adr.P.eMail                     ,n , 0);
    EndLine();


    if (list_XML) then begin

      // Priv. Anschrift
      StartLine();
      Write(4, 'Straße'             ,n , 0);
      Write(5, ':'                  ,n , 0);
      Write(6, "Adr.P.Priv.Straße"  ,n , 0);
      EndLine();

      StartLine();
      Write(4, 'PLZ'             ,n , 0);
      Write(5, ':'                  ,n , 0);
      Write(6, "Adr.P.Priv.PLZ"  ,n , 0);
      EndLine();

      StartLine();
      Write(4, 'Ort'             ,n , 0);
      Write(5, ':'                  ,n , 0);
      Write(6, "Adr.P.Priv.Ort"  ,n , 0);
      EndLine();

      // priv. Geschenk
      StartLine();
      Write(4, 'Privates Geschenk'             ,n , 0);
      Write(5, ':'                             ,n , 0);
      if (Adr.P.PrivGeschenkYN) then
        Write(6, 'ja'  ,n , 0);
      else
        Write(6, 'nein'  ,n , 0);
      EndLine();


    end;




    vzae # vzae+1;
    END;
    startline();
    endline();
    startline(_LF_UnderLine);
    endline();

  END;
  ListTerm();

  SelClose(vSel);             // Selektion schliessen
  SelDelete(100,vSelName);    // temp. Selektion löschen
  vSel  # 0;
End;

//========================================================================