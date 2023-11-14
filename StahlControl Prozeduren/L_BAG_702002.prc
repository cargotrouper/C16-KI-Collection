@A+
//===== Business-Control =================================================
//
//  Prozedur    L_BAG_702002
//                    OHNE E_R_G
//  Info        Maschineneinplanung
//
//
//  15.02.2008  DS  Erstellung der Prozedur
//  01.08.2008  DS  QUERY
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB AusSel();
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB BerechneDatbis(aDatum : date): date;
//    sub FuelleDatArray(aBeginn : date; aEnde : date);
//    sub LeereSummen();
//    Sub Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Print(aName : alpha);

define begin
  cFile : 702
  cSel  : 'LST.702002'
end;

local begin
  vDateArray : date[10];
  vMaschine  : alpha;
end;


//========================================================================
//  Main
//
//========================================================================
MAIN
begin

  RecBufClear(998);
  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'SEL.LST.702002',here+':AusSel');
  gMDI->wpcaption # Lfm.Name;
  Lib_GuiCom:RunChildWindow(gMDI);

end;

//========================================================================
// Berechnung Startdatum bis
//
//========================================================================
sub BerechneDatbis(aDatum : date): date;
local begin
  vDate       : date;
  vDateInt    : int;
end;
begin
  vDateInt      # cnvID(aDatum);
  vDateInt      # vDateInt + 9;
  vDate         # cnvDI(vDateInt);
  Return vDate;
end;

//========================================================================
// Fülle Datums-Array
//
//========================================================================
sub FuelleDatArray(aBeginn : date; aEnde : date);
local begin
  vBeginn     : date;
  vEnde       : date;
  vDateInt    : int;
  i           : int;
end;
begin
  vBeginn       # aBeginn;
  vEnde         # aEnde;
  i # 1;
  While (vBeginn <= vEnde) do begin

    vDateArray[i] # vBeginn;
    vDateInt      # cnvID(vBeginn);
    vDateInt      # vDateInt + 1;
    vBeginn       # cnvDI(vDateInt);
    i # i+1;
  END;
end;

//========================================================================
// Leere Summen
//
//========================================================================
sub LeereSummen();
local begin
  i           : int;
end;
begin
  for i # 1
  loop inc(i)
  while ( i <= 20) do begin
    ResetSum(i);
  end;
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

  // Datum Pflichtfeld
  if (Sel.von.Datum = 0.0.0) then begin
    Msg(001200, 'Startdatum', _WinIcoWarning, _WinDialogOk,0);
    Call('L_BAG_702002');
    RETURN;
  end;

  //Startdatum bis berechnen
  Sel.bis.Datum # BerechneDatbis(Sel.von.Datum);
  // Datums-Array füllen
  FuelleDatArray(Sel.von.Datum, Sel.bis.Datum);

  StartList(vSort,vSortname);  // Liste generieren
end;


//========================================================================
//  SeitenKopf
//
//========================================================================
sub SeitenKopf(aSeite : int);
begin

  WriteTitel();   // Drucke grosse Überschrift

  if (aSeite=1) then begin

    List_Spacing[ 1]  #   0.0;
    List_Spacing[ 2]  #  80.0;
    List_Spacing[ 3]  # 160.0;
    List_Spacing[ 4]  # 240.0;

    StartLine();
    if (Sel.von.Datum <> 0.0.0) and (Sel.bis.Datum <> 0.0.0) then
      Write( 1, 'Datum von ' + DatS(Sel.von.Datum) + ' bis ' + DatS(Sel.bis.Datum) ,n , 0);
    Write(2, 'Aktion: ' + Sel.BAG.Aktion                      ,n , 0);
    Write(3, 'Ressourcegruppe: ' + cnvAI(Sel.BAG.Res.Gruppe)  ,n , 0);
    Write(4, 'Ressource: ' + cnvAI(Sel.BAG.Res.Nummer)        ,n , 0);
    EndLine();
  end;

  StartLine();
  EndLine();

  if (List_XML = n) then begin
    List_Spacing[ 1]  #  0.0;
    List_Spacing[ 2]  # List_Spacing[ 1]  + 32.0;
    List_Spacing[ 3]  # List_Spacing[ 2]  + 24.0;
    List_Spacing[ 4]  # List_Spacing[ 3]  + 24.0;
    List_Spacing[ 5]  # List_Spacing[ 4]  + 24.0;
    List_Spacing[ 6]  # List_Spacing[ 5]  + 24.0;
    List_Spacing[ 7]  # List_Spacing[ 6]  + 24.0;
    List_Spacing[ 8]  # List_Spacing[ 7]  + 24.0;
    List_Spacing[ 9]  # List_Spacing[ 8]  + 24.0;
    List_Spacing[10]  # List_Spacing[ 9]  + 24.0;
    List_Spacing[11]  # List_Spacing[10]  + 24.0;
    List_Spacing[12]  # List_Spacing[11]  + 24.0;

    StartLine(_LF_UnderLine + _LF_Bold);
    Write( 1, 'Maschine    min/t'                        ,n , 0);
    Write( 2, DatS(vDateArray[1])                        ,y , _LF_Date);
    Write( 3, DatS(vDateArray[2])                        ,y , _LF_Date);
    Write( 4, DatS(vDateArray[3])                        ,y , _LF_Date);
    Write( 5, DatS(vDateArray[4])                        ,y , _LF_Date);
    Write( 6, DatS(vDateArray[5])                        ,y , _LF_Date);
    Write( 7, DatS(vDateArray[6])                        ,y , _LF_Date);
    Write( 8, DatS(vDateArray[7])                        ,y , _LF_Date);
    Write( 9, DatS(vDateArray[8])                        ,y , _LF_Date);
    Write(10, DatS(vDateArray[9])                        ,y , _LF_Date);
    Write(11, DatS(vDateArray[10])                       ,y , _LF_Date);
    EndLine();

  end else begin
    List_Spacing[ 1]  #  0.0;
    List_Spacing[ 2]  # List_Spacing[ 1]  + 32.0;
    List_Spacing[ 3]  # List_Spacing[ 2]  + 12.0;
    List_Spacing[ 4]  # List_Spacing[ 3]  + 12.0;
    List_Spacing[ 5]  # List_Spacing[ 4]  + 12.0;
    List_Spacing[ 6]  # List_Spacing[ 5]  + 12.0;
    List_Spacing[ 7]  # List_Spacing[ 6]  + 12.0;
    List_Spacing[ 8]  # List_Spacing[ 7]  + 12.0;
    List_Spacing[ 9]  # List_Spacing[ 8]  + 12.0;
    List_Spacing[10]  # List_Spacing[ 9]  + 12.0;
    List_Spacing[11]  # List_Spacing[10]  + 12.0;
    List_Spacing[12]  # List_Spacing[11]  + 12.0;
    List_Spacing[13]  # List_Spacing[12]  + 12.0;
    List_Spacing[14]  # List_Spacing[13]  + 12.0;
    List_Spacing[15]  # List_Spacing[14]  + 12.0;
    List_Spacing[16]  # List_Spacing[15]  + 12.0;
    List_Spacing[17]  # List_Spacing[16]  + 12.0;
    List_Spacing[18]  # List_Spacing[17]  + 12.0;
    List_Spacing[19]  # List_Spacing[18]  + 12.0;
    List_Spacing[20]  # List_Spacing[19]  + 12.0;
    List_Spacing[21]  # List_Spacing[20]  + 12.0;
    List_Spacing[22]  # List_Spacing[21]  + 12.0;

    StartLine();
    Write( 1, 'Maschine    min/t'                        ,n , 0);
    Write( 2, DatS(vDateArray[1])                        ,y , _LF_Date);
    Write( 3, DatS(vDateArray[1])                        ,y , _LF_Date);
    Write( 4, DatS(vDateArray[2])                        ,y , _LF_Date);
    Write( 5, DatS(vDateArray[2])                        ,y , _LF_Date);
    Write( 6, DatS(vDateArray[3])                        ,y , _LF_Date);
    Write( 7, DatS(vDateArray[3])                        ,y , _LF_Date);
    Write( 8, DatS(vDateArray[4])                        ,y , _LF_Date);
    Write( 9, DatS(vDateArray[4])                        ,y , _LF_Date);
    Write(10, DatS(vDateArray[5])                        ,y , _LF_Date);
    Write(11, DatS(vDateArray[5])                        ,y , _LF_Date);
    Write(12, DatS(vDateArray[6])                        ,y , _LF_Date);
    Write(13, DatS(vDateArray[6])                        ,y , _LF_Date);
    Write(14, DatS(vDateArray[7])                        ,y , _LF_Date);
    Write(15, DatS(vDateArray[7])                        ,y , _LF_Date);
    Write(16, DatS(vDateArray[8])                        ,y , _LF_Date);
    Write(17, DatS(vDateArray[8])                        ,y , _LF_Date);
    Write(18, DatS(vDateArray[9])                        ,y , _LF_Date);
    Write(19, DatS(vDateArray[9])                        ,y , _LF_Date);
    Write(20, DatS(vDateArray[10])                       ,y , _LF_Date);
    Write(21, DatS(vDateArray[10])                       ,y , _LF_Date);
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
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'Maschine' : begin
      List_Spacing[ 1]  #  0.0;
      List_Spacing[ 2]  # List_Spacing[ 1]  + 32.0;
      List_Spacing[ 3]  # List_Spacing[ 2]  + 12.0;
      List_Spacing[ 4]  # List_Spacing[ 3]  + 12.0;
      List_Spacing[ 5]  # List_Spacing[ 4]  + 12.0;
      List_Spacing[ 6]  # List_Spacing[ 5]  + 12.0;
      List_Spacing[ 7]  # List_Spacing[ 6]  + 12.0;
      List_Spacing[ 8]  # List_Spacing[ 7]  + 12.0;
      List_Spacing[ 9]  # List_Spacing[ 8]  + 12.0;
      List_Spacing[10]  # List_Spacing[ 9]  + 12.0;
      List_Spacing[11]  # List_Spacing[10]  + 12.0;
      List_Spacing[12]  # List_Spacing[11]  + 12.0;
      List_Spacing[13]  # List_Spacing[12]  + 12.0;
      List_Spacing[14]  # List_Spacing[13]  + 12.0;
      List_Spacing[15]  # List_Spacing[14]  + 12.0;
      List_Spacing[16]  # List_Spacing[15]  + 12.0;
      List_Spacing[17]  # List_Spacing[16]  + 12.0;
      List_Spacing[18]  # List_Spacing[17]  + 12.0;
      List_Spacing[19]  # List_Spacing[18]  + 12.0;
      List_Spacing[20]  # List_Spacing[19]  + 12.0;
      List_Spacing[21]  # List_Spacing[20]  + 12.0;
      List_Spacing[22]  # List_Spacing[21]  + 12.0;

      StartLine();
      Write(1,  vMaschine                                  ,n , 0);
      Write(2,  ZahlF(GetSum(1),0)                         ,y , _LF_Int);
      Write(3,  ZahlF(GetSum(2),1)                         ,y , _LF_Num);
      Write(4,  ZahlF(GetSum(3),0)                         ,y , _LF_Int);
      Write(5,  ZahlF(GetSum(4),1)                         ,y , _LF_Num);
      Write(6,  ZahlF(GetSum(5),0)                         ,y , _LF_Int);
      Write(7,  ZahlF(GetSum(6),1)                         ,y , _LF_Num);
      Write(8,  ZahlF(GetSum(7),0)                         ,y , _LF_Int);
      Write(9,  ZahlF(GetSum(8),1)                         ,y , _LF_Num);
      Write(10, ZahlF(GetSum(9),0)                         ,y , _LF_Int);
      Write(11, ZahlF(GetSum(10),1)                        ,y , _LF_Num);
      Write(12, ZahlF(GetSum(11),0)                        ,y , _LF_Int);
      Write(13, ZahlF(GetSum(12),1)                        ,y , _LF_Num);
      Write(14, ZahlF(GetSum(13),0)                        ,y , _LF_Int);
      Write(15, ZahlF(GetSum(14),1)                        ,y , _LF_Num);
      Write(16, ZahlF(GetSum(15),0)                        ,y , _LF_Int);
      Write(17, ZahlF(GetSum(16),1)                        ,y , _LF_Num);
      Write(18, ZahlF(GetSum(17),0)                        ,y , _LF_Int);
      Write(19, ZahlF(GetSum(18),1)                        ,y , _LF_Num);
      Write(20, ZahlF(GetSum(19),0)                        ,y , _LF_Int);
      Write(21, ZahlF(GetSum(20),1)                        ,y , _LF_Num);

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
  Erx         : int;
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vGruppe     : alpha;
  vMas        : alpha;
  vDateInt1   : int;
  vDateInt2   : int;
  vPosition   : int;
  vTag        : float;
  vQ          : alpha(4000);
  tErx        : int;
end;
begin

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);             // starte Landscape

  //Umrechnung Startdatum aus Selektionsdialog
  vDateInt1 # cnvID(Sel.von.Datum);                 //

  // Selektionsquery für 702
  vQ # '';
  Lib_Sel:QVonBisD( var vQ, 'BAG.P.Plan.StartDat', Sel.von.Datum, Sel.bis.Datum );
  vQ # vQ + ' AND !BAG.P.ExternYN '
  if ( Sel.BAG.Aktion != '' ) then
    Lib_Sel:QAlpha( var vQ, 'BAG.P.Aktion', '=', Sel.BAG.Aktion );
  if ( Sel.BAG.Res.Gruppe != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource.Grp', '=', Sel.BAG.Res.Gruppe );
  if ( Sel.BAG.Res.Nummer != 0 ) then
    Lib_Sel:QInt( var vQ, 'BAG.P.Ressource', '=', Sel.BAG.Res.Nummer );

  // Selektion starten...
  vSel # SelCreate( 702, 0 );
  vSel->SelAddSortFld(2, 17, _KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2, 18, _KeyFldAttrUpperCase);
  vSel->SelAddSortFld(2,  5, _KeyFldAttrUpperCase);
  tErx # vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  //vSelName # Sel_Build(vSel, 702, cSel,y,0);
  vFlag # _RecFirst;
  WHILE (RecRead(702,vSel,vFlag) <= _rLocked ) DO BEGIN
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (BAG.P.Ressource.Grp = 0) or (BAG.P.Ressource = 0) then CYCLE;

    Erx # RecLink(160,702,11,_RecFirst);
    if (Erx > _rLocked) then RecBufClear(160);

    Erx # RecLink(701,702,2,_RecFirst);
    if (Erx > _rLocked) then RecBufClear(701);

    // Startdatum des Datensatzes
       vDateInt2    # cnvID(BAG.P.Plan.StartDat);

    if (vGruppe = cnvAI(BAG.P.Ressource.Grp) or (vGruppe = '')) and
       (vMas    = cnvAI(BAG.P.Ressource)     or (vMas = '')) then begin

       // hier wird Plandauer summiert
       vPosition    # (vDateInt2 - vDateInt1)+1;        // Position des Datums im Array bestimmen
       vPosition    # (vPosition * 2)-1;                // Position des Summanden bestimmen
       AddSum(vPosition, BAG.P.Plan.Dauer);
 /*
       //wenn Dauer größer als 1 Tag(1440 min.), dann auf darauffolgende Tage aufteilen
       vTag         # GetSum(vPosition);
       While (vTag > 1440.0) do begin
          SetSum(vPosition, 1440.0);
          vPosition # vPosition + 2;
          vTag      # vTag - 1440.0;
          if (vTag <= 1440.0) then
            SetSum(vPosition, vTag);
       END;
 */
       // hier wird Einsatzgewicht summiert
       vPosition    # (vDateInt2 - vDateInt1)+1;        // Position des Datums im Array bestimmen
       vPosition    # (vPosition * 2);                  // Position des Summanden bestimmen
       if (BAG.IO.BruderID = 0) then
          AddSum(vPosition, BAG.IO.Plan.Out.GewN/1000.0);

       vMaschine # Rso.Stichwort;                       // Maschine merken

    end
    else begin
      //hier wird geschrieben
      Print('Maschine');
      //Summierungen geleert
      LeereSummen();
      //neue Maschine
      //wieder summieren für nächste Maschine
      vPosition    # (vDateInt2 - vDateInt1)+1;        // Position des Datums im Array bestimmen
      vPosition    # (vPosition * 2)-1;                // Position des Summanden bestimmen
      AddSum(vPosition, BAG.P.Plan.Dauer);
 /*
      //wenn Dauer größer als 1 Tag(1440 min.), dann auf darauffolgende Tage aufteilen
       vTag         # GetSum(vPosition);
       While (vTag > 1440.0) do begin
          SetSum(vPosition, 1440.0);
          vPosition # vPosition + 2;
          vTag      # vTag - 1440.0;
          if (vTag <= 1440.0) then
            SetSum(vPosition, vTag);
       END;
 */
      // hier wird Einsatzgewicht summiert
      vPosition    # (vDateInt2 - vDateInt1)+1;       // Position des Datums im Array bestimmen
      vPosition    # (vPosition * 2);                 // Position des Summanden bestimmen
      if (BAG.IO.BruderID = 0) then
         AddSum(vPosition, BAG.IO.Plan.Out.GewN/1000.0);

      vMaschine # Rso.Stichwort;                      // Maschine merken

    end;
    vGruppe # cnvAI(BAG.P.Ressource.Grp);
    vMas    # cnvAI(BAG.P.Ressource);

  END;

  //letzten Datensatz schreiben
  Print('Maschine');
  //Summierungen geleert
  LeereSummen();

  SelClose(vSel);
  SelDelete(702, vSelName);
  vSel # 0;

  ListTerm();
end;

//========================================================================