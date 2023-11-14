@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Prj_120007
//                    OHNE E_R_G
//  Info        Projekte Zeiten pro User/Tag
//
//
//  04.09.2008  MS  Erstellung der Prozedur
//  04.09.2008  MS  QUERY
//  18.11.2016  AH  Telefonate eingebaut
//  2022-06-28  AH  ERX
//  2023-05-10  AH  Erweiterung
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
@I:Def_aktionen

define begin
  cAuto     : Lfm.Nummer=120500
end;


declare StartList(aSort : int; aSortName : alpha);
declare AusSel();


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort     : int;
  vSortName : alpha;
end;
begin

  RecBufClear(998);
  Sel.Adr.von.Sachbear # gUsername;
  Sel.von.Datum # today;
  Sel.bis.Datum # today;
  GV.Logic.01   # false;
  
  if (cAuto) then begin
    Sel.von.Datum->vmDayModify(-5);
    StartList(1,'AUTO');
    RETURN;
  end;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.120007',here+':AusSel');
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
  vSum  : float;
  vSum2 : float;
  vAbmessung : alpha;
end;
begin

  case aName of

    'POS' : begin
      StartLine();
      Write(1, ZahlI(Prj.Nummer)           ,y , _LF_Int);
      Write(2, ZahlI(Prj.P.Position)       ,y , _LF_Int);
      Write(3, Adr.Stichwort               ,n , 0, 3.0);
      Write(4, Prj.P.Bezeichnung           ,n , 0);
      Write(5, cnvAT(Prj.Z.Start.Zeit)     ,y , 0);
      Write(6, cnvAT(Prj.Z.End.Zeit)       ,y , 0);
      Write(7, ZahlF(Prj.Z.Dauer,2)          ,y , _LF_Num);
      Write(8, Prj.Z.Bemerkung        ,n , 0, 3.0);
      EndLine();
    end;

    'POS_TEM' : begin
      StartLine();
//      Write(1, ZahlI(TeM.Nummer)           ,y , _LF_Int);
//      Write(2, ZahlI(0)                    ,y , _LF_Int);
      Write(3, 'Telefonat'                 ,n , 0, 3.0);
      Write(4, TeM.Bezeichnung             ,n , 0);
      Write(5, cnvAT(TeM.Start.Von.Zeit)   ,y , 0);
      Write(6, cnvAT(TeM.Ende.Bis.Zeit)    ,y , 0);
      Write(7, ZahlF(TeM.Dauer / 60.0,2)   ,y , _LF_Num);
      Write(8, TeM.Bemerkung               ,n , 0, 3.0);
      EndLine();
    end;

    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(7, ZahlF(getSum(1),2)                                         ,y, _LF_Num);
      EndLine();
     end; // Summe

    'StartTag' : begin
      StartLine();
      if (Prj.Z.Start.Datum<>0.0.0) then begin
        Write(1, DatS(Prj.Z.Start.Datum)                         ,y, 0);
        GV.num.11 # 100.0;
        try begin
          ErrTryIgnore(_rlocked,_rNoRec);
          ErrTryCatch(_ErrNoProcInfo,y);
          ErrTryCatch(_ErrNoSub,y);
          GV.num.11 # call('SFX_BCS_App:SollWert',Prj.Z.Start.Datum);
          if (Gv.Num.11>0.0) then GV.Num.11 # GV.Num.11 - 1.0;
        end;
      end;
      EndLine();
     end; // Summe

    'ZwSumme' : begin
      StartLine(_LF_Overline);
      if (GetSum(2)<Gv.Num.11) then
        Lib_PrintLine:Drawbox(0.0, 440.0, RGB(230,130,130), 4.0)
      Write(7, ZahlF(getSum(2),2)                                         ,y, _LF_Num);
      EndLine();

      GV.Num.10 # GetSum(2);  // für AUTO

      ResetSum(2);
     end; // Summe

    'Leer' : begin
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
  WriteTitel();

  StartLine();
  EndLine();
  if (aSeite=1) then begin
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 15.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 30.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 80.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 20.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 80.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 20.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'ProjektNr'        ,y, 0);
  Write(2, 'Pos.'             ,y , 0);
  Write(3, 'Kunde'            ,n , 0, 3.0);
  Write(4, 'Pos.Bezeichnung'  ,n , 0);
  Write(5, 'StartZeit'        ,y , 0);
  Write(6, 'EndZeit'          ,y , 0);
  Write(7, 'Dauer'            ,y ,0);
  Write(8, 'Text'             ,n ,0, 3.0);
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
//========================================================================
Sub DruckeLeere(
  aLast   : date;
  aNext   : date);
local begin
  vDat    : date;
end;
begin
  // LEERE TAGE DRUCKEN
  if (cAuto=false) then RETURN;

  vDat # Prj.Z.Start.Datum;
  WHILE (aLast<aNext) do begin
    aLast->vmDayModify(1);
    Prj.Z.Start.Datum # aLast;
    Print('StartTag');
    Print('ZwSumme');
    Print('Leer');
  END;
  Prj.Z.Start.Datum # vDat;
end;

/**
  vItem2 # Sort_ItemNext(aTree,aItem);
  if (vItem2<>0) then begin
    RecRead(CnvIA(vItem2->spCustom),0,0,vItem2->spID);    // Custom=Dateinr, ID=SatzID
    if (cnvia(vitem2->spCustom)=123) then
      TeM.Start.Von.Datum # Prj.Z.Start.Datum;
  end
  else begin
    TeM.Start.Von.Datum # Sel.Bis.Datum;
  end;
debug('nächster Satr:'+cnvad(TeM.Start.Von.Datum));

  Prj.Z.Start.Datum # aDat;
  Prj.Z.Start.Datum->vmDayModify(1);
  WHILE (Prj.Z.Start.Datum<TeM.Start.Von.Datum) do begin
    Prj.Z.STart.Datum->vmDayModify(1);
debug('+++ auf : '+cnvad(Prj.Z.Start.Datum));
    Print('ZwSumme');
    Print('Leer');
    Print('StartTag');
  END;
end;
end;
**/


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vKey        : int;
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vPrinted    : logic;
  vItem       : int;
  vDatum      : date;
  vFirst      : logic;

  vQ120       : alpha(4000);
  vQ122       : alpha(4000);
  vQ123       : alpha(4000);

  vQ980       : alpha(4000);
  vQ981       : alpha(4000);
  vQ981b      : alpha(4000);
  vMitTelefon : logic;
  Erx         : int;
end;
begin

  if (cAuto) then begin
    vMitTelefon # true;
  end
  else begin
    if (Sel.Adr.von.Sachbear <> '') then
      vMitTelefon # (Msg(99,'Unzugeordnete Telefonate mit einbeziehen?',_WinIcoQuestion,_WinDialogYesNo,2)=_winidyes);
  end;

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  /*
  vQ120 # '';
  vQ122 # '';


  vQ120 # 'LinkCount(PrjPos) > 0';
  vQ122 # 'LinkCount(PosZeit) > 0';
  */
  vQ123 # '';

  if(Sel.Adr.von.Sachbear <> '') then
    Lib_Sel:QAlpha(var vQ123, 'Prj.Z.User' , '=' , Sel.Adr.von.Sachbear);

  Lib_Sel:QvonbisD(var vQ123, 'Prj.Z.End.Datum' , Sel.von.Datum , Sel.bis.Datum);

  // 2023-05-10 AH
  if (GV.Logic.01) then begin
    Lib_Sel:QInt(var vQ123, 'Prj.Z.ZuAuftragsnr' , '=',0);
  end;

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(123, 1 );
  /*
  vSel->SelAddLink('',122,120,4,'PrjPos');
  vSel->SelAddLink('PrjPos',123,122,1,'PosZeit');
  Erx # vSel->SelDefQuery('', vQ120);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('PrjPos', vQ122);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  */
  Erx # vSel->SelDefQuery('', vQ123);
  if (Erx != 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  FOR Erx # RecRead(123,vSel,_recFirst)
  LOOP Erx # RecRead(123,vSel,_recNext)
  WHILE (Erx <= _rLocked ) DO BEGIN // Projekt Zeiten LOOPEN

    if (GV.Logic.01) then begin
      Erx # RecLink(122,123,1,_RecFirst);   // PrjPos holen
      if ("Prj.P.Lösch.datum">0.0.0) then CYCLE;
    end;

    vSortKey # cnvAI(cnvID(Prj.Z.Start.Datum),_FmtNumLeadZero,0,10)
             + cnvAI(cnvID(Prj.Z.End.Datum),_FmtNumLeadZero,0,10)
             + cnvAT(Prj.Z.Start.Zeit)
             + cnvAT(Prj.Z.End.Zeit);
    Sort_ItemAdd(vTree,vSortKey,123,RecInfo(123,_RecId));

  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(123, vSelName);


  if (vMitTelefon) and (Sel.Adr.von.Sachbear <> '') then begin
    Lib_Sel:QAlpha(var vQ980, 'TeM.Typ', '=', 'TEL');
    Lib_Sel:QvonbisD(var vQ980, 'TeM.Start.Von.Datum' , Sel.von.Datum , Sel.bis.Datum);
    Lib_Sel:QFloat(var vQ980, 'TeM.Dauer' , '>=', 1.0);
    vQ980 # vQ980 + ' AND LinkCount(Anker) > 0';
    vQ980 # vQ980 + ' AND LinkCount(Anker2) = 0';

    Lib_Sel:QInt(var vQ981, 'TeM.A.Datei' , '=' , 800);
    Lib_Sel:QAlpha(var vQ981, 'TeM.A.Code' , '=' , Sel.Adr.von.Sachbear);

    Lib_Sel:QInt(var vQ981b, 'TeM.A.Datei' , '=' , 122);

    vSel # SelCreate(980, 1 );
    vSel->SelAddLink('',981,980,1,'Anker');
    vSel->SelAddLink('',981,980,1,'Anker2');
    Erx # vSel->SelDefQuery('', vQ980);
    if (Erx != 0) then Lib_Sel:QError(vSel);
    Erx # vSel->SelDefQuery('Anker', vQ981);
    if (Erx != 0) then Lib_Sel:QError(vSel);
    Erx # vSel->SelDefQuery('Anker2', vQ981b);
    if (Erx != 0) then Lib_Sel:QError(vSel);
    vSelName # Lib_Sel:SaveRun( var vSel, 0);

    FOR Erx # RecRead(980,vSel,_recFirst)
    LOOP Erx # RecRead(980,vSel,_recNext)
    WHILE (Erx <= _rLocked ) DO BEGIN
      vSortKey # cnvAI(cnvID(TeM.Start.Von.Datum),_FmtNumLeadZero,0,10)
               + cnvAI(cnvID(TeM.Start.Bis.Datum),_FmtNumLeadZero,0,10)
               + cnvAT(TeM.Start.Von.Zeit)
               + cnvAT(TeM.Start.Bis.Zeit);
      Sort_ItemAdd(vTree,vSortKey,980,RecInfo(980,_RecId));
    END;
    SelClose(vSel);
    vSel # 0;
    SelDelete(980, vSelName);
  end;



  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # true;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    if (cnvia(vitem->spCustom)=980) then begin
      Prj.Z.Start.Datum # TeM.Start.Von.Datum;
    end
    else begin
      Erx # RekLink(122,123,1,_recFirst);   // Position holen
      Erx # RekLink(120,123,2,_recFirst);   // Projekt holen
      Erx # RekLink(100,120,1,0);           // Adresse holen
    end;

    if (vFirst) then begin
      if (Prj.Z.Start.Datum<>0.0.0) then
        DruckeLeere(Sel.Von.Datum, cnvdi(cnvid(Prj.Z.Start.Datum)-1));
      vDatum # Prj.Z.Start.Datum;
      Print('StartTag');
      vFirst # n;
    end;

    if (vDatum <> Prj.Z.Start.Datum) then begin
      Print('ZwSumme');
      Print('Leer');
      DruckeLeere(cnvdi(cnvid(vDatum)+1), cnvdi(cnvid(Prj.Z.Start.Datum)-1));
      Print('StartTag');
    end;


    if (cnvia(vitem->spCustom)=980) then begin
      if (cAuto=false) then
        Print('POS_TEM');
      AddSum(1,TeM.Dauer / 60.0);
      AddSum(2,TeM.Dauer / 60.0);
    end
    else begin
      if (cAuto=false) then
        Print('POS');
      AddSum(1,Prj.Z.Dauer);
      AddSum(2,Prj.Z.Dauer);
    end;
    vDatum # Prj.Z.Start.Datum;

  END;  // loop

  Print('ZwSumme');
  Print('Leer');
  DruckeLeere(vDatum, Sel.Bis.Datum);
  Print('GesamtSumme');

  // wenn letzter Tag nicht heute war, gibt es auch keine Stunden
  if (vDatum<>Today) then GV.num.10 # 0.0;

  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================