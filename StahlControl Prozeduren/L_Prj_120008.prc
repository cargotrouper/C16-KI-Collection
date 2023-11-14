@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Mat_120008
//                    OHNE E_R_G
//  Info        Projekt Übersichtsliste
//
//
//  26.01.2009  MS  Erstellung der Prozedur
//  26.01.2009  MS  QUERY
//  08.03.2010  ST  Selektions und Sortierung hinzugefügt
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

  "Sel.Fin.GelöschteYN" # false;

  // Abfrage ob auch gelöschte angezeigt werden sollen
  if (Msg(000099,Translate('Auf gelöschte Projekte anzeigen?'),_WinIcoQuestion,_WinDialogYesNo,1)=_WinIdYes) then
    "Sel.Fin.GelöschteYN" # true;

  AusSel();

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
  vHdl2->WinLstDatLineAdd('Adress');
  vHdl2->WinLstDatLineAdd('Projektnummer');
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
Sub Print(aName : alpha);
local begin
  Erx   : int;
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


    'POS' : begin
      StartLine();
      Write(1, "Prj.Löschmarker" + Aint(Prj.Nummer)                                ,y , 0);
      Write(2, ZahlI(Prj.Adressnummer)                                             ,y , _LF_Int);
      Erx # RecLink(100,120,1,0) // Adresse lesen
      if(Erx > _rLocked) then
        RecBufClear(100);
      Write(3,  Adr.Stichwort                                                      ,n , 0, 3.0);
      Write(4,  Prj.Stichwort                                                      ,n , 0);
      Write(5,  Prj.Bemerkung                                                      ,n , 0);
      Write(6,  cnvAD(Prj.Termin.Start) + ' - ' + cnvAD(Prj.Termin.Ende),n , 0);
      Write(7,  ZahlI("Prj.Priorität")                                             ,y , _LF_Int);
      Write(8,  Prj.Projektleiter                                                  ,n , 0, 3.0);
      Write(9,  Prj.Team                                                           ,n , 0);
      EndLine();
    end;

    'GesamtSumme' : begin
      StartLine(_LF_Overline);
      Write(1, 'Summe'                                                    ,n, 0);
      Write(3, ZahlF(getSum(5),0)                                         ,y, _LF_Num);
      Write(4, ZahlF(getSum(6),0)                                         ,y, _LF_Num);
      EndLine();
     end; // Summe

    'ZwSumme' : begin
      StartLine(_LF_Overline);
      Write(1, 'Summe'                                                    ,n, 0);
      Write(3, ZahlF(getSum(3),0)                                         ,y, _LF_Num);
      Write(4, ZahlF(getSum(4),0)                                         ,y, _LF_Num);
      EndLine();
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
  List_Spacing[ 2]  # List_Spacing[ 1] + 15.0; // PrjNr
  List_Spacing[ 3]  # List_Spacing[ 2] + 15.0; // AdrNr
  List_Spacing[ 4]  # List_Spacing[ 3] + 40.0; // AdrSW
  List_Spacing[ 5]  # List_Spacing[ 4] + 45.0; // PrjSW
  List_Spacing[ 6]  # List_Spacing[ 5] + 65.0; // Bem
  List_Spacing[ 7]  # List_Spacing[ 6] + 45.0; // Zeit
  List_Spacing[ 8]  # List_Spacing[ 7] + 15.0; // PrjP
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0; // PrjL
  List_Spacing[10]  # List_Spacing[ 9] + 20.0; // Team
  List_Spacing[11]  # List_Spacing[10] + 30.0; //

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1, 'Prj-Nr.'      ,y , 0);
  Write(2, 'Adr-Nr.'       ,y , 0);
  Write(3, 'Adr.Stichwort'  ,n , 0, 3.0);
  Write(4, 'Prj.Stichwort' ,n , 0);
  Write(5, 'Bemerkung'        ,n , 0);
  Write(6, 'Zeitraum'         ,n , 0);
  Write(7, 'Priorität'    ,y , 0);
  Write(8, 'Prj.Leiter'    ,n , 0, 3.0);
  Write(9, 'Team'             ,n , 0);
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
  vAbmessung  : alpha(120);
  vLKZ        : alpha;
  vGuete      : alpha;
  vAF         : int;
  vFirst      : logic;
  vTage       : int;
  vAuftragsGew : float;

  vQ120       : alpha(4000);
  end;
begin

  // Liste starten
  ListInit(y); // mit Landscape

  // Selektionsquery
  vQ120 # '';

  Lib_Sel:QAlpha(var vQ120, 'Prj.Wartungsinterval', '=', '');
  if !("Sel.Fin.GelöschteYN") then
    Lib_Sel:QAlpha(var vQ120, 'Prj.Löschmarker', '=', '');

  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // --------------------------------------------------
  // Sortierte Liste im Arbeitsspeicher erstellen
  // --------------------------------------------------

  // Selektion starten...
  vSel # SelCreate(120, 1 );
  Erx # vSel->SelDefQuery( '', vQ120);
  if(Erx <> 0) then
    Lib_Sel:QError(vSel);
  vSelName # Lib_Sel:SaveRun( var vSel, 0);

  Erx # RecRead(120,vSel,_recFirst);
  WHILE (Erx <= _rLocked ) DO BEGIN // Projekte loopen

    Erx # RecLink(100,120,1,_recFirst);   // Adresse holen
    if (Erx>_rLocked) then RecBufClear(100);

    if (aSort=1) then   vSortKey # Adr.Stichwort + cnvAI(Prj.Adressnummer) + cnvAI(Prj.Nummer);
    if (aSort=2) then   vSortKey # cnvAI(Prj.Nummer);

    Sort_ItemAdd(vTree,vSortKey,120,RecInfo(120,_RecId));
    Erx # RecRead(120,vSel,_recNext);
  END;

  // Selektion loeschen
  SelClose(vSel);
  vSel # 0;
  SelDelete(120, vSelName);

  // AUSGABE ---------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!


  // Durchlaufen und
  FOR   vItem # Sort_ItemFirst(vTree)
  loop  vItem # Sort_ItemNext(vTree,vItem)
  WHILE (vItem != 0) do begin

    // Datensatz holen
    RecRead(CnvIA(vItem->spCustom),0,0,vItem->spID);    // Custom=Dateinr, ID=SatzID

    Print('POS');
  END;  // loop


  // Liste beenden
  ListTerm();

  // Löschen der Liste
  Sort_KillList(vTree);

end;

//========================================================================