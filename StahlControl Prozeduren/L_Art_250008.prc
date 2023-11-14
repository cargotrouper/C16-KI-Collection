@A+
//===== Business-Control =================================================
//
//  Prozedur    L_Art_250008
//                    OHNE E_R_G
//  Info        Lagerjournal drucken MARKIERT
//
//
//  21.03.2006  AI  Erstellung der Prozedur
//  29.07.2008  DS  QUERY
//  05.03.2009  MS  Anpassungen fuer Jepsen
//  12.11.2013  AH  BugFix
//  13.06.2022  AH  ERX
//
//  Subprozeduren
//    SUB StartList(aSort : int; aSortName : alpha);
//========================================================================
@I:Def_Global
@I:Def_List
declare StartList(aSort : int; aSortName : alpha);


//========================================================================
//  Main
//
//========================================================================
MAIN
local begin
  vItem : int;
end;
begin
  vItem # gMarkList->CteRead(_CteFirst);
  if(vItem = 0) then begin
    Msg(99,'Bitte markieren Sie zunächst einen bzw. mehrere Artikel!',0,0,0);
    RETURN;
  end;

//  12.11.2013 AH Lib_Dokumente:Printform(250,'Lagerjournal-Artikelliste',false);
  StartList(0,'');
end;



//========================================================================
//  Print
//
//========================================================================
Sub Print(aName : alpha);
begin

  case aName of

    'journal' : begin
      StartLine();
      Write(1, cnvad(Art.J.Anlage.Datum)                            ,n , 0);
      Write(2, cnvat(Art.J.Anlage.Zeit)                             ,n , 0);
      Write(3, Art.J.Anlage.User                                    ,n , 0);
      Write(4, ZahlF(Art.J.Menge,2) + Art.MEH                       ,n , 0);
      Write(5, Art.J.Bemerkung                                      ,n , 0);
      EndLine();
     end;



    'Selektierung' : begin

      List_Spacing[ 1]  #   0.0;
      List_Spacing[ 2]  # List_Spacing[ 1] + 20.0;
      List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
      List_Spacing[ 4]  # List_Spacing[ 3] + 30.0;
      List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
      List_Spacing[ 6]  # List_Spacing[ 5] + 20.0;

      StartLine();
      Write( 1, Art.Nummer                                          ,n , 0);
      Write( 2, cnvad(Sel.von.Datum)                                ,n , 0);
      Write( 3, ' bis '                                             ,n , 0);
      Write( 4, cnvad(Sel.bis.Datum)                                ,n , 0);
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
    StartLine();
    EndLine();
  end;

  List_Spacing[ 1]  #  0.0;
  List_Spacing[ 2]  #100.0;
  List_Spacing[ 3]  #200.0;
  StartLine();
  Write(1, Prg.Key.Name                        ,n , 0);
  EndLine();
  StartLine();
  EndLine();
  StartLine();
  EndLine();

  Print('Selektierung');        // Selektierung drucken

  List_Spacing[ 1]  #   0.0;
  List_Spacing[ 2]  # List_Spacing[ 1] + 30.0;
  List_Spacing[ 3]  # List_Spacing[ 2] + 30.0;
  List_Spacing[ 4]  # List_Spacing[ 3] + 30.0;
  List_Spacing[ 5]  # List_Spacing[ 4] + 30.0;
  List_Spacing[ 6]  # List_Spacing[ 5] + 40.0;


  StartLine(_LF_UnderLine + _LF_Bold);
  Write(1,  'Datum'                                ,n , 0);
  Write(2,  'Zeit'                                 ,n , 0);
  Write(3,  'User'                                 ,n , 0);
  Write(4,  'Menge'                                ,n , 0);
  Write(5,  'Bemerkung'                            ,n , 0);
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
  vItem       : int;
  vKey        : int;
  vMFile,vMID : int;
  vDat1, vDat2 : date;
  vTree       : int;
  vSortKey    : alpha;
  vQ           : alpha(4000);
  vFirst      : logic;
end;
begin

  if (Dlg_Standard:DatumVonBis('Bewegungszeitraum von '/*+Art.Nummer*/,var Sel.von.Datum, var Sel.bis.Datum)=false) then RETURN;

  gFrmMain->winfocusset();  // HAUPTFENSTER baut Liste auf!!!

  //vTree # CteOpen(_CteTreeCI);    // Rambaum anlegen

  // Ermittelt das erste Element der Liste (oder des Baumes)
  FOR vItem # gMarkList->CteRead(_CteFirst)
  // Instanzieren des globalen Datenbereiches, der mit diesem Element verknüpft ist
  LOOP vItem # gMarkList->CteRead(_CteNext, vItem)
  WHILE (vItem > 0) do begin
    Lib_Mark:TokenMark(vItem,var vMFile,var vMID);
    if (vMFile<> 250) then CYCLE;

    Erx # RecRead(250,0,_RecId,vMID); // Markierte

    // Selektionsquery
    vQ # '';
    if ( Sel.von.Datum != 0.0.0) or ( Sel.bis.Datum != 0.0.0) then
      Lib_Sel:QVonBisD( var vQ, 'Art.J.Anlage.Datum', Sel.von.Datum, Sel.bis.Datum );
    Lib_Sel:QAlpha( var vQ, 'Art.J.ArtikelNr', '=', Art.Nummer );

    // Selektion starten...
    vSel # SelCreate( 253, 2 );
    vSel->SelDefQuery( '', vQ );
    vSelName # Lib_Sel:SaveRun( var vSel, 0);

    if (vFirst) then Lib_Print:Print_FF()
    else ListInit(n); // KEIN Landscap
    vFirst # true;

    // Lagerjournal loopen
//    Erx # RecLink(253,250,vSel,_recFirst);
    FOR Erx # RecRead(253,vsel,_recfirst)
    LOOP Erx # RecRead(253,vsel,_recnext)
    WHILE (Erx <= _rLocked ) DO BEGIN
      Print('journal');        // Artikel drucken
  //    Erx # RecLink(253,250,vSel,_recNext);
    END;

    SelDelete(253,vSelName);

  END;


  ListTerm();


//  SelDelete(253,vSelName);

end;

//========================================================================