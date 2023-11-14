@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Ein_500500
//
//  Info        Eingangsliste
//
//
//  18.02.2008 MS  Erstellung der Prozedur
//  31.07.2008 DS  QUERY
//  17.08.2010  TM  Selektions-Fixdatum 1.1.2010 getauscht durch 31.12. des aktuellen Jahres
//  16.10.2013  AH  Anfragenx
//  18.02.2020  ST  Übernahme für Brockhaus Tagesliste
//
//  Subprozeduren
//    SUB AusSel();
//    SUB StartList(aSort : int; aSortName : alpha);
//    SUB SeitenKopf(aSeite : int);
//    SUB SeitenFuss(aSeite : int);
//    SUB Print(aName : alpha);
//
//========================================================================
@I:Def_Global
@I:Def_List

declare StartList(aSort : int; aSortName : alpha);
declare Autogenerate();

define begin
  cFile : 506
  cSel  : 'LST.500008'
  cMask : 'SEL.LST.500008'
end;

local begin
  gSumGew : float;

end;



//========================================================================
//  Main
//
//========================================================================
MAIN
begin
  RecBufClear(998);

  if (gUsergroup = 'JOB-SERVER') or (gUserGroup=*^'SOA*') then begin
    Autogenerate();
    RETURN;
  end;

  Dlg_Standard:DatumVonBis('Eingangsdatum', var Sel.von.Datum, var Sel.bis.Datum, 0.0.0, today);
  StartList(1,'');  // Liste generieren
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
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 20.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 25.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 35.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 35.0;
  List_Spacing[ 7]  # List_Spacing[ 6] + 20.0;
  List_Spacing[ 8]  # List_Spacing[ 7] + 30.0;
  List_Spacing[ 9]  # List_Spacing[ 8] + 25.0;
  List_Spacing[10]  # List_Spacing[ 9] + 20.0;
  List_Spacing[11]  # List_Spacing[10] + 25.0;
  List_Spacing[12]  # List_Spacing[11] + 25.0;

  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'WE-Dat.'       ,n ,0);
  Write(2,  'Wgr.'          ,y ,0);
  Write(3,  'Bestell-Nr.'   ,y ,0 ,3.0);
  Write(4,  'Lfr.stichwort' ,n ,0);
  Write(5,  'AB-Nr.'        ,y ,0);
  Write(6,  'Prj-Nr.'       ,y ,0 ,3.0);
  Write(7,  'Lagerort'      ,n ,0);
  Write(8,  'Coil-Nr.'      ,n ,0);
  Write(9,  'Gewicht kg'    ,y ,0);

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
sub Print(aName   : alpha);
local begin
  vEinzel : float;
  vGesamt : float;
end;
begin
   case aName of

    'Position' : begin

      StartLine();
      if (Ein.E.Eingang_Datum <> 0.0.0) then
        Write(1, DatS(Ein.E.Eingang_Datum)                                             ,n , _LF_Date);
      Write(2,  ZahlI(Ein.P.Warengruppe)                                               ,y ,_LF_Int);
      Write(3,  ZahlI(Ein.P.Nummer) +'/ '+ ZahlI(Ein.P.Position)                       ,y ,0 , 3.0);
      Write(4,  Ein.P.LieferantenSW                                                    ,n ,0);
      Write(5,  Ein.AB.Nummer                                                          ,y ,0);
      Write(6,  ZahlI(Ein.P.Projektnummer)                                             ,y ,_LF_Int,3.0);
      if(Ein.E.Lageradresse <>0) then
        RecLink(100,501,11,_recFirst);
      Write(7,  Adr.Stichwort                                                          ,n ,0);
      Write(8,  Ein.E.Coilnummer                                                       ,n ,0);
      Write(9,  ZahlF(Ein.E.Gewicht, Set.Stellen.Gewicht)                            ,y ,_LF_NUM);
      EndLine();

      AddSum(1,vGesamt);
      AddSum(2,Ein.E.Gewicht);
    end;

    'Summe' : begin
      StartLine(_LF_Overline + _LF_Bold);
      Write( 9, ZahlF(GetSum(2),Set.Stellen.Gewicht)                                   ,y , _LF_NUM);
      EndLine();
    end;
  end; // CASE
end;


//========================================================================
//  StartList
//
//========================================================================
Sub StartList(aSort : int; aSortName : alpha);
local begin
  vSel        : int;
  vFlag       : int;        // Datensatzlese option
  vSelName    : alpha;
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vOK         : logic;
  vTree       : int;
  vSortKey    : alpha;
  vQ          : alpha(4000);
  vQ2         : alpha(4000);
  vQ3         : alpha(4000);
  vQ4         : alpha(4000);
  vQ5         : alpha(4000);
  vQ6         : alpha(4000);
end;
begin

  // dynamische Sortierung? -> RAMBAUM aufbauen
  vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // BESTAND-Selektion öffnen

  // Selektionsquery für 506
  vQ # '';
  Lib_Sel:QAlpha(var vQ, '"Ein.E.Löschmarker"', '!=', '*');
  Lib_Sel:QVonBisD( var vQ, '"Ein.E.Eingang_Datum"', Sel.von.Datum, Sel.bis.Datum );


  // Selektion starten...
  vSel # SelCreate( 506, 1 );
  vSel->SelDefQuery('', vQ );
  vSelName # Lib_Sel:SaveRun( var vSel, 0);


  // Ausgabe ----------------------------------------------------------------

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!
  ListInit(y);              // starte Landscape

  // Durchlaufen und löschen
  FOR   Erg # RecRead(506,vSel,_RecFirst)
  LOOP  Erg # RecRead(506,vSel,_RecNext)
  WHILE (Erg <= _rLocked ) DO BEGIN

    Print('Position');

  END;
  SelClose(vSel);
  SelDelete(506, vSelName);
  vSel # 0;

  Print('Summe'); //Summen drucken

  gSumGew # GetSum(2);


  // Löschen der Liste
  Sort_KillList(vTree);


  ListTerm();
end;




//========================================================================
//
//========================================================================
sub Autogenerate();
local begin
  vForm       : alpha(1000);
  vDesign     : alpha(1000);
  vJSON       : handle;
end
begin

  Sel.von.Datum         # Gv.Datum.01;
  Sel.bis.Datum         # GV.Datum.02;

  StartList(0,'');

  // Ergebnis zurück
  vJSON # Lib_Json:OpenJSON();
  Lib_Json:AddJSONAlpha(vJSON,'KgVormat', ANum(gSumGew,0));
  gBCPS_ResultJson # Lib_Json:ToJsonList(vJson);
end;


//========================================================================
