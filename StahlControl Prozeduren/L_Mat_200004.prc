@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200004
//                    OHNE E_R_G
//  Info        Lagerdauer Eigenmaterial
//
//
//  08.01.2008  AI  Erstellung der Prozedur
//  01.08.2008  DS  QUERY
//  10.09.2014  ST  Bugfix: Bei Excelausgabe keinen Seitenumbruch
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cSel    : 'LST.200004'
  cSpace  : 2.0
  cSumGes : 1
  cSumLag : 2
  cSumAdr : 3
end;

//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);
  REPEAT
    if (Dlg_Standard:DatumVonBis(Translate('Zeitraum'), var Sel.von.Datum, var Sel.bis.Datum)=false) then RETURN;
  UNTIL (Sel.von.Datum<>0.0.0) and (Sel.bis.Datum<>0.0.0);

  StartList(0,'');

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

  Print('Selektierung');

  List_Spacing[ 1]  #  0.1;
  List_Spacing[ 2]  # List_Spacing[ 1]  + 15.0;   // Kunde
  List_Spacing[ 3]  # List_Spacing[ 2]  + 200.0;  // Kunde
  List_Spacing[ 4]  # 0.1;
  List_Spacing[ 5]  # List_Spacing[ 4]  + 15.0;   // Lager
  List_Spacing[ 6]  # List_Spacing[ 5]  + 200.0;  // Lager

  List_Spacing[ 7]  # 0.1;
  List_Spacing[ 8]  # List_Spacing[ 7]  + 15.0;   // Matnr
  List_Spacing[ 9]  # List_Spacing[ 8]  + 20.0;   // Quali
  List_Spacing[10]  # List_Spacing[ 9]  + 20.0;   // Dicke
  List_Spacing[11]  # List_Spacing[10]  + 20.0;   // Breite
  List_Spacing[12]  # List_Spacing[11]  + 20.0;   // Länge
  List_Spacing[13]  # List_Spacing[12]  + 25.0;   // Coilnr.
  List_Spacing[14]  # List_Spacing[13]  + 20.0;   // Eingang
  List_Spacing[15]  # List_Spacing[14]  + 20.0;   // Ausgang
  List_Spacing[16]  # List_Spacing[15]  + 25.0;   // Wert

  StartLine(_LF_UnderLine + _LF_Bold);

  Write(7,  'Mat.Nr.'                               ,y , 0);
  Write(8,  'Qualität'                              ,n , 0, cSpace);
  Write(9,  'Dicke'                                 ,y , 0);
  Write(10, 'Breite'                                ,y , 0);
  Write(11, 'Länge'                                 ,y , 0);
  Write(12, 'Coilnummer'                            ,n , 0, cSpace);
  Write(13, 'Eingang'                               ,n , 0);
  Write(14, 'Ausgang'                               ,n , 0);
  Write(15, 'Tonne*Tag'                             ,y , 0);
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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  vX  : float;
end;
begin

  case aName of

    'Selektierung' : begin
      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  #   20.0;
      List_Spacing[ 3]  #   22.0;
      List_Spacing[ 4]  #   30.0;
      List_Spacing[ 5]  #   47.0;
      List_Spacing[ 6]  #   53.0;
      List_Spacing[ 7]  #   80.0;

      StartLine();
      Write( 1, 'Zeitraum'                                         ,n , 0);
      Write(2,  ': '                                               ,n , 0);
      Write(3,  ' von: '                                           ,n , 0);
      if("Sel.von.Datum" <> 0.0.0) then
        Write(4,  DatS("Sel.von.Datum")                            ,n ,_LF_Date);
      Write(5,  ' bis: '                                           ,n , 0);
      if("Sel.bis.Datum" <> 0.0.0) then
        Write(6,  DatS("Sel.bis.Datum")                            ,y , _LF_Date, 2.0);
      EndLine();
    end;  // Selektion

    'AdressKopf' : begin
      StartLine();
      Write( 1, 'Adresse'           ,n , 0);
      Write( 2, Adr.Stichwort       ,n , 0);
      EndLine();
    end;

    'AdressFuss' : begin
      StartLine();
      EndLine();
      startline(_LF_Overline);
      Write(15, ZahlF(Getsum(cSumAdr),1)             ,y , _LF_NUM);
      EndLine();
      Resetsum(cSumAdr);
    end;

    'LagerKopf' : begin
      StartLine();
      Write( 4, 'Lager'               ,n , 0);
      Write( 5, Adr.A.Stichwort       ,n , 0);
      EndLine();
    end;

    'LagerFuss' : begin
      StartLine();
      endline();
      startline(_LF_Overline);
      Write(15, ZahlF(Getsum(cSumLag),1)              ,y , _LF_NUM);
      EndLine();
      Resetsum(cSumLag);
    end;

    'Material' : begin
      StartLine();
      Write(7,  ZahlI(Mat.Nummer)                       ,y , _LF_Int);
      Write(8,  "Mat.Güte"                              ,n , 0, cSpace);
      Write(9,  ZahlF(Mat.Dicke,Set.Stellen.Dicke)      ,y , _LF_Num3);
      Write(10, ZahlF(Mat.Breite,Set.Stellen.Breite)    ,y , _LF_Num3);
      Write(11, ZahlF("Mat.Länge","Set.Stellen.Länge")  ,y , _LF_Num3);
      Write(12, Mat.Coilnummer                          ,n , 0,cSpace);
      if (Mat.Eingangsdatum <> 0.0.0) then
        Write(13, DatS(Mat.Eingangsdatum)               ,n ,_LF_Date);
      if (Mat.Ausgangsdatum <> 0.0.0) then
        Write(14, DatS(Mat.Ausgangsdatum)               ,n ,_LF_Date);

      if (Mat.Eingangsdatum<Sel.Von.Datum) then Mat.Eingangsdatum # Sel.von.Datum;
      if (Mat.Ausgangsdatum>Sel.bis.Datum) then Mat.Ausgangsdatum # Sel.bis.Datum;
      if (Mat.Ausgangsdatum=0.0.0) then  Mat.Ausgangsdatum # Sel.Bis.datum;
      vX  # cnvfi( cnvid(Mat.Ausgangsdatum)-cnvid(Mat.Eingangsdatum) );
      vX # vX * (Mat.Bestand.Gew / 1000.0);
      Write(15, ZahlF(vX,1)                             ,y ,_LF_num);

      AddSum(cSumGes,vX);
      AddSum(cSumLag,vX);
      AddSum(cSumAdr,vX);
      EndLine();
    end;

    'EndSumme' : begin
        startline(_LF_Overline);
        Write(15, ZahlF(Getsum(cSumGes),1)              ,y , _LF_NUM);
        endline();
    end;

  end; // CASE
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
  vMFile      : int;
  vTree       : int;
  vSortKey    : alpha;
  vAnschr     : int;
  vAdr        : int;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  tErx        : int;

  vI  : int;
end;
begin
  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion öffnen
  // Selektionsquery für 200
  vQ # '';
  Lib_Sel:QDate( var vQ, 'Mat.Eingangsdatum', '>', 0.0.0 );
  Lib_Sel:QDate( var vQ, 'Mat.Eingangsdatum', '<=', Sel.bis.Datum );
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( Mat.Ausgangsdatum >= Sel.von.Datum OR Mat.Ausgangsdatum = 0.0.0 ) ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # VQ + ' Mat.Lageradresse != Set.eigeneAdressNr ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' Mat.EigenmaterialYN '
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' Mat.Eingangsdatum != Mat.Ausgangsdatum ';

  vSel # SelCreate( 200, 1 );
  tErx # vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 200, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(200,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    vSortKey # Mat.LagerStichwort+cnvAI(Mat.Lageranschrift,_FmtNumLeadZero,0,8)+cnvAI(Mat.Nummer,_FmtNumLeadZero,0,8);

    Sort_ItemAdd(vTree,vSortKey,200,RecInfo(200,_RecId));
  END;
  SelClose(vSel);
  SelDelete(200, vSelName);
  vSel # 0;

  // ABLAGE-Selektion öffnen
  // Selektionsquery für 210
  vQ # '';
  Lib_Sel:QDate( var vQ, '"Mat~Eingangsdatum"', '>', 0.0.0 );
  Lib_Sel:QDate( var vQ, '"Mat~Eingangsdatum"', '<=', Sel.bis.Datum );
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( "Mat~Ausgangsdatum" >= Sel.von.Datum OR "Mat~Ausgangsdatum" = 0.0.0 ) ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # VQ + ' "Mat~Lageradresse" != Set.eigeneAdressNr ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' "Mat~EigenmaterialYN" '
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' "Mat~Eingangsdatum" != "Mat~Ausgangsdatum" ';

  vSel # SelCreate( 210, 1 );
  tErx # vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 210, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(210,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    vSortKey # Mat.LieferStichwort+cnvAI("Mat~Lageranschrift",_FmtNumLeadZero,0,8)+cnvAI("Mat~Nummer",_FmtNumLeadZero,0,8);

    Sort_ItemAdd(vTree,vSortKey,210,RecInfo(210,_RecId));
  END;
  SelClose(vSel);
  SelDelete(210, vSelName);
  vSel # 0;

  // Protokoll öffnen
  // Selektionsquery für 205
  vQ # '';
  Lib_Sel:QDate( var vQ, 'Mat.O.Anfangsdatum', '<=', Sel.bis.Datum );
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( Mat.O.Enddatum >= Sel.von.Datum ) ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # VQ + ' Mat.O.Lageradresse != Set.eigeneAdressNr ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' Mat.O.Anfangsdatum != Mat.O.Enddatum ';
  if ( vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Mat) > 0 OR LinkCount(MatA) > 0 ) ';

  // Selektionsquery für 200
  vQ2 # '';
  vQ2 # ' Mat.EigenmaterialYN ';

  // Selektionsquery für 210
  vQ3 # '';
  vQ3 # ' "Mat~EigenmaterialYN" ';

  vSel # SelCreate( 205, 1 );
  vSel->SelAddLink('', 200, 205, 1, 'Mat');
  vSel->SelAddLink('', 210, 205, 4, 'MatA');
  tErx # vSel->SelDefQuery('', vQ );
  tErx # vSel->SelDefQuery('Mat', vQ2 );
  tErx # vSel->SelDefQuery('MatA', vQ3 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 205, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(205,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    Erx # RecLink(200,205,1,_recFirst);   // Material holen
    if (Erx>_rLockeD) then begin
      Erx # RecLink(210,205,4,_recFirst); // Materialablage holen
      RecBufCopy(210,200);
    end;
    vSortKey # Mat.LieferStichwort+cnvAI(Mat.O.Lageranschrift,_FmtNumLeadZero,0,8)+cnvAI(Mat.Nummer,_FmtNumLeadZero,0,8);

    Sort_ItemAdd(vTree,vSortKey,205,RecInfo(205,_RecId));
  END;
  SelClose(vSel);
  SelDelete(205, vSelName);
  vSel # 0;


  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(n);    // starte Portrait


  // RAMBAUM
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    vMFile # cnvIA(vItem->spCustom);

    // Datensatz holen
    RecRead(vMFile,0,0,vItem->spID);
    If (vMFile=210) then RecBufCopy(210,200); // Ablage kopieren

    // Protokoll?
    If (vMFile=205) then begin
      Erx # RecLink(200,205,1,_recFirsT);   // Material holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(210,205,4,_recFirsT); // Materialablage holen
        RecBufCopy(210,200);
      end;
      Mat.Eingangsdatum   # Mat.O.AnfangsDatum;
      Mat.Ausgangsdatum   # Mat.O.EndDatum;
      Mat.Lageradresse    # Mat.O.Lageradresse;
      Mat.Lageranschrift  # Mat.O.Lageranschrift;
    end;


    if (vAdr<>Mat.Lageradresse) then begin
      if (vAnschr<>0) then Print('LagerFuss');
      if (vAdr<>0) then begin
        if (vAnschr<>0) then Print('AdressFuss');
        if (List_XML = false) then
          Lib_Print:Print_FF();
      end;
      RecLink(100,200,5,_recFirst);   // Lageradresse holen
      Print('AdressKopf');
      vAdr # Mat.Lageradresse;
      if (vAnschr<>0) then vAnschr # -1;
    end;

    if (vAnschr<>Mat.Lageranschrift) then begin
      if (vAnschr>0) then Print('LagerFuss');
      RecLink(101,200,6,_recFirst);   // Lageranschrift holen
      Print('LagerKopf');
      vAnschr # Mat.Lageranschrift;
    end;
    Print('Material');

  END;
  if (vAnschr>0) then Print('LagerFuss');
  if (vAdr>0) then Print('LieferantFuss');
  Print('EndSumme');
  
  //Liste beenden
  ListTerm();
  
  // Löschen der Liste
  Sort_KillList(vTree);

  //ListTerm();
end;

//========================================================================