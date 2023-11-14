@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_200005
//                    OHNE E_R_G
//  Info        Ökonomischer Lagervorrat
//
//
//  15.07.2008  MS  Erstellung der Prozedur
//  28.07.2008  MS  QUERY
//  12.03.2009  ST  Selektionskriterium Gütenstufe hinzugefügt
//  13.06.2022  AH  ERX
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
end;

local begin
  Abmessung   : alpha(120);
  Dicke       : float;
  Warengruppe : int;
  vItem       : int;
end;

declare StartList(aSort : int; aSortName : alpha);
declare AusSel();


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vSort : int;
  vSortName : alpha;
end;
begin
  RecBufClear(998);

  Sel.Mat.von.Wgr       # 0;
  Sel.Mat.bis.WGr       # 9999;
  Sel.Mat.bis.Dicke     # 999999.00;
  Sel.Mat.bis.Breite    # 999999.00;
  "Sel.Mat.bis.Länge"   # 999999.00;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.200005',here+':AusSel');
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
  /*
  vHdl # WinOpen('Lfm.Sortierung',_WinOpenDialog);
  vHdl2 # vHdl->WinSearch('Dl.Sort');
  vHdl2->WinLstDatLineAdd('Belegnummer');
  vHdl2->WinLstDatLineAdd('Rechnungsnummer');
  vHdl2->wpcurrentint # 1;
  vHdl->WinDialogRun(_WindialogCenter,gMdi);
  vHdl2->WinLstCellGet(vSortname, 1, _WinLstDatLineCurrent);
  vHdl->WinClose();
  if (gSelected=0) then RETURN;
  vSort # gSelected;
  gSelected # 0;
  */
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

/*
      Write(, ZahlI()                         ,y ,_LF_INT);
      if (<>0.0.0) then
        Write(, DatS()                       ,y ,_LF_Date);
      Write(,ZahlF(,)          ,y ,_LF_Num  );
      Write(,ZahlF(Erl.NettoW1,2)                            ,y ,_LF_Wae);
*/

    'MERKE' : begin
       if (cnvia(vItem->spcustom)=200) then begin
        Abmessung   # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Mat.Breite,Set.Stellen.Breite) + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
        Warengruppe # Mat.Warengruppe;
        Dicke       # Mat.Dicke;
       end;

       if (cnvia(vItem->spcustom)=401) then begin
        Abmessung   # ANum(Auf.P.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Auf.P.Breite,Set.Stellen.Breite) + ' x ' + ANum("Auf.P.Länge","Set.Stellen.Länge");
        Warengruppe # Auf.P.Warengruppe;
        Dicke       # Auf.P.Dicke;
       end;
    end;

    '200' : begin
      vAbmessung # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Mat.Breite,Set.Stellen.Breite) + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
      StartLine();
      Write(1, ZahlI(Mat.Warengruppe)                         ,y , _LF_Int);
      Write(2, vAbmessung              ,y ,0);
      Write(3, ZahlF(Mat.Bestand.Gew,0)                 ,y ,_LF_Num);
      if(Mat.Bestand.Gew = 0.0) then begin
        Write(4, ZahlF(Ein.P.Gewicht,0)                 ,y ,_LF_Num);
      end;
      Write(6, ZahlF(GetSum(10),0)                 ,y ,_LF_Num);
      Write(7, ZahlF(GetSum(11),0)                 ,y ,_LF_Num);
      Write(8, ZahlF(GetSum(12),0)                 ,y ,_LF_Num);
      if(List_XML = y) then begin
        Write(10,  Mat.Kommission                 ,y ,0);
        Write(11,  ZahlI(Mat.Status)                  ,n ,_LF_Int);
        Write(12,  ZahlI(Mat.Nummer)                   ,y ,_LF_INT);
        Write(13,  ZahlI(Ein.P.Nummer)                   ,y ,_LF_INT);

      end;
      EndLine();
      ResetSum(10);
      ResetSum(11);
      ResetSum(12);
    end;

    '401' : begin
      vAbmessung # ANum(Auf.P.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Auf.P.Breite,Set.Stellen.Breite) + ' x ' + ANum("Auf.P.Länge","Set.Stellen.Länge");
      StartLine();
      Write(1, ZahlI(Auf.P.Warengruppe)                         ,y , _LF_Int);
      Write(2, vAbmessung              ,y ,0);
      //Write(3, ZahlF(Auf.P.Gewicht,0)                 ,y ,_LF_Num);
      //Write(4, ZahlF(Auf.P.Bestellt.Gew,0)                 ,y ,_LF_Num);
      Write(5, ZahlF(Auf.P.Gewicht,0)                 ,y ,_LF_Num);
      Write(6, ZahlF(GetSum(10),0)                 ,y ,_LF_Num);
      Write(7, ZahlF(GetSum(11),0)                 ,y ,_LF_Num);
      Write(8, ZahlF(GetSum(12),0)                 ,y ,_LF_Num);
      Write(9,  ''                  ,y ,_LF_Wae,3.0);
      Write(10, ''                 ,n ,_LF_Date);
      EndLine();
      ResetSum(10);
      ResetSum(11);
      ResetSum(12);
    end;

    'Pos' : begin
      StartLine();
      Write(1, ZahlI(Warengruppe)                         ,y , _LF_Int);
      Write(2, Abmessung              ,y ,0);
      Write(3, ZahlF(GetSum(4),0)                 ,y ,_LF_Num);
      Write(4, ZahlF(GetSum(5),0)                 ,y ,_LF_Num);
      Write(5, ZahlF(GetSum(6),0)                 ,y ,_LF_Num);
      Write(6, ZahlF(GetSum(10),0)                 ,y ,_LF_Num);
      Write(7, ZahlF(GetSum(11),0)                 ,y ,_LF_Num);
      Write(8, ZahlF(GetSum(12),0)                 ,y ,_LF_Num);

      EndLine();
    end;

    'DickenSumme' : begin
      StartLine(_LF_Overline);
      Write(2, 'DICKEN SUMME:'                                            ,y, 0);
      Write(3, ZahlF(getSum(7),0)                                         ,y, _LF_Num);
      Write(4, ZahlF(getSum(8),0)                                         ,y, _LF_Num);
      Write(5, ZahlF(getSum(9),0)                                         ,y, _LF_Num);
      Write(6, ZahlF(getSum(13),0)                                         ,y, _LF_Num);
      Write(7, ZahlF(getSum(15),0)                                         ,y, _LF_Num);
      Write(8, ZahlF(getSum(17),0)                                         ,y, _LF_Num);
      EndLine();

      StartLine();
      EndLine();
    end;


    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(2, 'GESAMT SUMME:'                                            ,y, 0);
      Write(3, ZahlF(getSum(1),0)                                         ,y, _LF_Num);
      Write(4, ZahlF(getSum(2),0)                                         ,y, _LF_Num);
      Write(5, ZahlF(getSum(3),0)                                         ,y, _LF_Num);
      Write(6, ZahlF(getSum(14),0)                                         ,y, _LF_Num);
      Write(7, ZahlF(getSum(16),0)                                         ,y, _LF_Num);
      Write(8, ZahlF(getSum(18),0)                                         ,y, _LF_Num);
      EndLine();
     end; // Summe



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
  List_Spacing[ 3]  # List_Spacing[ 2] + 55.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 35.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 30.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 35.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Wgr.'                          ,y , 0);
  Write(2, 'Abmessung'                          ,y , 0);
  Write(3, 'Verfügbar'                          ,y , 0);
  Write(4, 'Bestellt'                          ,y , 0);
  Write(5, 'Auftrag'                          ,y , 0);
  Write(6, '<5 Wochen'                          ,y , 0);
  Write(7, '5-9 Wochen'                          ,y , 0);
  Write(8, '>9 Wochen'                          ,y , 0);

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
  vKey        : int;
  vMFile,vMID : int;
  vTree       : int;
  vOK         : logic;
  vSortKey    : alpha;
  vPL         : int;
  vPrinted    : logic;
  vZAu        : int;
  vWgr        : int;
  vAbmessung     : alpha(120);
  vWarengruppe   : int;
  vAbmessungALT  : alpha(120);
  vDicke      : float;
  vFirst      : logic;
  vTage       : int;
  vAuftragsGew : float;

  vQ200       : alpha(4000);
  vQ401       : alpha(4000);
  vQ400       : alpha(4000);
end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ200 # '';
  if (Sel.Mat.von.WGr != 0 ) or ( Sel.Mat.bis.WGr != 9999) then
    Lib_Sel:QVonBisI( var vQ200, 'Mat.Warengruppe', Sel.Mat.von.WGr, Sel.Mat.bis.WGr );
  if (Sel.Mat.von.Dicke != 0.0 ) or (Sel.Mat.bis.Dicke  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ200, 'Mat.Dicke',Sel.Mat.von.Dicke ,Sel.Mat.bis.Dicke);
  if (Sel.Mat.von.Breite!= 0.0 ) or (Sel.Mat.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ200, 'Mat.Breite',Sel.Mat.von.Breite ,Sel.Mat.bis.Breite);
  if ("Sel.Mat.von.Länge"!= 0.0 ) or ("Sel.Mat.bis.Länge"!= 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ200, '"Mat.Länge"',"Sel.Mat.von.Länge" ,"Sel.Mat.bis.Länge");
  if ("Sel.Mat.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ200, '"Mat.Güte"', '=', "Sel.Mat.Güte");
  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ200, '"Mat.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");


  Lib_Sel:QAlpha(var vQ200, '"Mat.Löschmarker"', '=', '');

  vQ401 # '';
  if (Sel.Mat.von.WGr != 0 ) or ( Sel.Mat.bis.WGr != 9999 ) then
    Lib_Sel:QVonBisI( var vQ401, 'Auf.P.Warengruppe', Sel.Mat.von.WGr, Sel.Mat.bis.WGr );
  if (Sel.Mat.von.Dicke != 0.0 ) or (Sel.Mat.bis.Dicke  != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, 'Auf.P.Dicke',Sel.Mat.von.Dicke ,Sel.Mat.bis.Dicke);
  if (Sel.Mat.von.Breite!= 0.0 ) or (Sel.Mat.bis.Breite != 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, 'Auf.P.Breite',Sel.Mat.von.Breite ,Sel.Mat.bis.Breite);
  if ("Sel.Mat.von.Länge"!= 0.0 ) or ("Sel.Mat.bis.Länge"!= 999999.00 ) then
    Lib_Sel:QVonBisF( var vQ401, '"Auf.P.Länge"',"Sel.Mat.von.Länge" ,"Sel.Mat.bis.Länge");
  if ("Sel.Mat.Güte" != '' ) then
    Lib_Sel:QAlpha( var vQ401, '"Auf.P.Güte"', '=', "Sel.Mat.Güte");
  if ("Sel.Mat.Gütenstufe" != '') then
    Lib_Sel:QAlpha(var vQ401, '"Auf.P.Gütenstufe"', '=*', "Sel.Mat.Gütenstufe");
  Lib_Sel:QAlpha(var vQ401, '"Auf.P.Löschmarker"', '=', '');
  if (vQ401 != '') then vQ401 # vQ401 + ' AND ';
  vQ401 # vQ401 + ' LinkCount(Kopf) > 0 ';

  vQ400 # '(Auf.Vorgangstyp=''' + c_AUF + ''')';


  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Selektion starten...
  vSel # SelCreate(200, 1 );
  vSel->SelDefQuery( '', vQ200 );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  vFlag # _RecFirst;
  WHILE (RecRead(200,vSel,vFlag) <= _rLocked ) DO BEGIN // Material loopen
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    //if("Mat.Löschmarker"='') then begin
    vSortKey # cnvAI(Mat.Warengruppe,_FmtNumLeadZero,0,7)+ cnvAF(Mat.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)
    +cnvAF(Mat.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Mat.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);

    Sort_ItemAdd(vTree,vSortKey,200,RecInfo(200,_RecId));
    //end;
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(200, vSelName);

  // Selektion starten...
  vSel # SelCreate(401, 1 );
  vSel->SelAddLink('', 400, 401, 3, 'Kopf');
  Erx # vSel->SelDefQuery( '', vQ401 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery('Kopf', vQ400);
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  vFlag # _RecFirst;
  WHILE (RecRead(401,vSel,vFlag) <= _rLocked ) DO BEGIN // Auftraege loopen
    if (vFlag=_RecFirst) then vFlag # _RecNext;
    //if("Auf.P.Löschmarker"='') then begin
    vSortKey # cnvAI(Auf.P.Warengruppe,_FmtNumLeadZero,0,7)+ cnvAF(Auf.P.Dicke,_FmtNumLeadZero|_fmtNumNoGroup,0,3,8)
    +cnvAF(Auf.P.Breite,_FmtNumLeadZero|_fmtNumNoGroup,0,2,10)+cnvAF("Auf.P.Länge",_FmtNumLeadZero|_fmtNumNoGroup,0,0,12);

    Sort_ItemAdd(vTree,vSortKey,401,RecInfo(401,_RecId));
    //end;
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(401, vSelName);



  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;
  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin



    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID


    if (cnvia(vItem->spcustom)=200) then begin
      RecRead(200,1,0);                                    // Materialkarte lesen

      Erx # RecLink(501,200,18,0);                         // Bestellung holen
      if(Erx>_rLocked)then begin
        Erx # RecLink(511,200,19,0);                       // ~ Bestellung holen
        if(Erx<=_rLocked)then begin
          RecBufCopy(511,501);
        end
        else begin
          RecBufClear(501);
          RecBufClear(511);
        end;
      end;

    end;



    /*
    AddSum
      1 : GesamtBestand
      2 : GesamtBestellt
      3 : GesamtAuftrag
      4 : SelbePosBestand
      5 : SelbePosBestellt
      6 : SelbePosAuftrag
      7 : DickenSummeBestand
      8 : DickenSummeBestellt
      9 : DickenSUmmeAuftrag
     10 : <5 WOCHEN
     11 : 5 - 9 WOCHEN
     12 : >9 WOCHEN
     13 : <5 WOCHEN DickenSummeBestand
     14 : 5 - 9 WOCHEN DickenSummeBestellt
     15 : >9 WOCHEN DickenSUmmeAuftrag
     16 : <5 WOCHEN Gesamt
     17 : 5 - 9 WOCHEN Gesamt
     18 : >9 WOCHEN Gesamt
    */


    if (cnvia(vItem->spcustom)=200) then begin
      vAbmessung # ANum(Mat.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Mat.Breite,Set.Stellen.Breite) + ' x ' + ANum("Mat.Länge","Set.Stellen.Länge");
      vWarengruppe # Mat.Warengruppe;
      vDicke      # Mat.Dicke;
    end;
    if (cnvia(vItem->spcustom)=401) then begin
      vAbmessung # ANum(Auf.P.Dicke,Set.Stellen.Dicke) + ' x ' + ANum(Auf.P.Breite,Set.Stellen.Breite) + ' x ' + ANum("Auf.P.Länge","Set.Stellen.Länge");
      vWarengruppe # Auf.P.Warengruppe;
      vDicke      # Auf.P.Dicke;
    end;
    if (vFirst = y ) then begin
      Print('MERKE');             // Abmessung und Warengruppe merken !
      vFirst # n;
    end;


    // PRINT
    //  if (cnvia(vItem->spcustom)=200) then PRINT('200');
    //  if (cnvia(vItem->spcustom)=401) then PRINT('401');



    if (vAbmessung <> Abmessung) or (vWarengruppe <> Warengruppe) then begin
      Print('Pos');                 // Zusammengefasste Position drucken !
      ResetSum(4);
      ResetSum(5);
      ResetSum(6);
      ResetSum(10);
      ResetSum(11);
      ResetSum(12);
    end;

    if (vDicke <> Dicke) or (vWarengruppe <> Warengruppe)  then begin
      Print('DickenSumme');       // Dickensumme drucken
      ResetSum(7);
      ResetSum(8);
      ResetSum(9);
      ResetSum(13);
      ResetSum(15);
      ResetSum(17);
    end;


    // Tage ermitteln
    if (cnvia(vItem->spcustom)=200) and (Mat.Bestand.Gew <> 0.0) then begin
      vTage # 0;// Gewicht in unter 5 Wochen addieren !
      AddSum(10,Mat.Bestand.Gew);
      AddSum(13,Mat.Bestand.Gew);
      AddSum(14,Mat.Bestand.Gew);
    end
    else if (cnvia(vItem->spcustom)=200) and (Mat.Bestand.Gew = 0.0) then begin
      vTage # cnvID(Ein.P.Termin1Wunsch) - cnvID(today);
      if(vTage < 35) then begin
        AddSum(10,Ein.P.Gewicht);
        AddSum(13,Ein.P.Gewicht);
        AddSum(14,Ein.P.Gewicht);
      end
      else if (vTage >= 35 and vTage <= 63) then begin
        AddSum(11,Ein.P.Gewicht);
        AddSum(15,Ein.P.Gewicht);
        AddSum(16,Ein.P.Gewicht);
      end
      else if (vTage > 63) then begin
        AddSum(12,Ein.P.Gewicht);
        AddSum(17,Ein.P.Gewicht);
        AddSum(18,Ein.P.Gewicht);
      end;
    end;
    if (cnvia(vItem->spcustom)=401) then begin
      vTage # cnvID(Auf.P.Termin1Wunsch) - cnvID(today);
      vTage # vTage;
      vAuftragsGew # Auf.P.Gewicht*-1.0;
      if(vTage < 35) then begin
        AddSum(10,vAuftragsGew);
        AddSum(13,vAuftragsGew)
        AddSum(14,vAuftragsGew)
      end
      else if (vTage >= 35 and vTage <= 63) then begin
        AddSum(11,vAuftragsGew);
        AddSum(15,vAuftragsGew);
        AddSum(16,vAuftragsGew);
      end
      else if (vTage > 63) then begin
        AddSum(12,vAuftragsGew);
        AddSum(17,vAuftragsGew);
        AddSum(18,vAuftragsGew);
      end;
    end;


    // GESAMTSUMMEN und DICKEN SUMME und Aufsummierung der selben Positionen
    if (cnvia(vItem->spcustom)=200) and (Mat.Bestand.Gew <> 0.0) then begin
      AddSum(1,Mat.Bestand.Gew);    // Vorrat
      AddSum(4,Mat.Bestand.Gew);
      AddSum(7,Mat.Bestand.Gew);    // Vorrat
    end
    else if (cnvia(vItem->spcustom)=200) and (Mat.Bestand.Gew = 0.0)  then begin
      AddSum(2,Ein.P.Gewicht);
      AddSum(5,Ein.P.Gewicht);
      AddSum(8,Ein.P.Gewicht);
    end;

    if (cnvia(vItem->spcustom)=401) then begin
      if(Auf.P.Gewicht <> 0.0) then begin
        AddSum(3,Auf.P.Gewicht);    // Auftrag
        AddSum(6,Auf.P.Gewicht);
        AddSum(9,Auf.P.Gewicht);
      end;
    end;

    Print('MERKE');  // Abmessung und Warengruppe merken !

  END;  // loop

  Print('Pos');                 // Zusammengefasste Position drucken !
  Print('DickenSumme');
  Print('GesamtSumme');



  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================