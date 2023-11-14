@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450005
//                    OHNE E_R_G
//  Info        Eingangs-und Ausgangsrechnungen ausgeben
//
//
//  31.05.2007  NH  Erstellung der Prozedur
//  25.07.2008  DS  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
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
  Sel.Auf.von.Projekt # 0;  Sel.Auf.bis.Projekt # 9999999;
  Sel.von.Datum # 0.0.0;    Sel.bis.Datum # today;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450005','L_Erl_450005:AusSel');
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
  StartList(vSort,vSortname);  // Liste generieren

end;

//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
local begin
  Erx     : int;
  vAufNr  : int;
end;
begin
  case aName of

    'Ausgang' : begin;
      StartLine();
      RecLink(100,451,6,_recFirst)
      Erx # RecLink(401,451,8,0);    // Auf.Position holen
      if (Erx>_rLocked) then begin
        Erx # RecLink(411,451,9,0);  // Auf.Pos.Ablage holen
        if (Erx>_rLocked) then RecBufClear(411);
        RecBufCopy(411,401);
      end
      if(Auf.P.Projektnummer <> 0 ) then
        vAufNr # Auf.P.Projektnummer
      else
        begin
        RecLink(411,451,9,_recFirst)
        vAufNr # "Auf~P.Projektnummer"
        end;
      Write(1, ZahlI(Erl.K.Rechnungsnr)    ,y , 0,3.0);
      Write(2, cnvAD(Erl.K.Rechnungsdatum) ,n , 0);
      Write(3, ZahlI(Erl.K.Kundennummer)   ,y , 0,3.0);
      Write(4, Adr.Stichwort               ,n , 0);
      Write(5, ZahlI("Erl.K.Stückzahl")    ,y , 0,3.0);
      Write(6, ZahlF(Erl.K.Menge,2)        ,y , 0);
      Write(7, ZahlF(Erl.K.BetragW1,2)     ,y , 0);
      Write(8, ZahlI(vAufNr)               ,y , 0);
      EndLine();
    end;

    'Bestand' : begin;
      StartLine();
      Write(1, ZahlI(Mat.Nummer)                          ,y , 0,3.0);
      Write(2, "Mat.Güte"                                 ,n , 0);
      Write(3, ANum(Mat.Dicke   ,Set.Stellen.Dicke)      ,y , 0);
      Write(4, ANum(Mat.Breite  ,Set.Stellen.Breite)     ,y , 0);
      Write(5, ANum("Mat.Länge" ,"Set.Stellen.Länge")    ,y , 0);
      Write(6, ANum(Mat.Bestand.Gew,Set.Stellen.Gewicht) ,y , 0);
      Write(7, ANum(Mat.EK.Preis * Mat.Bestand.Gew / 1000.0,2)      ,y , 0);
      EndLine();
    end;

    'Eingang' : begin;
      StartLine();
      Write(1, ZahlI(EKK.EingangsreNr)                    ,y , 0,2.0);
      Write(2, EKK.LieferStichwort                        ,n , 0);
      Reclink(560,555,1,_RecFirst);
        Write(3, cnvAD(ERe.Rechnungsdatum)                           ,n , 0);
      Write(4, ZahlF(EKK.PreisW1,2)                         ,y , 0);
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
    List_Spacing[ 20]  # 5.0;
    List_Spacing[ 21]  #100.0;
    StartLine();
    Write(20,'Projekt     ' + AInt(Sel.Auf.von.Projekt) + '  bis  ' + AInt(Sel.Auf.bis.Projekt),n);
    EndLine();
    StartLine();
    Write(20,'Zeitraum    ' + cnvAD(Sel.von.Datum) + '  bis  ' + cnvAD(Sel.bis.Datum),n);
    EndLine();
    StartLine();
    EndLine();
  end;

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
  vFlag       : int;        // Datensatzlese option
  vSel        : int;
  vSelName    : alpha;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  tErx        : int;
  tErx2        : int;
  tErx3        : int;
end;
begin
  ListInit(n);

  //-------------------Ausgang------------------------

  List_Spacing[ 1]  #   0.0;
  List_Spacing[ 2]  #  21.0;
  List_Spacing[ 3]  #  40.0;
  List_Spacing[ 4]  #  56.0;
  List_Spacing[ 5]  #  95.0;
  List_Spacing[ 6]  # 113.0;
  List_Spacing[ 7]  # 130.0;
  List_Spacing[ 8]  # 155.0;
  List_Spacing[ 9]  # 180.0;

  StartLine(_LF_Bold);
  Write(1,'Ausgang',n);
  EndLine();

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Rechn.-Nr'                        ,y , 0,3.0);
  Write(2, 'Datum'                            ,n , 0);
  Write(3, 'Adr-Nr'                           ,y , 0,3.0);
  Write(4, 'Name'                             ,n , 0);
  Write(5, 'Stück'                            ,y , 0,3.0);
  Write(6, 'Menge'                            ,y , 0);
  Write(7, 'Wert'                             ,y , 0);
  Write(8, 'Projekt'                          ,y , 0);
  EndLine();

  // Selektionsquery für 451
  vQ # '';
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, 'Erl.K.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Auftrag) > 0 OR LinkCount(AAblage) > 0 ) ';

  // Selektionsquery für 401
  vQ2 # '';
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.Bis.Projekt != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Auf.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.Bis.Projekt );
  // Selektionsquery für 411
  vQ3 # '';
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.Bis.Projekt != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Auf~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.Bis.Projekt );

  // Selektion starten...
  vSel # SelCreate( 451, 1 );
  vSel->SelAddLink('', 401, 451, 8, 'Auftrag');
  vSel->SelAddLink('', 411, 451, 9, 'AAblage');
  tErx # vSel->SelDefQuery('', vQ );
  tErx2 # vSel->SelDefQuery('Auftrag', vQ2 );
  tErx3 # vSel->SelDefQuery('AAblage', vQ3 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


//  vSel#0;
//  vSelName # Sel_Build(vSel, 451, 'LST.450005' ,y ,0);
  vFlag # _RecFirst;
  WHILE (RecRead(451,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    Print('Ausgang');
  END;
  SelClose(vSel);
  vSel # 0;
  SelDelete(451,vSelName);
  StartLine();
  EndLine();

  //-------------------Bestand-----------------------

  StartLine(_LF_Bold);
  Write(1,'Bestand',n);
  EndLine();

  List_Spacing[ 1]  #   0.0;
  List_Spacing[ 2]  #  17.0;
  List_Spacing[ 3]  #  45.0;
  List_Spacing[ 4]  #  63.0;
  List_Spacing[ 5]  #  88.0;
  List_Spacing[ 6]  # 111.0;
  List_Spacing[ 7]  # 145.0;
  List_Spacing[ 8]  # 180.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Mat.-Nr'                       ,y ,0 ,3.0);
  Write(2, 'Güte'                          ,n ,0     );
  Write(3, 'Dicke'                         ,y ,0     );
  Write(4, 'Breite'                        ,y ,0     );
  Write(5, 'Länge'                         ,y ,0     );
  Write(6, 'Gewicht'                       ,y ,0     );
  Write(7, 'Wert'                          ,y ,0     );
  EndLine();

  // Selektionsquery für 200
  vQ # '';
  if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != today) then
    Lib_Sel:QVonBisD( var vQ, '"Mat.Übernahmedatum"', Sel.von.Datum, Sel.bis.Datum );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Einkauf) > 0 OR LinkCount(EAblage) > 0 ) ';

  // Selektionsquery für 501
  vQ2 # ''
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.Bis.Projekt != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ2, 'Ein.P.Projektnummer', Sel.Auf.von.Projekt, Sel.Auf.Bis.Projekt );
  // Selektionsquery für 511
  vQ3 # '';
  if ( Sel.Auf.von.Projekt != 0 ) or ( Sel.Auf.Bis.Projekt != 9999999 ) then
    Lib_Sel:QVonBisI( var vQ3, '"Ein~P.Projektnummer"', Sel.Auf.von.Projekt, Sel.Auf.Bis.Projekt );

  // Selektion starten...
  vSel # SelCreate( 200, 1 );
  vSel->SelAddLink('', 501, 200, 18, 'Einkauf');
  vSel->SelAddLink('', 511, 200, 19, 'EAblage');
  tErx # vSel->SelDefQuery('', vQ );
  tErx2 # vSel->SelDefQuery('Einkauf', vQ2 );
  tErx3 # vSel->SelDefQuery('EAblage', vQ3 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


//  vSel#0;
//  vSelName # Sel_Build(vSel, 200, 'LST.450005' ,y ,0);
  vFlag # _RecFirst;
  WHILE (RecRead(200,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    Print('Bestand');
  END;
  SelClose(vSel);
  SelDelete(200,vSelName);

  //-------------------Eingang------------------------

  List_Spacing[ 1]  #   0.0;
  List_Spacing[ 2]  #  20.0;
  List_Spacing[ 3]  #  60.0;
  List_Spacing[ 4]  #  90.0;
  List_Spacing[ 5]  # 120.0;

  StartLine(_LF_Bold);
  Write(1,'Eingang',n);
  EndLine();

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Rechn.-Nr'                        ,y , 0, 2.0);
  Write(2, 'Lieferant'                        ,n , 0);
  Write(3, 'Rechn.-Datum'                     ,n , 0);
  Write(4, 'Wert €'                           ,y , 0);
  EndLine();

  // Selektionsquery für 555
  vQ # '';
  Lib_Sel:QInt( var vQ, 'EKK.EingangsreNr', '!=', 0 );
  if (vQ != '') then vQ # vQ + ' AND ';
  vQ # vQ + ' ( LinkCount(Einkauf) > 0 OR LinkCount(EAblage) > 0 ) ';

  // Selektion starten...
  vSel # SelCreate( 555, 1 );
  vSel->SelAddLink('', 501, 555, 5, 'Einkauf');
  vSel->SelAddLink('', 511, 555, 6, 'EAblage');
  tErx # vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  //vSel#0;
  //vSelName # Sel_Build(vSel, 555, 'LST.450005' ,y ,0);
  vFlag # _RecFirst;
  WHILE (RecRead(555,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    Print('Eingang');
  END;
  SelClose(vSel);
  vSel # 0;
  SelDelete(555,vSelName);
  StartLine();
  EndLine();

  ListTerm();
end;

//========================================================================