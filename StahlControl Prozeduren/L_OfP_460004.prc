@A+
//===== Business-Control =================================================
//
//  Prozedur    L_OfP_460004
//                    OHNE E_R_G
//  Info        Gutschriften und Belastungen
//
//
//  29.07.2008  MS  Erstellung der Prozedur
//  29.07.2008  MS  QUERY
//  2022-06-28  AH  ERX
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

  gMDI # Lib_GuiCom:AddChildWindow(gMDI,'Sel.LST.460004',here+':AusSel');
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



    'Pos' : begin
      StartLine();
      Write(1, ZahlI(OfP.Rechnungsnr)                     ,y , _LF_Int);
      Write(2, DatS(OfP.Rechnungsdatum)           ,n ,_LF_Date,3.0);
      Write(3, DatS(OfP.Zieldatum)                 ,n ,_LF_Date);
      Write(4, OfP.KundenStichwort                ,n ,0);
      Write(5, ZahlF(OfP.NettoW1,2)                 ,y ,_LF_Wae);
      EndLine();
    end;




    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(5, ZahlF(getSum(1),2)                                         ,y, _LF_Num);
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
  List_Spacing[ 2]  # List_Spacing[ 1] + 25.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 25.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 45.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 25.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 30.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 30.0;
  List_Spacing[10]  # List_Spacing[ 9] + 30.0;
  List_Spacing[11]  # List_Spacing[10] + 35.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Re.-Nr.'                         ,y , 0);
  Write(2, 'Anlage'                          ,n , 0,3.0);
  Write(3, 'Wertstell.'                      ,n , 0);
  Write(4, 'Empfänger'                       ,n , 0);
  Write(5, 'Betrag'                          ,y , 0);
  /*
  Write(6, ''                          ,y , 0);
  Write(7, ''                          ,y , 0);
  Write(8, ''                          ,y , 0);
  */
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
  vItem       : int;

  vQ460       : alpha(4000);
  vQ450       : alpha(4000);

end;
begin

  // Liste starten
  ListInit(n); // mit Landscape
  // Selektionsquery
  vQ460 # '';
  vQ450 # '';

  Lib_Sel:QVonBisD(var vQ460, 'OfP.Rechnungsdatum', Sel.von.Datum, Sel.bis.Datum);
  vQ460 # vQ460 + ' AND LinkCount(Erl) > 0';

  // Nur Belastungen und Gutschriften
  vQ450 # 'Erl.Rechnungstyp = 410 OR Erl.Rechnungstyp = 420';

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(460, 1 );
  vSel->SelAddLink('',450,460,2,'Erl');
  Erx # vSel->SelDefQuery( '', vQ460 );
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  Erx # vSel->SelDefQuery( 'Erl', vQ450 );
  if (Erx <> 0) then Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  vFlag # _RecFirst;
  WHILE (RecRead(460,vSel,vFlag) <= _rLocked ) DO BEGIN // Offene Posten loopen
    if (vFlag=_RecFirst) then vFlag # _RecNext;

    vSortKey # cnvAI(OfP.Rechnungsnr);

    Sort_ItemAdd(vTree,vSortKey,460,RecInfo(460,_RecId));

  END;



  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(460, vSelName);

  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  vFirst # y ;

  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID
    /*
    RecLink(450,460,2,0);
    */

    /*
    AddSum
      1 : GesamtBestand
      2 : GesamtBestellt
      3 : GesamtAuftrag
    */
      Print('Pos');                 // Zusammengefasste Position drucken !
      AddSum(1,OfP.NettoW1);

  END;  // loop

  Print('GesamtSumme');



  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================