@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Erl_450011
//                    OHNE E_R_G
//  Info      Rechnungsausgangsliste NEU
//
//
//  01.08.2008  MS  Erstellung der Prozedur
//  01.08.2008  MS  QUERY
//  10.03.2010  ST  Kundenselektion eingebaut
//  22.10.2010  AU  NEU: Steuer
//  29.08.2016  TM  NEU: Gesamtsumme Gewicht Prj. 1601/48 WSB
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
  cSumNetto   : 1
  cSumSteuer  : 2
  cSumBrutto  : 3
  cSumGew     : 4
end;

local begin
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
  Sel.bis.Datum # today;
  Sel.Fin.bis.Rechnung # 9999999;
  Sel.Auf.Kundennr     # 0;

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.450011',here+':AusSel');
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
  vHdl2->WinLstDatLineAdd('Kunde');
  vHdl2->WinLstDatLineAdd('Rechnungsdatum');
  vHdl2->wpcurrentint # 1;
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
Sub Print(aName : alpha);
local begin
  vAbmessung : alpha;
end;
begin

  case aName of

    'Pos' : begin

      StartLine();
      Write(1,  ZahlI(Erl.Rechnungsnr)                     ,y , _LF_Int);
      if (Erl.Rechnungsdatum <> 0.0.0) then
        Write(2, Dats(Erl.Rechnungsdatum)                 ,n , _LF_Date, 3.0);
      Write(3,  ZahlI(Auf.P.Nummer)                       ,y , _LF_Int);
      Write(4,  ZahlI(Auf.P.Projektnummer)                ,y , _LF_Int, 3.0);
      Write(5,  Erl.KundenStichwort                       ,n , 0);
      Write(6,  ZahlI(Erl.Kundennummer)                ,y , _LF_Int, 3.0);
      Write(7,  ZahlF(Erl.Gewicht,Set.Stellen.Gewicht)  ,y , _LF_Num, 3.0);
      Write(8,  ZahlF(Erl.NettoW1,2)                      ,y , _LF_Num, 3.0);
      Write(9,  ZahlF(Erl.SteuerW1,2)                     ,y , _LF_Num, 3.0);
      Write(10, ZahlF(Erl.BruttoW1,2)                     ,y , _LF_Num, 3.0);
      if (OfP.Zieldatum <> 0.0.0) then
        Write(11, Dats(OfP.Zieldatum)                      ,n , _LF_Date);
      EndLine();

      Addsum(cSumNetto, Erl.NettoW1);
      Addsum(cSumSteuer, Erl.SteuerW1);
      Addsum(cSumBrutto, Erl.BruttoW1);
      Addsum(cSumGew, Erl.Gewicht);
    end;



    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(5, 'GESAMT SUMME:'              ,y, 0);
      Write(7, ZahlF(GetSum(cSumGew),Set.Stellen.Gewicht)   ,y, _LF_Num, 3.0);
      Write(8, ZahlF(GetSum(cSumNetto),2)   ,y, _LF_Num, 3.0);
      Write(9, ZahlF(GetSum(cSumSteuer),2)  ,y, _LF_Num, 3.0);
      Write(10, ZahlF(GetSum(cSumBrutto),2)  ,y, _LF_Num, 3.0);
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

  List_Spacing[ 1]  #  0.0;                       //
  List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;    // Renr
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;    // ReDat
  List_Spacing[ 4]  # List_Spacing[ 3] + 20.0;    // Aufnr  25
  List_Spacing[ 5]  # List_Spacing[ 4] + 25.0;    // Projekt
  List_Spacing[ 6]  # List_Spacing[ 5] + 40.0;    // Kunde
  List_Spacing[ 7]  # List_Spacing[ 6] + 25.0;    // Gew. Lohn    46
  List_Spacing[ 8]  # List_Spacing[ 7] + 25.0;    // Gew. Voll  46
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;    // Netto    25
  List_Spacing[10]  # List_Spacing[ 9] + 25.0;    // Steuer
  List_Spacing[11]  # List_Spacing[10] + 25.0;    // Brutto
  List_Spacing[12]  # List_Spacing[11] + 25.0;    // Fälligkeit 40

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'ReNr.'        ,y , 0);
  Write(2,  'ReDat.'       ,n , 0, 3.0);
  Write(3,  'AufNr.'       ,y , 0);
  Write(4,  'PrjNr.'       ,y , 0, 3.0);
  Write(5,  'Kunde'        ,n , 0);
  Write(6,  'KundenNr.'       ,y , 0, 3.0);
  Write(7,  'Gewicht'       ,y , 0, 3.0);
  Write(8,  'Netto €'      ,y , 0, 3.0);
  Write(9,  'Steuer'       ,y , 0, 3.0);
  Write(10, 'Brutto'       ,y , 0, 3.0);
  Write(11, 'Fälligkeit'   ,n , 0);
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

  vQ203       : alpha(4000);
  vQ450       : alpha(4000);

end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ450 # '';
  Lib_Sel:QVonBisD( var vQ450, 'Erl.Rechnungsdatum',Sel.von.Datum ,Sel.bis.Datum);
  if(Sel.Fin.bis.Rechnung  <>  9999999) and (Sel.Fin.von.Rechnung  <> 0) then
    Lib_Sel:QVonBisI( var vQ450, 'Erl.Rechnungsnr', Sel.Fin.von.Rechnung , Sel.Fin.bis.Rechnung);
  if(Sel.Auf.Kundennr != 0) then
    Lib_Sel:QInt( var vQ450, 'Erl.Kundennummer','=', Sel.Auf.Kundennr);

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(450, 1 );
  erx # vSel->SelDefQuery( '', vQ450 );
  if (Erx <> 0) then
    Lib_Sel:QError(vSel);

  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  vFlag # _RecFirst;
  WHILE (RecRead(450,vSel,vFlag) <= _rLocked ) DO BEGIN // Material loopen
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    if (Sel.Fin.LiefGutBelYN=false) then begin
      Erx # RecLink(451,450,1,_RecFirst);   // 1.Erloeskonto holen
      if (Erx<=_rLocked) then begin
        Auf.Nummer # Erl.K.Auftragsnr;
        Erx # RecRead(400,1,0);             // Auftrag holen
        if (Erx > _rLocked) then begin
          "Auf~Nummer" # Erl.K.Auftragsnr;
          Erx # RecRead(410,1,0);             // Auftrag holen
          if (Erx > _rLocked) then RecBufClear(400)
          else RecbufCopy(410,400);
        end;
        if (Auf.Vorgangstyp=c_Gut) or (Auf.Vorgangstyp=c_Bel_LF) then CYCLE;
      end;
    end;

    if ( aSort = 1 ) then
      vSortKey # Erl.KundenStichwort;

    if ( aSort = 2 ) then
      vSortKey # AInt(Erl.Rechnungsnr);

    Sort_ItemAdd(vTree,vSortKey,450,RecInfo(450,_RecId));
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(450, vSelName);




  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin


    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    Erx # RecLink(451,450,1,_RecFirst);   // Erloeskonto holen
    if (Erx <= _rLocked) then begin
      Erx # RecLink(401,451,8,_RecFirst);   // Auftrag holen
      if (Erx > _rLocked) then begin
        Erx # RecLink(411,451,9,_RecFirst);
        if (Erx > _rLocked) then begin
          RecBufClear(401);
          RecBufClear(411);
        end
        else
          RecBufCopy(411,401);
      end;
    end;

    Erx # RecLink(460,450,2,_RecFirst);   // Offene Posten holen !
    if (Erx > _rLocked) then begin
      Erx # RecLink(470,450,11,_RecFirst);
      if (Erx > _rLocked) then begin
        RecBufClear(460);
        RecBufClear(470);
      end
      else
        RecBufCopy(470,460);
    end;


    PRINT('Pos');

  END;  // loop

  Print('GesamtSumme');



  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================