@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_120006
//                    OHNE E_R_G
//  Info        Projekte Positionsliste Übersicht
//
//
//  09.06.2008  MS  Erstellung der Prozedur
//  01.08.2008  DS  QUERY
//  18.03.2009  TM  Selektion erweitert um Gelöschte Projekte JN
//  24.03.2010  AI  Selektion aus 120004
//  2022-06-28  AH  ERX
//
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//    SUB StartList(aSort : int; aSortName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare AusSel();

define begin
cSel : 'LST.120006'
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  Sel.Selektionsname # '';
  Sel.Adr.von.KdNr # 0 ;
  Usr.Username # '';
  Adr.Stichwort # '';
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.120006',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd('Adresse');
  vHdl2->WinLstDatLineAdd('WV-User');
//  vHdl2->WinLstDatLineAdd('Kundenstichwort');
//  vHdl2->WinLstDatLineAdd('Wunschtermin');
//  vHdl2->WinLstDatLineAdd('Zusagetermin');
  vHdl2->wpcurrentint#1
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected = 0) then begin
    Lfm_Ausgabe:Cleanup();  // 17.02.2022 AH
    RETURN;
  end
  vSort # gSelected;
  gSelected # 0;

  StartList(vSort,vSortname);  // Liste generieren
end;

//========================================================================
//  Print
//
//========================================================================
sub Print(aName : alpha);
local begin
  vI      : int;
  vTxtHdl : int;
  vA      : alpha(200);
end;
begin

  case (aName) of

    'Leer' : begin
      StartLine();
      EndLine();
    end;

    'Summe' : begin
      StartLine(_LF_Overline);

      Write(4, ZahlF(GV.num.01, 2)                                                ,y , 0);
      GV.num.01 # 0.0;
      Write(5, ZahlF(GV.num.02, 2)                                                ,y , 0);
      GV.num.02 # 0.0;
      EndLine();
    end;

    '120_122' : begin
      StartLine();
      Write(1,  ZahlI(Prj.Nummer)                                      ,y , _LF_Int);
      Write(2,  ZahlI(Prj.P.Position)                                  ,y , _LF_Int, 3.0);

      Write(3,   Prj.P.Bezeichnung                                                ,n , 0);
      Write(4,  ZahlF(Prj.P.Dauer.Angebot, 2)                          ,y , _LF_Num);
      Write(5,  ZahlF(Prj.P.Dauer.Extern, 2)                           ,y , _LF_Num);

      Write(6,  ZahlI("Prj.P.Priorität")                               ,y , _LF_Int, 3.0);
      Write(7,  Prj.P.WiedervorlUser                                              ,n , 0);
      if ("Prj.P.Datum.Ende" <> 0.0.0) then
        Write(8,  DatS("Prj.P.Datum.Ende")                                 ,n ,_LF_Date);
      if ("Prj.P.Lösch.Datum" <> 0.0.0) then
        Write(9,  DatS("Prj.P.Lösch.Datum")                             ,n ,_LF_Date);
      RecLink(850,122,3,0);
      Write(10, StrCut(Stt.Bezeichnung,0,14)                                           ,n , 0);
      EndLine();

    end;

  end; // case

end;



//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
local begin
  Erx : int;
end;
begin
  WriteTitel();     // Drucke grosse Überschrift

  StartLine();
  if(Sel.Adr.von.KdNr <> 0) then begin
    Erx # RecLink(100,120,1,0);     // Adresse holen
    if (Erx<=_rLocked) then
      Write(1, 'Projektposition: '+ Adr.Stichwort    ,n , 0);
  end;
  EndLine();
  //if (aSeite=1) then begin

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 15.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 65.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 33.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 30.0;
  /*List_Spacing[12]  # List_Spacing[11] + 20.0;
  List_Spacing[13]  # List_Spacing[12] + 17.0;

  List_Spacing[15]  # List_Spacing[ 1] + 40.0;
  List_Spacing[16]  # List_Spacing[15] + 20.0;
  List_Spacing[17]  # List_Spacing[16] + 15.0;
  List_Spacing[18]  # List_Spacing[17] + 15.0;
  List_Spacing[19]  # List_Spacing[18] + 15.0;
  List_Spacing[20]  # List_Spacing[ 2]
  List_Spacing[21]  # List_Spacing[20] + 0.0;
  List_Spacing[22]  # List_Spacing[21] + 120.0;
  List_Spacing[23]  # List_Spacing[20] + 0.0;
  List_Spacing[24]  # List_Spacing[21] + 120.0;
  List_Spacing[25]  # List_Spacing[13] + 30.0;
  */


  StartLine(_LF_UnderLine + _LF_Bold);
  Write( 1, 'Prj.Nr'                                                       ,y, 0);
  Write( 2, 'Pos'                                                          ,y, 0, 3.0);
  Write( 3, 'Bezeichnung'                                                      ,n , 0);
  Write( 4, 'Angebotene Std.'                                                ,y , 0);
  Write( 5, 'Ist Std.'                                                    ,y , 0);
  Write( 6, 'Prio.'                                                         ,y , 0, 3.0);
  Write( 7, 'WV-User'                                                       ,n , 0);
  Write( 8, 'Termin bis'                                                    ,n , 0);
  Write( 9, 'gelöscht am'                                                   ,n , 0);
  Write(10, 'Status'                                                   ,n , 0);

  Endline();

 // end;
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
sub StartList(aSort : int; aSortName : alpha);
local begin
  Erx       : int;
  vSelName  : alpha;
  vSel      : int;
  vFlag     : int;

  vItem     : int;
  vMFile,vMID : int;

  vTree     : int;
  vSortKey  : alpha;

  vUser     : alpha;

  vKunde    : int;
  vQ        : alpha(4000);
  vQ1       : alpha(4000);
end;
begin

  //Rambaum aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  vSel # SelCreate(122, 1);
  // nur Markierte?
  if (Sel.Fin.NurMarkeYN) then begin

    // Selektion starten...
    vSelName # Lib_Sel:Save(vSel);          // speichern mit temp. Namen
    vSel # SelOpen();                       // Selektion öffnen
    vSel->selRead(122,_SelLock,vSelName);   // Selektion laden

    // Einträge der Markierungsliste in die Selektion schreiben
    vItem # gMarkList->CteRead(_CteFirst);
    WHILE (vItem > 0) do begin
      Lib_Mark:TokenMark(vItem,var vMFile, var vMID);
      if (vMFile = 122) then begin
        RecRead(122,0,_RecId,vMID);
        Erx # SelRecInsert(vSel,122);
      end;
      vItem # gMarkList->CteRead(_CteNext,vItem);
    END;

  end else begin

    // Selektionsquery für 122
    vQ # '';
    if(Sel.Art.von.Stichwor <> '') and (Sel.Art.bis.Stichwor <> '') then
      vQ # vQ + '("Prj.P.Bezeichnung" =* ''*' + Sel.Art.von.Stichwor + '*'' OR "Prj.P.Bezeichnung" =* ''*' + Sel.Art.bis.Stichwor + '*'')';
    else if (Sel.Art.von.Stichwor <> '') and (Sel.Art.bis.Stichwor = '') then
      vQ # vQ + '"Prj.P.Bezeichnung" =* ''*' + Sel.Art.von.Stichwor + '*''';
    else if (Sel.Art.von.Stichwor = '') and (Sel.Art.bis.Stichwor <> '') then
      vQ # vQ + '"Prj.P.Bezeichnung" =* ''*' + Sel.Art.bis.Stichwor + '*''';

    if (Sel.Adr.nurMarkeYN = true) then
      Lib_Sel:QDate(var vQ, 'Prj.P.Lösch.datum','=',0.0.0);
    if (Sel.Adr.von.Sachbear != '') then
      Lib_Sel:QenthaeltA(var vQ, 'Prj.P.WiedervorlUser',  Sel.Adr.von.Sachbear);

    if (Sel.Fin.von.Rechnung <> 0) then begin
      if (vQ <> '') then
        vQ # vQ + ' AND ';
      vQ # vQ + '"Prj.P.Nummer" = Sel.Fin.von.Rechnung';
    end;

    if (vQ <> '') then vQ # vQ + ' AND ';
    vQ # vQ + ' LinkCount(Kopf) > 0 ';

    // Selektionsquery für 120
    vQ1 # '';
    if (Sel.Adr.von.KdNr != 0) then
      Lib_Sel:QInt(var vQ1, 'Prj.Adressnummer', '=',  Sel.Adr.von.KdNr);
    if (Sel.Adr.nurMarkeYN = true) then
      Lib_Sel:QAlpha(var vQ1, 'Prj.Löschmarker','!=','*');

    // Selektion starten...
    vSel # SelCreate(122, 1);
    vSel->SelAddLink('', 120, 122, 2, 'Kopf');
    Erx # vSel->SelDefQuery('', vQ);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    Erx # vSel->SelDefQuery('Kopf', vQ1);
    if (Erx <> 0) then
      Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun(var vSel, 0);

  end;

  // Sortierung
  vFlag # _RecFirst;
  WHILE (RecRead(122,vSel,vFlag) <= _rLocked) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    RecLink(120,122,2,_recfirst);     // Kopf holen

    Erx # RecLink(100,120,1,_recFirst);   // Adresse holen
    if (Erx>_rLocked) then RecBufClear(100);

    if (aSort=1) then   vSortKey # Adr.Stichwort + cnvAI(Prj.Adressnummer) + cnvAI(Prj.Nummer);
    if (aSort=2) then   vSortKey # Prj.P.WiedervorlUser + cnvAI(Prj.Nummer);
    // Absteigende Sortierung für Prioritäten
    if (aSort=3) then   vSortKey # AInt(100000000-(("Prj.P.Priorität"*100000) + Prj.Nummer));

    Sort_ItemAdd(vTree,vSortKey,122,RecInfo(122,_RecId));
  END;

  // Daten stehen jetzt im Rambaum/-liste
  SelClose(vSel);
  SelDelete(120, vSelName);
  vSel # 0;

/***
  // Selektionsquery für 122
  vQ # '';
  if (Sel.Adr.nurMarkeYN = true) then
    Lib_Sel:QDate( var vQ, 'Prj.P.Lösch.datum','=',0.0.0);
  if (Sel.Adr.von.Sachbear != '') then
    Lib_Sel:QenthaeltA( var vQ, 'Prj.P.WiedervorlUser',  Sel.Adr.von.Sachbear );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' LinkCount(Kopf) > 0 ';

  // Selektionsquery für 120
  vQ1 # '';
  if (Sel.Adr.von.KdNr != 0) then
    Lib_Sel:QInt( var vQ1, 'Prj.Adressnummer', '=',  Sel.Adr.von.KdNr );
  if (Sel.Adr.nurMarkeYN = true) then
    Lib_Sel:QAlpha( var vQ1, 'Prj.Löschmarker','!=','*');

  // Selektion starten...
  vSel # SelCreate( 122, 1 );
  vSel->SelAddLink('', 120, 122, 2, 'Kopf');
  Erx # vSel->SelDefQuery( '', vQ );
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery( 'Kopf', vQ1 );
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  vFlag # _RecFirst;
  WHILE (RecRead(122,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    RecLink(120,122,2,_recfirst);     // Kopf holen

    Erx # RecLink(100,120,1,_recFirst);   // Adresse holen
    if (Erx>_rLocked) then RecBufClear(100);

    if (aSort=1) then   vSortKey # Adr.Stichwort + cnvAI(Prj.Adressnummer) + cnvAI(Prj.Nummer);
    if (aSort=2) then   vSortKey # Prj.P.WiedervorlUser + cnvAI(Prj.Nummer);

    Sort_ItemAdd(vTree,vSortKey,122,RecInfo(122,_RecId));
  END;

  SelClose(vSel);
  SelDelete(120, vSelName);
  vSel # 0;
***/


  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  ListInit(y);    // starte Landscape

  GV.num.01   # 0.0;
  GV.Num.02   # 0.0;

  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    RecLink(120,122,2,_recFirst);   // Projekt holen



    // Gruppierung je nach Sortierung
    if (aSort=2) then begin
      if (vUser<>Prj.P.WiedervorlUser) AND (vUser <> '') then begin
        Print('Summe');
        Print('Leer');

      end;
      Print('120_122');
      vUser  # Prj.P.WiedervorlUser;
    end;


    if (aSort=1) then begin
      if (vKunde<>Prj.Adressnummer) and (vKunde > 0) then begin
        Print('Summe');
        Print('Leer');

      end;
      Print('120_122');
      vKunde # Prj.Adressnummer;
    end;

    GV.num.01 # GV.num.01 + Prj.P.Dauer.Angebot;
    GV.Num.02 # GV.Num.02 + Prj.P.Dauer.Extern;

  END;
  Print('Summe');
  Sort_KillList(vTree);



  ListTerm(); // Ende der Liste

end;


//========================================================================